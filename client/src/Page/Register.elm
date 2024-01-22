module Page.Register exposing
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
import Business.PrivateKey
import Business.User
import Business.Username
import ConcurrentTask
import ConcurrentTask.Http
import ConcurrentTask.Http.Extra
import Context
import Css
import Effect
import Form
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Json.Decode
import Json.Encode
import Logger
import Page
import Port
import Translations
import View.Access.Form
import View.Logo
import View.Style
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


update : Translations.Helper -> Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update i msg model =
    case msg of
        WithUsername event ->
            ( { model
                | usernameInput =
                    Form.updateInput
                        event
                        Business.Username.fromString
                        model.usernameInput
              }
            , Effect.none
            , Cmd.none
            )

        WithPrivateKey event ->
            ( { model
                | privateKeyInput =
                    Form.updateInput
                        event
                        Business.PrivateKey.fromString
                        model.privateKeyInput
              }
            , Effect.none
            , Cmd.none
            )

        ToggleShowPrivateKey ->
            ( { model | showPrivateKey = not model.showPrivateKey }, Effect.none, Cmd.none )

        Submit ->
            let
                newModel : Model
                newModel =
                    { model
                        | usernameInput = Form.parseInput Business.Username.fromString model.usernameInput
                        , privateKeyInput = Form.parseInput Business.PrivateKey.fromString model.privateKeyInput
                    }
            in
            case Business.User.buildUserData newModel.usernameInput newModel.privateKeyInput of
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
                                |> ConcurrentTask.mapError (Translations.keyFromString >> Page.Generic)

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
                    , Effect.addAlert (Alert.new Alert.Error <| i errorKey)
                    , Cmd.none
                    )

        OnTaskProgress ( tasks, cmd ) ->
            ( { model | tasks = tasks }, Effect.none, cmd )

        OnTaskComplete (ConcurrentTask.Success (Register ())) ->
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Success <| i Translations.RegisterSuccess)
                , Effect.redirect "/"
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Error (Page.Generic errorKey)) ->
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i errorKey)
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Error (Page.RequestError httpError)) ->
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i Translations.RequestError)
                , Effect.toggleLoader
                ]
            , Logger.captureMessage <| ConcurrentTask.Http.Extra.errorToString httpError
            )

        OnTaskComplete (ConcurrentTask.UnexpectedError _) ->
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i Translations.RequestError)
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


view : Translations.Helper -> Context.Context -> Model -> Html.Html Msg
view i context model =
    Html.div [ HtmlAttributes.css [ Css.maxWidth <| Css.px 300, Css.width <| Css.pct 100 ] ]
        [ Html.div [ HtmlAttributes.css [ View.Style.logo ] ]
            [ View.Logo.logo 60 <| View.Theme.foregroundColor context.theme ]
        , View.Access.Form.form i
            context.theme
            model.showPrivateKey
            Translations.Register
            { submit = Submit
            , username = WithUsername
            , privateKey = WithPrivateKey
            , togglePrivateKey = ToggleShowPrivateKey
            }
            model.usernameInput
            model.privateKeyInput
        , Html.a
            [ HtmlAttributes.href "/"
            , HtmlAttributes.css
                [ View.Style.btn context.theme
                , View.Style.btnFull
                , View.Style.btnInverse context.theme
                ]
            ]
            [ Html.text <| i Translations.Login ]
        ]
