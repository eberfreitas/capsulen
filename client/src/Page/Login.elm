module Page.Login exposing (Model, Msg, init, subscriptions, update, view)

import Alert
import Api
import ConcurrentTask
import ConcurrentTask.Http
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


type alias LoginChallenge =
    { username : String
    , challengeEncrypted : String
    }


type TaskError
    = RequestError ConcurrentTask.Http.Error
    | Generic String


type TaskOutput
    = Register ()


type alias TaskPool =
    ConcurrentTask.Pool Msg TaskError TaskOutput


type Msg
    = WithUsername Form.InputEvent
    | WithPrivateKey Form.InputEvent
    | ToggleShowPrivateKey
    | Submit
      -- | GotLoginRequest (Result String LoginRequest)
      -- | GotLoginChallenge Json.Decode.Value
      -- | GotLogin (Result String String)
    | OnTaskProgress ( TaskPool, Cmd Msg )
    | OnTaskComplete (ConcurrentTask.Response TaskError TaskOutput)


baseModel : Model
baseModel =
    { usernameInput = Form.newInput
    , privateKeyInput = Form.newInput
    , showPrivateKey = False
    }


init : ( Model, Cmd Msg )
init =
    ( baseModel, Cmd.none )


view : (String -> String) -> Model -> Html.Html Msg
view i model =
    let
        ( privateKeyInputType, togglePrivateKeyIcon ) =
            if model.showPrivateKey then
                ( "text", Phosphor.eyeClosed Phosphor.Regular |> Phosphor.toHtml [] )

            else
                ( "password", Phosphor.eye Phosphor.Regular |> Phosphor.toHtml [] )
    in
    Html.div []
        [ Html.form [ Html.Events.onSubmit Submit ]
            [ Html.fieldset []
                [ Html.legend [] [ Html.text <| i "LOGIN" ]
                , Html.label []
                    [ Html.div []
                        [ Html.text <| i "USERNAME"
                        , Html.input
                            ([ Html.Attributes.type_ "text"
                             , Html.Attributes.value model.usernameInput.raw
                             ]
                                ++ Form.inputEvents WithUsername
                            )
                            []
                        , Form.viewInputError i model.usernameInput
                        ]
                    ]
                , Html.label []
                    [ Html.div []
                        [ Html.text <| i "PRIVATE_KEY"
                        , Html.input
                            ([ Html.Attributes.type_ privateKeyInputType
                             , Html.Attributes.value model.privateKeyInput.raw
                             ]
                                ++ Form.inputEvents WithPrivateKey
                            )
                            []
                        , Html.button
                            [ Html.Attributes.type_ "button", Html.Events.onClick ToggleShowPrivateKey ]
                            [ togglePrivateKeyIcon ]
                        , Form.viewInputError i model.privateKeyInput
                        , Html.div [] [ Html.text <| i "PRIVATE_KEY_NOTICE" ]
                        ]
                    ]
                , Html.button [] [ Html.text <| i "LOGIN" ]
                ]
            ]
        , Html.a [ Html.Attributes.href "/register" ] [ Html.text <| i "REGISTER_NEW" ]
        ]


update : Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update msg model =
    case msg of
        WithUsername event ->
            ( { model | usernameInput = Form.updateInput event plainParser model.usernameInput }
            , Effect.none
            , Cmd.none
            )

        WithPrivateKey event ->
            ( { model | privateKeyInput = Form.updateInput event plainParser model.privateKeyInput }
            , Effect.none
            , Cmd.none
            )

        ToggleShowPrivateKey ->
            ( { model | showPrivateKey = not model.showPrivateKey }
            , Effect.none
            , Cmd.none
            )

        Submit ->
            -- let
            --     requestChallenge : ConcurrentTask.ConcurrentTask TaskError String
            --     requestChallenge =
            --         ConcurrentTask.Http.post
            --             { url = "/api/users/request_login"
            --             , headers = []
            --             , body = ConcurrentTask.Http.stringBody "text/plain" model.usernameInput.raw
            --             , expect = ConcurrentTask.Http.expectString
            --             , timeout = Nothing
            --             }
            --             |> ConcurrentTask.mapError taskErrorMapper
            --     decryptChallenge : String -> ConcurrentTask.ConcurrentTask TaskError Json.Decode.Value
            --     decryptChallenge challengeEncrypted =
            --         ConcurrentTask.define
            --             { function = "login:decryptChallenge"
            --             , expect = ConcurrentTask.expectJson Json.Decode.value
            --             , errors = ConcurrentTask.expectErrors Json.Decode.string
            --             , args =
            --                 encodeChallengeEncryptedWithLoginData
            --                     challengeEncrypted
            --                     model.usernameInput.raw
            --                     model.privateKeyInput.raw
            --             }
            --             |> ConcurrentTask.mapError Generic
            --     requestToken : Json.Decode.Value -> ConcurrentTask.ConcurrentTask TaskError String
            --     requestToken value =
            --         ConcurrentTask.Http.post
            --             { url = "/api/users/login"
            --             , headers = []
            --             , body = ConcurrentTask.Http.jsonBody value
            --             , expect = ConcurrentTask.Http.expectString
            --             , timeout = Nothing
            --             }
            --             |> ConcurrentTask.mapError taskErrorMapper
            --     makeUser : String -> ConcurrentTask.ConcurrentTask TaskError PartialUser
            --     makeUser token =
            --         ConcurrentTask.define
            --             { function = "login:decryptChallenge"
            --             , expect = ConcurrentTask.expectJson Json.Decode.value
            --             , errors = ConcurrentTask.expectErrors Json.Decode.string
            --             , args =
            --                 encodeChallengeEncryptedWithLoginData
            --                     challengeEncrypted
            --                     model.usernameInput.raw
            --                     model.privateKeyInput.raw
            --             }
            --             |> ConcurrentTask.mapError Generic
            --     loginTask =
            --         requestChallenge
            --             |> ConcurrentTask.andThen decryptChallenge
            --             |> ConcurrentTask.andThen login
            -- in
            ( model, Effect.none, Cmd.none )

        _ ->
            ( model, Effect.none, Cmd.none )



