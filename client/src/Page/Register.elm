module Page.Register exposing
    ( Model
    , Msg
    , TaskOutput
    , TaskPool
    , UserData
    , init
    , subscriptions
    , update
    , view
    )

import Alert
import Business.PrivateKey
import Business.Username
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
    = Register ()


type alias TaskPool =
    ConcurrentTask.Pool Msg Page.TaskError TaskOutput


type Msg
    = WithUsername Form.InputEvent
    | WithPrivateKey Form.InputEvent
    | ToggleShowPrivateKey
    | Submit
    | OnTaskProgress ( TaskPool, Cmd Msg )
    | OnTaskComplete (ConcurrentTask.Response Page.TaskError TaskOutput)


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


init : ( Model, Effect.Effect, Cmd Msg )
init =
    ( initModel, Effect.none, Cmd.none )


update : Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update msg model =
    case msg of
        WithUsername event ->
            Page.done
                { model
                    | usernameInput =
                        Form.updateInput
                            event
                            Business.Username.fromString
                            model.usernameInput
                }

        WithPrivateKey event ->
            Page.done
                { model
                    | privateKeyInput =
                        Form.updateInput
                            event
                            Business.PrivateKey.fromString
                            model.privateKeyInput
                }

        ToggleShowPrivateKey ->
            Page.done { model | showPrivateKey = not model.showPrivateKey }

        Submit ->
            let
                newModel : Model
                newModel =
                    { model
                        | usernameInput = Form.parseInput Business.Username.fromString model.usernameInput
                        , privateKeyInput = Form.parseInput Business.PrivateKey.fromString model.privateKeyInput
                    }
            in
            case buildUserData newModel of
                Ok userData ->
                    let
                        requestAccess : ConcurrentTask.ConcurrentTask Page.TaskError Challenge
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
                                |> ConcurrentTask.mapError Page.httpErrorMapper

                        encryptChallenge : Challenge -> ConcurrentTask.ConcurrentTask Page.TaskError Json.Decode.Value
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
                                |> ConcurrentTask.mapError Page.Generic

                        createUser : Json.Decode.Value -> ConcurrentTask.ConcurrentTask Page.TaskError ()
                        createUser value =
                            ConcurrentTask.Http.post
                                { url = "/api/users/create_user"
                                , headers = []
                                , body = ConcurrentTask.Http.jsonBody value
                                , expect = ConcurrentTask.Http.expectWhatever
                                , timeout = Nothing
                                }
                                |> ConcurrentTask.mapError Page.httpErrorMapper

                        registrationTask : ConcurrentTask.ConcurrentTask Page.TaskError TaskOutput
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
                    ( { newModel | tasks = tasks }, Effect.toggleLoader, cmd )

                Err errorKey ->
                    ( newModel
                    , Effect.addAlert (Alert.new Alert.Error errorKey)
                    , Cmd.none
                    )

        OnTaskProgress ( tasks, cmd ) ->
            ( { model | tasks = tasks }, Effect.none, cmd )

        OnTaskComplete (ConcurrentTask.Success (Register ())) ->
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Success "REGISTER_SUCCESS")
                , Effect.redirect "/"
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
    case ( usernameInput.valid, privateKeyInput.valid ) of
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
        , Html.form [ Html.Events.onSubmit Submit, Html.Attributes.class "access__form" ]
            [ Html.fieldset []
                [ Html.legend [] [ Html.text <| i "REGISTER" ]
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
                , Html.button [ Html.Attributes.class "btn btn--full" ] [ Html.text <| i "REGISTER" ]
                ]
            ]
        , Html.a [ Html.Attributes.href "/", Html.Attributes.class "btn btn--full btn--inverse" ] [ Html.text <| i "LOGIN" ]
        ]
