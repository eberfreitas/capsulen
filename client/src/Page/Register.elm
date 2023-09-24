module Page.Register exposing (Model, Msg, UserData, init, subscriptions, update, view)

import Alert
import Business.PrivateKey
import Business.Username
import ConcurrentTask
import ConcurrentTask.Http
import Effect
import Form
import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Encode
import Phosphor
import Port


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
    | OnTaskProgress ( TaskPool, Cmd Msg )
    | OnTaskComplete (ConcurrentTask.Response TaskError TaskOutput)


type alias Model =
    { tasks : TaskPool
    , usernameInput : Form.Input Business.Username.Username
    , privateKeyInput : Form.Input Business.PrivateKey.PrivateKey
    , showPrivateKey : Bool
    }


type alias Challenge =
    { nonce : String
    , challenge : String
    }


type alias UserData =
    { username : Business.Username.Username
    , privateKey : Business.PrivateKey.PrivateKey
    }


initModel : Model
initModel =
    { tasks = ConcurrentTask.pool
    , usernameInput = Form.newInput
    , privateKeyInput = Form.newInput
    , showPrivateKey = False
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )


update : (String -> String) -> Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update i msg model =
    let
        done : Model -> ( Model, Effect.Effect, Cmd Msg )
        done model_ =
            ( model_, Effect.none, Cmd.none )
    in
    case msg of
        WithUsername event ->
            done
                { model
                    | usernameInput =
                        Form.updateInput
                            event
                            Business.Username.fromString
                            model.usernameInput
                }

        WithPrivateKey event ->
            done
                { model
                    | privateKeyInput =
                        Form.updateInput
                            event
                            Business.PrivateKey.fromString
                            model.privateKeyInput
                }

        ToggleShowPrivateKey ->
            done { model | showPrivateKey = not model.showPrivateKey }

        Submit ->
            let
                newModel =
                    { model
                        | usernameInput = Form.parseInput Business.Username.fromString model.usernameInput
                        , privateKeyInput = Form.parseInput Business.PrivateKey.fromString model.privateKeyInput
                    }
            in
            case buildUserData newModel of
                Ok userData ->
                    let
                        requestAccess : ConcurrentTask.ConcurrentTask TaskError Challenge
                        requestAccess =
                            ConcurrentTask.Http.post
                                { url = "/api/users/request_access"
                                , headers = []
                                , body =
                                    ConcurrentTask.Http.stringBody "text/plain" <|
                                        Business.Username.toString userData.username
                                , expect =
                                    ConcurrentTask.Http.expectJson
                                        (Json.Decode.map2 Challenge
                                            (Json.Decode.field "nonce" Json.Decode.string)
                                            (Json.Decode.field "challenge" Json.Decode.string)
                                        )
                                , timeout = Nothing
                                }
                                |> ConcurrentTask.mapError taskErrorMapper

                        encryptChallenge : Challenge -> ConcurrentTask.ConcurrentTask TaskError Json.Decode.Value
                        encryptChallenge challenge =
                            ConcurrentTask.define
                                { function = "register:encryptChallenge"
                                , expect = ConcurrentTask.expectJson Json.Decode.value
                                , errors = ConcurrentTask.expectErrors Json.Decode.string
                                , args =
                                    Json.Encode.object
                                        [ ( "username", Business.Username.encode userData.username )
                                        , ( "privateKey", Business.PrivateKey.encode userData.privateKey )
                                        , ( "nonce", Json.Encode.string challenge.nonce )
                                        , ( "challenge", Json.Encode.string challenge.challenge )
                                        ]
                                }
                                |> ConcurrentTask.mapError Generic

                        createUser : Json.Decode.Value -> ConcurrentTask.ConcurrentTask TaskError ()
                        createUser value =
                            ConcurrentTask.Http.post
                                { url = "/api/users/create_user"
                                , headers = []
                                , body = ConcurrentTask.Http.jsonBody value
                                , expect = ConcurrentTask.Http.expectWhatever
                                , timeout = Nothing
                                }
                                |> ConcurrentTask.mapError taskErrorMapper

                        registrationTask : ConcurrentTask.ConcurrentTask TaskError TaskOutput
                        registrationTask =
                            requestAccess
                                |> ConcurrentTask.andThen encryptChallenge
                                |> ConcurrentTask.andThen createUser
                                |> ConcurrentTask.map Register

                        ( tasks, cmd ) =
                            ConcurrentTask.attempt
                                { send = Port.taskSend
                                , pool = model.tasks
                                , onComplete = OnTaskComplete
                                }
                                registrationTask
                    in
                    -- TODO: Use loader effect here, to show fake progress bar
                    ( { newModel | tasks = tasks }, Effect.none, cmd )

                Err errorKey ->
                    ( newModel
                    , Effect.addAlert (Alert.new Alert.Error <| i errorKey)
                    , Cmd.none
                    )

        OnTaskProgress ( tasks, cmd ) ->
            ( { model | tasks = tasks }, Effect.none, cmd )

        OnTaskComplete (ConcurrentTask.Success (Register ())) ->
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Success <| i "REGISTER_SUCCESS")
                , Effect.redirect "/"
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Error (Generic errorMsgKey)) ->
            ( model, Effect.addAlert (Alert.new Alert.Error <| i errorMsgKey), Cmd.none )

        OnTaskComplete (ConcurrentTask.Error (RequestError _)) ->
            -- TODO: send error to monitoring tool
            ( model, Effect.addAlert (Alert.new Alert.Error <| i "REQUEST_ERROR"), Cmd.none )

        OnTaskComplete (ConcurrentTask.UnexpectedError _) ->
            ( model, Effect.addAlert (Alert.new Alert.Error <| i "REQUEST_ERROR"), Cmd.none )


taskErrorMapper : ConcurrentTask.Http.Error -> TaskError
taskErrorMapper error =
    case error of
        ConcurrentTask.Http.BadStatus meta value ->
            if List.member meta.statusCode [ 400, 500 ] then
                value
                    |> Json.Decode.decodeValue Json.Decode.string
                    |> Result.toMaybe
                    |> Maybe.withDefault "UNKNOWN_ERROR"
                    |> Generic

            else
                RequestError error

        _ ->
            RequestError error


subscriptions : TaskPool -> Sub Msg
subscriptions pool =
    ConcurrentTask.onProgress
        { send = Port.taskSend
        , receive = Port.taskReceive
        , onProgress = OnTaskProgress
        }
        pool


buildUserData : Model -> Result String UserData
buildUserData { usernameInput, privateKeyInput } =
    let
        errorMsgKey : String
        errorMsgKey =
            "INVALID_INPUTS"
    in
    case ( usernameInput.valid, privateKeyInput.valid ) of
        ( Form.Valid username, Form.Valid privateKey ) ->
            Ok { username = username, privateKey = privateKey }

        _ ->
            Err errorMsgKey


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
                [ Html.legend [] [ Html.text <| i "REGISTER" ]
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
                , Html.button [] [ Html.text <| i "REGISTER" ]
                ]
            ]
        , Html.a [ Html.Attributes.href "/" ] [ Html.text <| i "LOGIN" ]
        ]
