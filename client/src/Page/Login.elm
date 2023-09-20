module Page.Login exposing (Model, Msg, init, subscriptions, update, view)

import Alert
import Api
import Effect
import Form
import Html
import Html.Attributes
import Html.Events
import Http
import Json.Decode
import Json.Encode
import Phosphor
import Port
import Task


type alias Model =
    { usernameInput : Form.Input String
    , privateKeyInput : Form.Input String
    , showPrivateKey : Bool
    }


type alias LoginRequest =
    { username : String
    , challengeEncrypted : String
    }


type Msg
    = WithUsername Form.InputEvent
    | WithPrivateKey Form.InputEvent
    | ToggleShowPrivateKey
    | Submit
    | GotLoginRequest (Result String LoginRequest)
    | GotLoginChallenge Json.Decode.Value
    | GotLogin (Result String String)


baseModel : Model
baseModel =
    { usernameInput = Form.newInput
    , privateKeyInput = Form.newInput
    , showPrivateKey = False
    }


init : ( Model, Cmd Msg )
init =
    ( baseModel, Cmd.none )


view : Model -> Html.Html Msg
view { usernameInput, privateKeyInput, showPrivateKey } =
    let
        ( privateKeyInputType, togglePrivateKeyIcon ) =
            if showPrivateKey then
                ( "text", Phosphor.eyeClosed Phosphor.Regular |> Phosphor.toHtml [] )

            else
                ( "password", Phosphor.eye Phosphor.Regular |> Phosphor.toHtml [] )
    in
    Html.div []
        [ Html.form [ Html.Events.onSubmit Submit ]
            [ Html.fieldset []
                [ Html.legend [] [ Html.text "Login" ]
                , Html.label []
                    [ Html.div []
                        [ Html.text "Username"
                        , Html.input
                            ([ Html.Attributes.type_ "text"
                             , Html.Attributes.value usernameInput.raw
                             ]
                                ++ Form.inputEvents WithUsername
                            )
                            []
                        , Form.viewInputError usernameInput
                        ]
                    ]
                , Html.label []
                    [ Html.div []
                        [ Html.text "Private key"
                        , Html.input
                            ([ Html.Attributes.type_ privateKeyInputType
                             , Html.Attributes.value privateKeyInput.raw
                             ]
                                ++ Form.inputEvents WithPrivateKey
                            )
                            []
                        , Html.button
                            [ Html.Attributes.type_ "button", Html.Events.onClick ToggleShowPrivateKey ]
                            [ togglePrivateKeyIcon ]
                        , Form.viewInputError privateKeyInput
                        , Html.div [] [ Html.text "Your private key will *never* be sent over the network." ]
                        ]
                    ]
                , Html.button [] [ Html.text "Login" ]
                ]
            ]
        , Html.a [ Html.Attributes.href "/register" ] [ Html.text "Register new account" ]
        ]


update : Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update msg model =
    case msg of
        WithUsername event ->
            ( { model | usernameInput = updateInput event model.usernameInput }
            , Effect.none
            , Cmd.none
            )

        WithPrivateKey event ->
            ( { model | privateKeyInput = updateInput event model.privateKeyInput }
            , Effect.none
            , Cmd.none
            )

        ToggleShowPrivateKey ->
            ( { model | showPrivateKey = not model.showPrivateKey }
            , Effect.none
            , Cmd.none
            )

        Submit ->
            if validInputs model then
                ( model
                , Effect.none
                , Api.post
                    { url = "/api/users/login_request"
                    , body = Http.stringBody "text/plain" model.usernameInput.raw
                    , decoder = Json.Decode.decodeString decodeLoginRequest
                    }
                    |> Task.attempt GotLoginRequest
                )

            else
                ( model
                , Effect.addAlert (Alert.new Alert.Warning "Please, fill both fields before submiting.")
                , Cmd.none
                )

        GotLoginRequest result ->
            case result of
                Err errorMsg ->
                    ( model
                    , Effect.addAlert (Alert.new Alert.Error errorMsg)
                    , Cmd.none
                    )

                Ok loginRequest ->
                    ( model
                    , Effect.none
                    , Port.sendLoginRequest <| encodeLoginRequestWithPrivateKey loginRequest model.privateKeyInput.raw
                    )

        GotLoginChallenge raw ->
            ( model
            , Effect.none
            , Api.post
                { url = "/api/users/login"
                , body = Http.jsonBody raw
                , decoder = (identity >> Ok)
                }
                |> Task.attempt GotLogin
            )

        GotLogin result ->
            case result of
                Ok token ->
                    ( model
                    , Effect.batch
                        [ Effect.login model.usernameInput.raw
                        , Effect.redirect "/posts"
                        ]
                    , Port.sendToken <| encodeTokenAndPrivateKey model.privateKeyInput.raw token
                    )

                Err errorMsg ->
                    ( model
                    , Effect.addAlert (Alert.new Alert.Error errorMsg)
                    , Cmd.none
                    )


encodeTokenAndPrivateKey : String -> String -> Json.Encode.Value
encodeTokenAndPrivateKey privateKey token =
    Json.Encode.object
        [ ( "privateKey", Json.Encode.string privateKey )
        , ( "token", Json.Encode.string token )
        ]


decodeLoginRequest : Json.Decode.Decoder LoginRequest
decodeLoginRequest =
    Json.Decode.map2 LoginRequest
        (Json.Decode.field "username" Json.Decode.string)
        (Json.Decode.field "challenge_encrypted" Json.Decode.string)


encodeLoginRequestWithPrivateKey : LoginRequest -> String -> Json.Encode.Value
encodeLoginRequestWithPrivateKey loginRequest privateKey =
    Json.Encode.object
        [ ( "username", Json.Encode.string loginRequest.username )
        , ( "privateKey", Json.Encode.string privateKey )
        , ( "challengeEncrypted", Json.Encode.string loginRequest.challengeEncrypted )
        ]


validInputs : Model -> Bool
validInputs model =
    case ( model.usernameInput.valid, model.privateKeyInput.valid ) of
        ( Just (Ok ""), _ ) ->
            False

        ( _, Just (Ok "") ) ->
            False

        ( Nothing, _ ) ->
            False

        ( _, Nothing ) ->
            False

        _ ->
            True


updateInput :
    Form.InputEvent
    -> Form.Input String
    -> Form.Input String
updateInput event input =
    case event of
        Form.OnInput raw ->
            { input | raw = String.trim raw }

        Form.OnFocus ->
            { input | valid = Nothing }

        Form.OnBlur ->
            Form.parseInput (identity >> Ok) input


subscriptions : Sub Msg
subscriptions =
    Port.getLoginChallenge GotLoginChallenge