-- type alias PartialUser =
--     { privateKeyObj : Json.Decode.Value
--     , token : String
--     }
-- if validInputs model then
--     ( model
--     , Effect.none
--     , Api.post
--         { url = "/api/users/login_request"
--         , body = Http.stringBody "text/plain" model.usernameInput.raw
--         , decoder = Json.Decode.decodeString decodeLoginRequest
--         }
--         |> Task.attempt GotLoginRequest
--     )
-- else
--     ( model
--     , Effect.addAlert (Alert.new Alert.Warning "Please, fill both fields before submiting.")
--     , Cmd.none
--     )
-- GotLoginRequest result ->
--     case result of
--         Err errorMsg ->
--             ( model
--             , Effect.addAlert (Alert.new Alert.Error errorMsg)
--             , Cmd.none
--             )
--         Ok loginRequest ->
--             ( model
--             , Effect.none
--             , Port.sendLoginRequest <| encodeLoginRequestWithPrivateKey loginRequest model.privateKeyInput.raw
--             )
-- GotLoginChallenge raw ->
--     ( model
--     , Effect.none
--     , Api.post
--         { url = "/api/users/login"
--         , body = Http.jsonBody raw
--         , decoder = identity >> Ok
--         }
--         |> Task.attempt GotLogin
--     )
-- GotLogin result ->
--     case result of
--         Ok token ->
--             ( model
--             , Effect.batch
--                 [ Effect.login model.usernameInput.raw
--                 , Effect.redirect "/posts"
--                 ]
--             , Port.sendToken <| encodeTokenAndPrivateKey model.privateKeyInput.raw token
--             )
--         Err errorMsg ->
--             ( model
--             , Effect.addAlert (Alert.new Alert.Error errorMsg)
--             , Cmd.none
--             )


taskErrorMapper : ConcurrentTask.Http.Error -> TaskError
taskErrorMapper error =
    case error of
        ConcurrentTask.Http.BadStatus meta value ->
            if List.member meta.statusCode [ 400, 500 ] then
                value
                    |> Json.Decode.decodeValue Json.Decode.string
                    |> Result.toMaybe
                    |> Maybe.withDefault "Unknown error"
                    |> Generic

            else
                RequestError error

        _ ->
            RequestError error


encodeTokenAndPrivateKey : String -> String -> Json.Encode.Value
encodeTokenAndPrivateKey privateKey token =
    Json.Encode.object
        [ ( "privateKey", Json.Encode.string privateKey )
        , ( "token", Json.Encode.string token )
        ]


decodeLoginChallenge : Json.Decode.Decoder LoginChallenge
decodeLoginChallenge =
    Json.Decode.map2 LoginChallenge
        (Json.Decode.field "username" Json.Decode.string)
        (Json.Decode.field "challenge_encrypted" Json.Decode.string)


encodeChallengeEncryptedWithLoginData : String -> String -> String -> Json.Encode.Value
encodeChallengeEncryptedWithLoginData challengeEncrypted username privateKey =
    Json.Encode.object
        [ ( "username", Json.Encode.string username )
        , ( "privateKey", Json.Encode.string privateKey )
        , ( "challengeEncrypted", Json.Encode.string challengeEncrypted )
        ]


type alias UserData =
    { username : String
    , privateKey : String
    }


buildUserData : Model -> Result String UserData
buildUserData model =
    case ( model.usernameInput.valid, model.privateKeyInput.valid ) of
        ( Form.Valid username, Form.Valid privateKey ) ->
            Ok { username = username, privateKey = privateKey }

        _ ->
            Err "INVALID_INPUTS"


plainParser : String -> Result String String
plainParser value =
    let
        parsedValue =
            String.trim value
    in
    if parsedValue == "" then
        Err "INPUT_EMPTY"

    else
        Ok parsedValue


subscriptions : Sub Msg
subscriptions =
    Sub.none
