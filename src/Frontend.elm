module Frontend exposing (main)

import Browser
import Frontend.Page.Login
import Frontend.Page.Register
import Html


type Model
    = Login Frontend.Page.Login.Model
    | Register Frontend.Page.Register.Model


type Msg
    = LoginMsg Frontend.Page.Login.Msg
    | RegisterMsg Frontend.Page.Register.Msg


view : Model -> Html.Html Msg
view model =
    case model of
        Login subModel ->
            subModel |> Frontend.Page.Login.view |> Html.map LoginMsg

        Register subModel ->
            subModel |> Frontend.Page.Register.view |> Html.map RegisterMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( LoginMsg subMsg, Login subModel ) ->
            let
                ( nextSubModel, nextCmd ) =
                    Frontend.Page.Login.update subMsg subModel
            in
            ( Login nextSubModel, nextCmd |> Cmd.map LoginMsg )

        ( RegisterMsg subMsg, Register subModel ) ->
            let
                ( nextSubModel, nextCmd ) =
                    Frontend.Page.Register.update subMsg subModel
            in
            ( Register nextSubModel, nextCmd |> Cmd.map RegisterMsg )

        _ ->
            ( model, Cmd.none )


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
