module App exposing (main)

import AppUrl
import Browser
import Browser.Events
import Browser.Navigation
import Context
import Css
import Effect
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Page.Login
import Page.Posts
import Page.Register
import Port
import Translations
import Tuple.Extra
import Url
import View.Alerts
import View.Style
import View.Theme


type alias Model =
    { url : Url.Url
    , context : Context.Context
    , page : Page
    }


type Page
    = Register Page.Register.Model
    | Login Page.Login.Model
    | Posts Page.Posts.Model
    | NotFound


type Msg
    = UrlChange Url.Url
    | UrlRequest Browser.UrlRequest
    | RegisterMsg Page.Register.Msg
    | LoginMsg Page.Login.Msg
    | PostsMsg Page.Posts.Msg
    | AlertsMsg View.Alerts.Msg


view : Model -> Browser.Document Msg
view model =
    let
        i : Translations.Helper
        i =
            Translations.translate model.context.language

        pageHtml : Html.Html Msg
        pageHtml =
            case model.page of
                Register subModel ->
                    subModel |> Page.Register.view i model.context |> Html.map RegisterMsg

                Login subModel ->
                    subModel |> Page.Login.view i model.context |> Html.map LoginMsg

                Posts subModel ->
                    subModel |> Page.Posts.view i model.context |> Html.map PostsMsg

                NotFound ->
                    -- TODO: create a proper error page
                    Html.text "404 Not found"
    in
    { title = "Capsulen"
    , body =
        [ View.Style.app model.context.theme
        , Html.div
            [ HtmlAttributes.css
                [ Css.display Css.flex_
                , Css.justifyContent Css.center
                , Css.minHeight <| Css.vh 100
                , Css.padding <| Css.rem 2
                , Css.width <| Css.pct 100
                ]
            ]
            [ pageHtml ]
        , View.Alerts.view model.context.theme model.context.alerts |> Html.map AlertsMsg
        ]
            |> List.map Html.toUnstyled
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        i : Translations.Helper
        i =
            Translations.translate model.context.language
    in
    case ( msg, model.page ) of
        ( UrlRequest request, _ ) ->
            case request of
                Browser.Internal url ->
                    ( model, Browser.Navigation.pushUrl model.context.key (Url.toString url) )

                Browser.External url ->
                    ( model, Browser.Navigation.load url )

        ( UrlChange url, _ ) ->
            let
                ( page, effect, pageCmd ) =
                    router model.context <| AppUrl.fromUrl url

                ( nextContext, effectCmd ) =
                    Effect.run model.context effect
            in
            ( { model | page = page, url = url, context = nextContext }, Cmd.batch [ effectCmd, pageCmd ] )

        ( AlertsMsg subMsg, _ ) ->
            let
                effect : Effect.Effect
                effect =
                    View.Alerts.update subMsg

                ( nextContext, cmds ) =
                    Effect.run model.context effect
            in
            ( { model | context = nextContext }, cmds )

        ( RegisterMsg subMsg, Register subModel ) ->
            let
                ( nextSubModel, effects, nextCmd ) =
                    Page.Register.update i subMsg subModel

                ( nextContext, effectsCmds ) =
                    Effect.run model.context effects
            in
            ( { model | page = Register nextSubModel, context = nextContext }
            , Cmd.batch [ effectsCmds, nextCmd |> Cmd.map RegisterMsg ]
            )

        ( LoginMsg subMsg, Login subModel ) ->
            let
                ( nextSubModel, effects, nextCmd ) =
                    Page.Login.update i subMsg subModel

                ( nextContext, effectsCmds ) =
                    Effect.run model.context effects
            in
            ( { model | page = Login nextSubModel, context = nextContext }
            , Cmd.batch [ effectsCmds, nextCmd |> Cmd.map LoginMsg ]
            )

        ( PostsMsg subMsg, Posts subModel ) ->
            let
                ( nextSubModel, effects, nextCmd ) =
                    Page.Posts.update i model.context subMsg subModel

                ( nextContext, effectsCmds ) =
                    Effect.run model.context effects
            in
            ( { model | page = Posts nextSubModel, context = nextContext }
            , Cmd.batch [ effectsCmds, nextCmd |> Cmd.map PostsMsg ]
            )

        _ ->
            ( model, Cmd.none )


init : () -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init () url key =
    let
        -- TODO: get language from browser as flag
        initContext : Context.Context
        initContext =
            Context.new key (Translations.languageFromString "en") View.Theme.Dark

        ( page, effect, pageCmd ) =
            router initContext <| AppUrl.fromUrl url

        ( nextContext, effectCmd ) =
            Effect.run initContext effect

        setTheme : Cmd msg
        setTheme =
            Port.setTheme <| View.Theme.encode nextContext.theme
    in
    ( { url = url
      , context = nextContext
      , page = page
      }
    , Cmd.batch [ effectCmd, pageCmd, setTheme ]
    )


router : Context.Context -> AppUrl.AppUrl -> ( Page, Effect.Effect, Cmd Msg )
router context url =
    case url.path of
        [] ->
            Page.Login.init
                |> Tuple.Extra.mapTrio
                    Login
                    identity
                    (Cmd.map LoginMsg)

        [ "register" ] ->
            Page.Register.init
                |> Tuple.Extra.mapTrio
                    Register
                    identity
                    (Cmd.map RegisterMsg)

        [ "posts" ] ->
            Page.Posts.init (Translations.translate context.language) context
                |> Tuple.Extra.mapTrio
                    Posts
                    identity
                    (Cmd.map PostsMsg)

        _ ->
            ( NotFound, Effect.none, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageBatch : List (Sub Msg)
        pageBatch =
            case model.page of
                Register subModel ->
                    [ Page.Register.subscriptions subModel.tasks |> Sub.map RegisterMsg ]

                Login subModel ->
                    [ Page.Login.subscriptions subModel.tasks |> Sub.map LoginMsg ]

                Posts subModel ->
                    [ Page.Posts.subscriptions subModel.tasks |> Sub.map PostsMsg ]

                _ ->
                    []

        alertSub : Sub Msg
        alertSub =
            case model.context.alerts of
                [] ->
                    Sub.none

                _ ->
                    Browser.Events.onAnimationFrameDelta View.Alerts.decay |> Sub.map AlertsMsg
    in
    Sub.batch (alertSub :: pageBatch)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = UrlChange
        , onUrlRequest = UrlRequest
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
