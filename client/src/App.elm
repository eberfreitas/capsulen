module App exposing (main)

import Browser
import Context
import Effect
import Page.Register
import View.Alerts
import Html


type alias Model =
    { context : Context.Context
    , page : Page
    }


type Page
    = Register Page.Register.Model


type Msg
    = RegisterMsg Page.Register.Msg
    | AlertsMsg View.Alerts.Msg


view : Model -> Html.Html Msg
view model =
    let
        pageHtml : Html.Html Msg
        pageHtml =
            case model.page of
                Register subModel ->
                    subModel |> Page.Register.view |> Html.map RegisterMsg
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


init : () -> ( Model, Cmd Msg )
init () =
    let
        ( pageModel, pageCmd ) =
            Page.Register.init
    in
    ( { context = Context.new, page = Register pageModel }, Cmd.map RegisterMsg pageCmd )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Page.Register.subscriptions |> Sub.map RegisterMsg


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
