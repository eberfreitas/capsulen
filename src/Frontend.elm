module Frontend exposing (main)

import Browser
import Frontend.Context
import Frontend.Effect
import Frontend.Page.Register
import Frontend.View.Alerts
import Html


type alias Model =
    { context : Frontend.Context.Context
    , page : Page
    }


type Page
    = Register Frontend.Page.Register.Model


type Msg
    = RegisterMsg Frontend.Page.Register.Msg
    | AlertsMsg Frontend.View.Alerts.Msg


view : Model -> Html.Html Msg
view model =
    let
        pageHtml : Html.Html Msg
        pageHtml =
            case model.page of
                Register subModel ->
                    subModel |> Frontend.Page.Register.view |> Html.map RegisterMsg
    in
    Html.div
        []
        [ Html.h1 [] [ Html.text "Capsulen" ]
        , Frontend.View.Alerts.view model.context.alerts |> Html.map AlertsMsg
        , Html.div [] [ pageHtml ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( AlertsMsg subMsg, _ ) ->
            let
                effect =
                    Frontend.View.Alerts.update subMsg

                ( nextContext, cmds ) =
                    Frontend.Effect.run effect model.context
            in
            ( { model | context = nextContext }, cmds )

        ( RegisterMsg subMsg, Register subModel ) ->
            let
                ( nextSubModel, effects, nextCmd ) =
                    Frontend.Page.Register.update subMsg subModel

                ( nextContext, effectsCmds ) =
                    Frontend.Effect.run effects model.context
            in
            ( { model | page = Register nextSubModel, context = nextContext }
            , Cmd.batch [ effectsCmds, nextCmd |> Cmd.map RegisterMsg ]
            )


init : () -> ( Model, Cmd Msg )
init () =
    let
        ( pageModel, pageCmd ) =
            Frontend.Page.Register.init
    in
    ( { context = Frontend.Context.new, page = Register pageModel }, Cmd.map RegisterMsg pageCmd )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
