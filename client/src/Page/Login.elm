module Page.Login exposing
    ( Model
    , Msg
    , TaskOutput
    , TaskPool
    , init
    , subscriptions
    , update
    , view
    )

import Alert
import Business.User
import ConcurrentTask
import ConcurrentTask.Http
import Context
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
import View.Logo
import View.Theme


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


init : ( Model, Effect.Effect, Cmd Msg )
init =
    ( initModel, Effect.none, Cmd.none )


update : Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update msg model =
    case msg of
        WithUsername event ->
            Page.done { model | usernameInput = Form.updateInput event Page.nonEmptyInputParser model.usernameInput }

        WithPrivateKey event ->
            Page.done { model | privateKeyInput = Form.updateInput event Page.nonEmptyInputParser model.privateKeyInput }

        ToggleShowPrivateKey ->
            Page.done { model | showPrivateKey = not model.showPrivateKey }

        Submit ->
            let
                newModel : Model
                newModel =
                    { model
                        | usernameInput = Form.parseInput Page.nonEmptyInputParser model.usernameInput
                        , privateKeyInput = Form.parseInput Page.nonEmptyInputParser model.privateKeyInput
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
                    ( { newModel | tasks = tasks }, Effect.toggleLoader, cmd )

                Err errorKey ->
                    ( newModel
                    , Effect.addAlert (Alert.new Alert.Error errorKey)
                    , Cmd.none
                    )

        OnTaskProgress ( tasks, cmd ) ->
            ( { model | tasks = tasks }, Effect.none, cmd )

        OnTaskComplete (ConcurrentTask.Success (Login user)) ->
            ( model
            , Effect.batch
                [ Effect.login user
                , Effect.redirect "/posts"
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Error (Page.Generic errorMsgKey)) ->
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error errorMsgKey)
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Error (Page.RequestError _)) ->
            -- TODO: send error to monitoring tool
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error "REQUEST_ERROR")
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.UnexpectedError _) ->
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error "REQUEST_ERROR")
                , Effect.toggleLoader
                ]
            , Cmd.none
            )


buildUserData : Model -> Result String UserData
buildUserData model =
    case ( model.usernameInput.valid, model.privateKeyInput.valid ) of
        ( Form.Valid username, Form.Valid privateKey ) ->
            Ok { username = username, privateKey = privateKey }

        _ ->
            Err "INVALID_INPUTS"


view : (String -> String) -> Context.Context -> Model -> Html.Html Msg
view i context model =
    let
        ( privateKeyInputType, togglePrivateKeyIcon ) =
            if model.showPrivateKey then
                ( "text", Phosphor.eyeClosed Phosphor.Regular |> Phosphor.toHtml [] )

            else
                ( "password", Phosphor.eye Phosphor.Regular |> Phosphor.toHtml [] )
    in
    Html.div [ Html.Attributes.class "access" ]
        [ Html.div [ Html.Attributes.class "access__logo" ]
            [ View.Logo.logo 60 <| View.Theme.foregroundColor context.theme ]
        , Html.div [ Html.Attributes.class "capsulen-tagline" ] [ Html.text <| i "TAGLINE" ]
        , Html.form [ Html.Events.onSubmit Submit, Html.Attributes.class "access__form" ]
            [ Html.fieldset []
                [ Html.legend [] [ Html.text <| i "LOGIN" ]
                , Html.div [ Html.Attributes.class "access__input" ]
                    [ Html.label [ Html.Attributes.for "username" ] [ Html.text <| i "USERNAME" ]
                    , Html.input
                        ([ Html.Attributes.type_ "text"
                         , Html.Attributes.name "username"
                         , Html.Attributes.id "username"
                         , Html.Attributes.value model.usernameInput.raw
                         ]
                            ++ Form.inputEvents WithUsername
                        )
                        []
                    , Form.viewInputError i model.usernameInput
                    ]
                , Html.div [ Html.Attributes.class "access__input" ]
                    [ Html.label [ Html.Attributes.for "privateKey" ] [ Html.text <| i "PRIVATE_KEY" ]
                    , Html.input
                        ([ Html.Attributes.type_ privateKeyInputType
                         , Html.Attributes.name "privateKey"
                         , Html.Attributes.id "privateKey"
                         , Html.Attributes.value model.privateKeyInput.raw
                         ]
                            ++ Form.inputEvents WithPrivateKey
                        )
                        []
                    , Html.button
                        [ Html.Attributes.type_ "button"
                        , Html.Events.onClick ToggleShowPrivateKey
                        , Html.Attributes.class "btn btn--left-flat private-key-toggle"
                        ]
                        [ togglePrivateKeyIcon ]
                    , Form.viewInputError i model.privateKeyInput
                    ]
                , Html.div [ Html.Attributes.class "notice" ] [ Html.text <| i "PRIVATE_KEY_NOTICE" ]
                , Html.button [ Html.Attributes.class "btn btn--full" ] [ Html.text <| i "LOGIN" ]
                ]
            ]
        , Html.a [ Html.Attributes.href "/register", Html.Attributes.class "btn btn--full btn--inverse" ] [ Html.text <| i "REGISTER_NEW" ]
        ]


subscriptions : TaskPool -> Sub Msg
subscriptions pool =
    ConcurrentTask.onProgress
        { send = Port.taskSend
        , receive = Port.taskReceive
        , onProgress = OnTaskProgress
        }
        pool
