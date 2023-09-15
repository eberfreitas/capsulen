module App exposing (main)

import AppUrl
import Browser
import Browser.Navigation
import Context
import Effect
import Html
import Page.Login
import Page.Register
import Url
import View.Alerts


type alias Model =
    { url : Url.Url
    , context : Context.Context
    , page : Page
    }


type Page
    = Register Page.Register.Model
    | Login Page.Login.Model
    | NotFound


type Msg
    = UrlChange Url.Url
    | UrlRequest Browser.UrlRequest
    | RegisterMsg Page.Register.Msg
    | LoginMsg Page.Login.Msg
    | AlertsMsg View.Alerts.Msg


view : Model -> Browser.Document Msg
view model =
    let
        pageHtml : Html.Html Msg
        pageHtml =
            case model.page of
                Register subModel ->
                    subModel |> Page.Register.view |> Html.map RegisterMsg

                Login subModel ->
                    subModel |> Page.Login.view |> Html.map LoginMsg

                NotFound ->
                    -- TODO: create a proper error page
                    Html.text "404 Not found"
    in
    { title = "Capsulen"
    , body =
        [ Html.div
            []
            [ Html.h1 [] [ Html.text "Capsulen" ]
            , View.Alerts.view model.context.alerts |> Html.map AlertsMsg
            , Html.div [] [ pageHtml ]
            ]
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
                ( page, cmd ) =
                    router <| AppUrl.fromUrl url
            in
            ( { model | page = page, url = url }, cmd )

        ( AlertsMsg subMsg, _ ) ->
            let
                effect : Effect.Effect
                effect =
                    View.Alerts.update subMsg

                ( nextContext, cmds ) =
                    Effect.run effect model.context
            in
            ( { model | context = nextContext }, cmds )

        ( RegisterMsg subMsg, Register subModel ) ->
            let
                ( nextSubModel, effects, nextCmd ) =
                    Page.Register.update subMsg subModel

                ( nextContext, effectsCmds ) =
                    Effect.run effects model.context
            in
            ( { model | page = Register nextSubModel, context = nextContext }
            , Cmd.batch [ effectsCmds, nextCmd |> Cmd.map RegisterMsg ]
            )

        ( LoginMsg subMsg, Login subModel ) ->
            let
                ( nextSubModel, effects, nextCmd ) =
                    Page.Login.update subMsg subModel

                ( nextContext, effectsCmds ) =
                    Effect.run effects model.context
            in
            ( { model | page = Login nextSubModel, context = nextContext }
            , Cmd.batch [ effectsCmds, nextCmd |> Cmd.map LoginMsg ]
            )

        _ ->
            ( model, Cmd.none )


init : () -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init () url key =
    let
        ( page, cmd ) =
            router <| AppUrl.fromUrl url

        context =
            { key = key
            , alerts = []
            , user = Nothing
            }
    in
    ( { url = url, context = context, page = page }, cmd )


router : AppUrl.AppUrl -> ( Page, Cmd Msg )
router url =
    case url.path of
        [] ->
            Tuple.mapBoth Login (Cmd.map LoginMsg) Page.Login.init

        [ "register" ] ->
            Tuple.mapBoth Register (Cmd.map RegisterMsg) Page.Register.init

        _ ->
            ( NotFound, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Page.Register.subscriptions |> Sub.map RegisterMsg
        , Page.Login.subscriptions |> Sub.map LoginMsg
        ]


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
