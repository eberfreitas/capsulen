module Frontend exposing (main)

import Browser
import Frontend.Page.Register
import Html


type Model
    = Register Frontend.Page.Register.Model


type Msg
    = RegisterMsg Frontend.Page.Register.Msg


view : Model -> Html.Html Msg
view model =
    case model of
        Register subModel ->
            subModel |> Frontend.Page.Register.view |> Html.map RegisterMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( RegisterMsg subMsg, Register subModel ) ->
            let
                ( nextSubModel, nextCmd ) =
                    Frontend.Page.Register.update subMsg subModel
            in
            ( Register nextSubModel, nextCmd |> Cmd.map RegisterMsg )


init : () -> ( Model, Cmd Msg )
init () =
    let
        ( pageModel, pageCmd ) =
            Frontend.Page.Register.init
    in
    ( Register pageModel, Cmd.map RegisterMsg pageCmd )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
