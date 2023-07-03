module Frontend.Page.Login exposing (Model, Msg, init, update, view)

import Frontend.Port
import Frontend.View
import Html
import Html.Events
import Json.Encode


type alias Model =
    { username : String
    , privateKey : String
    }


type Msg
    = FillUsername String
    | FillPrivateKey String
    | Submit


init : Model
init =
    { username = "", privateKey = "" }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FillUsername username ->
            ( { model | username = username }, Cmd.none )

        FillPrivateKey privateKey ->
            ( { model | privateKey = privateKey }, Cmd.none )

        Submit ->
            ( model, model |> encodeModel |> Frontend.Port.login )


view : Model -> Html.Html Msg
view model =
    Frontend.View.template
        [ Html.fieldset []
            [ Html.legend [] [ Html.text "Login" ]
            , Html.label []
                [ Html.text "Username"
                , Html.input [ Html.Events.onInput FillUsername ] [ Html.text model.username ]
                ]
            , Html.label []
                [ Html.text "Private key"
                , Html.input [ Html.Events.onInput FillPrivateKey ] [ Html.text model.privateKey ]
                ]
            , Html.button [ Html.Events.onClick Submit ] [ Html.text "Access" ]
            ]
        ]


encodeModel : Model -> Json.Encode.Value
encodeModel model =
    Json.Encode.object
        [ ( "username", Json.Encode.string model.username )
        , ( "privateKey", Json.Encode.string model.privateKey )
        ]
