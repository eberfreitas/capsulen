module Page.Login exposing (Model, Msg, init, subscriptions, update, view)

import Alert
import Business.User
import ConcurrentTask
import ConcurrentTask.Http
import Effect
import Form
import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Encode
import Page
import Phosphor
import Port


type TaskOutput
    = Login Business.User.User


type alias TaskPool =
    ConcurrentTask.Pool Msg Page.TaskError TaskOutput


type alias Model =
    { tasks : TaskPool
    , usernameInput : Form.Input String
    , privateKeyInput : Form.Input String
    , showPrivateKey : Bool
    }


type Msg
    = WithUsername Form.InputEvent
    | WithPrivateKey Form.InputEvent
    | ToggleShowPrivateKey
    | Submit
    | OnTaskProgress ( TaskPool, Cmd Msg )
    | OnTaskComplete (ConcurrentTask.Response Page.TaskError TaskOutput)


type alias UserData =
    { username : String
    , privateKey : String
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
    case msg of
        WithUsername event ->
            Page.done { model | usernameInput = Form.updateInput event plainParser model.usernameInput }

        WithPrivateKey event ->
            Page.done { model | privateKeyInput = Form.updateInput event plainParser model.privateKeyInput }

        ToggleShowPrivateKey ->
            Page.done { model | showPrivateKey = not model.showPrivateKey }

        Submit ->
            let
                newModel =
                    { model
                        | usernameInput = Form.parseInput plainParser model.usernameInput
                        , privateKeyInput = Form.parseInput plainParser model.privateKeyInput
                    }
            in
            case buildUserData newModel of
                Ok userData ->
                    let
                        requestChallengeEncrypted : ConcurrentTask.ConcurrentTask Page.TaskError String
                        requestChallengeEncrypted =
                            ConcurrentTask.Http.post
                                { url = "/api/users/request_login"
                                , headers = []
                                , body = ConcurrentTask.Http.stringBody "text/plain" userData.username
                                , expect = ConcurrentTask.Http.expectString
                                , timeout = Nothing
                                }
                                |> ConcurrentTask.mapError Page.httpErrorMapper

                        decryptChallenge : String -> ConcurrentTask.ConcurrentTask Page.TaskError Json.Decode.Value
                        decryptChallenge challengeEncrypted =
                            ConcurrentTask.define
                                { function = "login:decryptChallenge"
                                , expect = ConcurrentTask.expectJson Json.Decode.value
                                , errors = ConcurrentTask.expectErrors Json.Decode.string
                                , args =
                                    Json.Encode.object
                                        [ ( "username", Json.Encode.string userData.username )
                                        , ( "privateKey", Json.Encode.string userData.privateKey )
                                        , ( "challengeEncrypted", Json.Encode.string challengeEncrypted )
                                        ]
                                }
                                |> ConcurrentTask.mapError Page.Generic

                        requestToken : Json.Decode.Value -> ConcurrentTask.ConcurrentTask Page.TaskError String
                        requestToken challengeData =
                            ConcurrentTask.Http.post
                                { url = "/api/users/login"
                                , headers = []
                                , body = ConcurrentTask.Http.jsonBody challengeData
                                , expect = ConcurrentTask.Http.expectString
                                , timeout = Nothing
                                }
                                |> ConcurrentTask.mapError Page.httpErrorMapper

                        buildUser : String -> ConcurrentTask.ConcurrentTask Page.TaskError Business.User.User
                        buildUser token =
                            ConcurrentTask.define
                                { function = "login:buildUser"
                                , expect = ConcurrentTask.expectJson Business.User.decode
                                , errors = ConcurrentTask.expectErrors Json.Decode.string
                                , args =
                                    Json.Encode.object
                                        [ ( "username", Json.Encode.string userData.username )
                                        , ( "privateKey", Json.Encode.string userData.privateKey )
                                        , ( "token", Json.Encode.string token )
                                        ]
                                }
                                |> ConcurrentTask.mapError Page.Generic

                        loginTask : ConcurrentTask.ConcurrentTask Page.TaskError TaskOutput
                        loginTask =
                            requestChallengeEncrypted
                                |> ConcurrentTask.andThen decryptChallenge
                                |> ConcurrentTask.andThen requestToken
                                |> ConcurrentTask.andThen buildUser
                                |> ConcurrentTask.map Login

                        ( tasks, cmd ) =
                            ConcurrentTask.attempt
                                { pool = model.tasks
                                , send = Port.taskSend
                                , onComplete = OnTaskComplete
                                }
                                loginTask
                    in
                    ( { newModel | tasks = tasks }, Effect.none, cmd )

                Err errorKey ->
                    ( newModel
                    , Effect.addAlert (Alert.new Alert.Error <| i errorKey)
                    , Cmd.none
                    )

        OnTaskProgress ( tasks, cmd ) ->
            ( { model | tasks = tasks }, Effect.none, cmd )

        OnTaskComplete (ConcurrentTask.Success (Login user)) ->
            ( model
            , Effect.batch
                [ Effect.login user
                , Effect.redirect "/posts"
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Error (Page.Generic errorMsgKey)) ->
            ( model, Effect.addAlert (Alert.new Alert.Error <| i errorMsgKey), Cmd.none )

        OnTaskComplete (ConcurrentTask.Error (Page.RequestError _)) ->
            -- TODO: send error to monitoring tool
            ( model, Effect.addAlert (Alert.new Alert.Error <| i "REQUEST_ERROR"), Cmd.none )

        OnTaskComplete (ConcurrentTask.UnexpectedError _) ->
            ( model, Effect.addAlert (Alert.new Alert.Error <| i "REQUEST_ERROR"), Cmd.none )


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


subscriptions : TaskPool -> Sub Msg
subscriptions pool =
    ConcurrentTask.onProgress
        { send = Port.taskSend
        , receive = Port.taskReceive
        , onProgress = OnTaskProgress
        }
        pool
