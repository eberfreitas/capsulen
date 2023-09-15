module App exposing (main)

import Browser
import Context
import Effect
import Html
import Page.Login
import Page.Register
import View.Alerts


type alias Model =
    { context : Context.Context
    , page : Page
    }


type Page
    = Register Page.Register.Model
    | Login Page.Login.Model


type Msg
    = RegisterMsg Page.Register.Msg
    | LoginMsg Page.Login.Msg
    | AlertsMsg View.Alerts.Msg


view : Model -> Html.Html Msg
view model =
    let
        pageHtml : Html.Html Msg
        pageHtml =
            case model.page of
                Register subModel ->
                    subModel |> Page.Register.view |> Html.map RegisterMsg

                Login subModel ->
                    subModel |> Page.Login.view |> Html.map LoginMsg
    in
    Html.div
        []
        [ Html.h1 [] [ Html.text "Capsulen" ]
        , View.Alerts.view model.context.alerts |> Html.map AlertsMsg
        , Html.div [] [ pageHtml ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
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


init : () -> ( Model, Cmd Msg )
init () =
    let
        ( pageModel, pageCmd ) =
            Page.Login.init
    in
    ( { context = Context.new, page = Login pageModel }, Cmd.map LoginMsg pageCmd )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Page.Register.subscriptions |> Sub.map RegisterMsg
        , Page.Login.subscriptions |> Sub.map LoginMsg
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
