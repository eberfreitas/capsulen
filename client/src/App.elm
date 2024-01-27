module App exposing (Model, Msg, Page, main)

import AppUrl
import Browser
import Browser.Events
import Browser.Navigation
import Color.Extra
import Context
import Css
import Effect
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Json.Decode
import Page.Invites
import Page.Login
import Page.NotFound
import Page.Posts
import Page.Register
import Page.Settings
import Port
import Task
import Time
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
    | Invites Page.Invites.Model
    | Settings Page.Settings.Model
    | NotFound


type Msg
    = UrlChange Url.Url
    | UrlRequest Browser.UrlRequest
    | RegisterMsg Page.Register.Msg
    | LoginMsg Page.Login.Msg
    | PostsMsg Page.Posts.Msg
    | InvitesMsg Page.Invites.Msg
    | SettingsMsg Page.Settings.Msg
    | AlertsMsg View.Alerts.Msg
    | Logout Browser.Events.Visibility
    | GotTimeZone (Result () Time.Zone)


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

                Invites subModel ->
                    subModel |> Page.Invites.view i model.context |> Html.map InvitesMsg

                Settings subModel ->
                    subModel |> Page.Settings.view i model.context |> Html.map SettingsMsg

                NotFound ->
                    Page.NotFound.view model.context.theme
    in
    { title = "Capsulen"
    , body =
        [ View.Style.app model.context.theme
        , Html.div
            [ HtmlAttributes.css
                [ Css.display Css.flex_
                , Css.justifyContent Css.center
                , Css.minHeight (Css.calc (Css.vh 100) (Css.minus <| Css.rem 2))
                , Css.padding <| Css.rem 2
                , Css.width <| Css.pct 100
                ]
            ]
            [ pageHtml ]
        , Html.div
            [ HtmlAttributes.css
                [ Css.textAlign Css.center
                , Css.fontSize <| Css.rem 0.85
                , Css.marginBottom <| Css.rem 1
                ]
            ]
            [ Html.text <| i Translations.Credits
            , Html.text " "
            , Html.a
                [ HtmlAttributes.href "https://www.eberfdias.com"
                , HtmlAttributes.target "_blank"
                , HtmlAttributes.css
                    [ Css.fontWeight Css.bold
                    , Css.textDecoration Css.none
                    , Css.color (model.context.theme |> View.Theme.foregroundColor |> Color.Extra.toCss)
                    , Css.cursor Css.pointer
                    ]
                ]
                [ Html.text "éber f. dias" ]
            , Html.text " • "
            , Html.a
                [ HtmlAttributes.href "https://www.buymeacoffee.com/eberfre"
                , HtmlAttributes.target "_blank"
                , HtmlAttributes.css
                    [ Css.fontWeight Css.bold
                    , Css.textDecoration Css.none
                    , Css.color (model.context.theme |> View.Theme.foregroundColor |> Color.Extra.toCss)
                    , Css.cursor Css.pointer
                    ]
                ]
                [ Html.text <| i Translations.BuyMePizza ]
            ]
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

        pageUpdate :
            (Translations.Helper -> Context.Context -> subMsg -> subModel -> ( subModel, Effect.Effect, Cmd subMsg ))
            -> (subMsg -> Msg)
            -> subMsg
            -> (subModel -> Page)
            -> subModel
            -> Context.Context
            -> ( Model, Cmd Msg )
        pageUpdate updateFn pageMsg subMsg page subModel context =
            let
                ( nextSubModel, effects, nextCmd ) =
                    updateFn i context subMsg subModel

                ( nextContext, effectsCmd ) =
                    Effect.run model.context effects
            in
            ( { model | page = page nextSubModel, context = nextContext }
            , Cmd.batch [ effectsCmd, nextCmd |> Cmd.map pageMsg ]
            )
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

                ( nextContext, cmd ) =
                    Effect.run model.context effect
            in
            ( { model | context = nextContext }, cmd )

        ( RegisterMsg subMsg, Register subModel ) ->
            pageUpdate Page.Register.update RegisterMsg subMsg Register subModel model.context

        ( LoginMsg subMsg, Login subModel ) ->
            pageUpdate Page.Login.update LoginMsg subMsg Login subModel model.context

        ( PostsMsg subMsg, Posts subModel ) ->
            pageUpdate Page.Posts.update PostsMsg subMsg Posts subModel model.context

        ( InvitesMsg subMsg, Invites subModel ) ->
            pageUpdate Page.Invites.update InvitesMsg subMsg Invites subModel model.context

        ( SettingsMsg subMsg, Settings subModel ) ->
            pageUpdate Page.Settings.update SettingsMsg subMsg Settings subModel model.context

        ( Logout visibility, _ ) ->
            case visibility of
                Browser.Events.Hidden ->
                    let
                        effects : Effect.Effect
                        effects =
                            Effect.batch [ Effect.logout, Effect.redirect "/" ]

                        ( nextContext, cmd ) =
                            Effect.run model.context effects
                    in
                    ( { model | context = nextContext }, cmd )

                Browser.Events.Visible ->
                    ( model, Cmd.none )

        ( GotTimeZone result, _ ) ->
            case result of
                Ok timeZone ->
                    let
                        context : Context.Context
                        context =
                            model.context

                        nextContext : Context.Context
                        nextContext =
                            { context | timeZone = timeZone }
                    in
                    ( { model | context = nextContext }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


init : Json.Decode.Value -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        initContext : Context.Context
        initContext =
            Context.fromFlags key flags

        ( page, effect, pageCmd ) =
            router initContext <| AppUrl.fromUrl url

        ( nextContext, effectCmd ) =
            Effect.run initContext effect

        setTheme : Cmd msg
        setTheme =
            Port.setTheme <| View.Theme.encode nextContext.theme

        getTimeZone : Cmd Msg
        getTimeZone =
            Task.attempt GotTimeZone Time.here
    in
    ( { url = url
      , context = nextContext
      , page = page
      }
    , Cmd.batch [ getTimeZone, effectCmd, pageCmd, setTheme ]
    )


router : Context.Context -> AppUrl.AppUrl -> ( Page, Effect.Effect, Cmd Msg )
router context url =
    case url.path of
        [] ->
            Page.Login.init context
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

        [ "invites" ] ->
            Page.Invites.init (Translations.translate context.language) context
                |> Tuple.Extra.mapTrio
                    Invites
                    identity
                    (Cmd.map InvitesMsg)

        [ "settings" ] ->
            Page.Settings.init (Translations.translate context.language) context
                |> Tuple.Extra.mapTrio
                    Settings
                    identity
                    (Cmd.map SettingsMsg)

        _ ->
            ( NotFound, Effect.none, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageSub : Sub Msg
        pageSub =
            case model.page of
                Register subModel ->
                    Page.Register.subscriptions subModel.tasks |> Sub.map RegisterMsg

                Login subModel ->
                    Page.Login.subscriptions subModel.tasks |> Sub.map LoginMsg

                Posts subModel ->
                    Page.Posts.subscriptions subModel |> Sub.map PostsMsg

                Invites subModel ->
                    Page.Invites.subscriptions subModel.tasks |> Sub.map InvitesMsg

                _ ->
                    Sub.none

        alertSub : Sub Msg
        alertSub =
            case model.context.alerts of
                [] ->
                    Sub.none

                _ ->
                    Browser.Events.onAnimationFrameDelta View.Alerts.decay |> Sub.map AlertsMsg

        logoutSub : Sub Msg
        logoutSub =
            case ( model.context.user, model.context.autoLogout ) of
                ( Just _, True ) ->
                    Browser.Events.onVisibilityChange Logout

                _ ->
                    Sub.none
    in
    Sub.batch [ alertSub, pageSub, logoutSub ]


main : Program Json.Decode.Value Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = UrlChange
        , onUrlRequest = UrlRequest
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
