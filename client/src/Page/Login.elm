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
import Business.PrivateKey
import Business.User
import Business.Username
import ConcurrentTask
import ConcurrentTask.Http
import Context
import Css
import Effect
import Form
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Json.Decode
import Json.Encode
import Page
import Port
import Translations
import View.Access.Form
import View.Color
import View.Logo
import View.Style
import View.Theme


type TaskOutput
    = Login Business.User.User


type alias TaskPool =
    ConcurrentTask.Pool Msg Page.TaskError TaskOutput


type alias Model =
    { tasks : TaskPool
    , usernameInput : Form.Input Business.Username.Username
    , privateKeyInput : Form.Input Business.PrivateKey.PrivateKey
    , showPrivateKey : Bool
    }


type Msg
    = WithUsername Form.InputEvent
    | WithPrivateKey Form.InputEvent
    | ToggleShowPrivateKey
    | Submit
    | OnTaskProgress ( TaskPool, Cmd Msg )
    | OnTaskComplete (ConcurrentTask.Response Page.TaskError TaskOutput)


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
            Page.done { model | usernameInput = Form.updateInput event Business.Username.fromString model.usernameInput }

        WithPrivateKey event ->
            Page.done { model | privateKeyInput = Form.updateInput event Business.PrivateKey.fromString model.privateKeyInput }

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
            case Business.User.buildUserData newModel.usernameInput newModel.privateKeyInput of
                Ok userData ->
                    let
                        requestChallengeEncrypted : ConcurrentTask.ConcurrentTask Page.TaskError String
                        requestChallengeEncrypted =
                            ConcurrentTask.Http.post
                                { url = "/api/users/request_login"
                                , headers = []
                                , body = ConcurrentTask.Http.stringBody "text/plain" <| Business.Username.toString userData.username
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
                                        [ ( "username", Business.Username.encode userData.username )
                                        , ( "privateKey", Business.PrivateKey.encode userData.privateKey )
                                        , ( "challengeEncrypted", Json.Encode.string challengeEncrypted )
                                        ]
                                }
                                |> ConcurrentTask.mapError (Translations.keyFromString >> Page.Generic)

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
                                        [ ( "username", Business.Username.encode userData.username )
                                        , ( "privateKey", Business.PrivateKey.encode userData.privateKey )
                                        , ( "token", Json.Encode.string token )
                                        ]
                                }
                                |> ConcurrentTask.mapError (Translations.keyFromString >> Page.Generic)

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

        OnTaskComplete (ConcurrentTask.Error (Page.RequestError _)) ->
            -- TODO: send error to monitoring tool
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i Translations.RequestError)
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.UnexpectedError _) ->
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i Translations.RequestError)
                , Effect.toggleLoader
                ]
            , Cmd.none
            )


view : Translations.Helper -> Context.Context -> Model -> Html.Html Msg
view i context model =
    Html.div [ HtmlAttributes.css [ Css.maxWidth <| Css.px 300, Css.width <| Css.pct 100 ] ]
        [ Html.div [ HtmlAttributes.css [ View.Style.logo ] ]
            [ View.Logo.logo 60 <| View.Theme.foregroundColor context.theme ]
        , Html.div
            [ HtmlAttributes.css
                [ Css.color (context.theme |> View.Theme.foregroundColor |> View.Color.toCss)
                , Css.fontWeight Css.bold
                , Css.marginBottom <| Css.rem 3
                , Css.textAlign Css.center
                ]
            ]
            [ Html.text <| i Translations.Tagline ]
        , View.Access.Form.form i
            context.theme
            model.showPrivateKey
            Translations.Login
            { submit = Submit
            , username = WithUsername
            , privateKey = WithPrivateKey
            , togglePrivateKey = ToggleShowPrivateKey
            }
            model.usernameInput
            model.privateKeyInput
        , Html.a
            [ HtmlAttributes.href "/register"
            , HtmlAttributes.css
                [ View.Style.btn context.theme
                , View.Style.btnFull
                , View.Style.btnInverse context.theme
                ]
            ]
            [ Html.text <| i Translations.RegisterNew ]
        ]


subscriptions : TaskPool -> Sub Msg
subscriptions pool =
    ConcurrentTask.onProgress
        { send = Port.taskSend
        , receive = Port.taskReceive
        , onProgress = OnTaskProgress
        }
        pool
