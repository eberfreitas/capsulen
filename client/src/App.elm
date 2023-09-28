module App exposing (main)

import AppUrl
import Browser
import Browser.Navigation
import Context
import Effect
import Html
import Html.Attributes
import Locale
import Page.Login
import Page.Posts
import Page.Register
import Port
import Tuple.Extra
import Url
import View.Alerts
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
        localeHelper : String -> String
        localeHelper =
            Locale.getPhrase model.context.locale

        pageHtml : Html.Html Msg
        pageHtml =
            case model.page of
                Register subModel ->
                    subModel |> Page.Register.view localeHelper |> Html.map RegisterMsg

                Login subModel ->
                    subModel |> Page.Login.view localeHelper model.context |> Html.map LoginMsg

                Posts subModel ->
                    subModel |> Page.Posts.view localeHelper model.context |> Html.map PostsMsg

                NotFound ->
                    -- TODO: create a proper error page
                    Html.text "404 Not found"
    in
    { title = "Capsulen"
    , body =
        [ Html.div [ Html.Attributes.class "wrapper" ] [ pageHtml ]
        , View.Alerts.view localeHelper model.context.alerts |> Html.map AlertsMsg
        ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
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
                    Page.Register.update subMsg subModel

                ( nextContext, effectsCmds ) =
                    Effect.run model.context effects
            in
            ( { model | page = Register nextSubModel, context = nextContext }
            , Cmd.batch [ effectsCmds, nextCmd |> Cmd.map RegisterMsg ]
            )

        ( LoginMsg subMsg, Login subModel ) ->
            let
                ( nextSubModel, effects, nextCmd ) =
                    Page.Login.update subMsg subModel

                ( nextContext, effectsCmds ) =
                    Effect.run model.context effects
            in
            ( { model | page = Login nextSubModel, context = nextContext }
            , Cmd.batch [ effectsCmds, nextCmd |> Cmd.map LoginMsg ]
            )

        ( PostsMsg subMsg, Posts subModel ) ->
            let
                ( nextSubModel, effects, nextCmd ) =
                    Page.Posts.update model.context subMsg subModel

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
        -- TODO: get locale from browser as flag
        initContext =
            Context.new key (Locale.fromString "en") View.Theme.Dark

        ( page, effect, pageCmd ) =
            router initContext <| AppUrl.fromUrl url

        ( nextContext, effectCmd ) =
            Effect.run initContext effect

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
            Page.Posts.init context
                |> Tuple.Extra.mapTrio
                    Posts
                    identity
                    (Cmd.map PostsMsg)

        _ ->
            ( NotFound, Effect.none, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        batch : List (Sub Msg)
        batch =
            case model.page of
                Register subModel ->
                    [ Page.Register.subscriptions subModel.tasks |> Sub.map RegisterMsg ]

                Login subModel ->
                    [ Page.Login.subscriptions subModel.tasks |> Sub.map LoginMsg ]

                Posts subModel ->
                    [ Page.Posts.subscriptions subModel.tasks |> Sub.map PostsMsg ]

                _ ->
                    []
    in
    Sub.batch batch


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
