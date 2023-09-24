module App exposing (main)

import Alert
import AppUrl
import Browser
import Browser.Navigation
import Context
import Effect
import Html
import Page.Login
import Page.Posts
import Page.Register
import Port
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
    | Posts Page.Posts.Model
    | NotFound


type Msg
    = UrlChange Url.Url
    | UrlRequest Browser.UrlRequest
    | GotError String
    | RegisterMsg Page.Register.Msg
    | LoginMsg Page.Login.Msg
    | PostsMsg Page.Posts.Msg
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

                Posts subModel ->
                    subModel |> Page.Posts.view model.context |> Html.map PostsMsg

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

        ( GotError errorMsg, _ ) ->
            let
                effect =
                    Effect.addAlert (Alert.new Alert.Error errorMsg)

                ( nextContext, cmd ) =
                    Effect.run model.context effect
            in
            ( { model | context = nextContext }, cmd )

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
                    Page.Posts.update subMsg subModel

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
        ( page, cmd ) =
            router <| AppUrl.fromUrl url
    in
    ( { url = url, context = Context.new key, page = page }, cmd )


router : AppUrl.AppUrl -> ( Page, Cmd Msg )
router url =
    case url.path of
        [] ->
            Tuple.mapBoth Login (Cmd.map LoginMsg) Page.Login.init

        [ "register" ] ->
            Tuple.mapBoth Register (Cmd.map RegisterMsg) Page.Register.init

        [ "posts" ] ->
            Tuple.mapBoth Posts (Cmd.map PostsMsg) Page.Posts.init

        _ ->
            ( NotFound, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        batch =
            Port.getError GotError
                :: (case model.page of
                        Register subModel ->
                            [ Page.Register.subscriptions subModel.tasks |> Sub.map RegisterMsg ]

                        _ ->
                            []
                   )
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
