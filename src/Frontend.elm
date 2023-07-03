module Frontend exposing (main)

import Browser
import Frontend.Page.Login
import Html


type Model
    = Login Frontend.Page.Login.Model


type Msg
    = LoginMsg Frontend.Page.Login.Msg


view : Model -> Html.Html Msg
view model =
    case model of
        Login subModel ->
            subModel |> Frontend.Page.Login.view |> Html.map LoginMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( LoginMsg subMsg, Login subModel ) ->
            let
                ( nextSubModel, nextCmd ) =
                    Frontend.Page.Login.update subMsg subModel
            in
            ( Login nextSubModel, nextCmd |> Cmd.map LoginMsg )


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( Login Frontend.Page.Login.init, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
