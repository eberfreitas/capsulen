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
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Html.Styled.Events as HtmlEvents
import Json.Decode
import Json.Encode
import Page
import Phosphor
import Port
import Translations
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


update : Translations.Helper -> Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update i msg model =
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
                    , Effect.addAlert (Alert.new Alert.Error (errorKey |> Translations.keyFromString |> i))
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
                [ Effect.addAlert (Alert.new Alert.Error (errorKey |> Translations.keyFromString |> i))
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


buildUserData : Model -> Result String UserData
buildUserData model =
    case ( model.usernameInput.valid, model.privateKeyInput.valid ) of
        ( Form.Valid username, Form.Valid privateKey ) ->
            Ok { username = username, privateKey = privateKey }

        _ ->
            Err "INVALID_INPUTS"


view : Translations.Helper -> Context.Context -> Model -> Html.Html Msg
view i context model =
    let
        ( privateKeyInputType, togglePrivateKeyIcon ) =
            if model.showPrivateKey then
                ( "text", Phosphor.eyeClosed Phosphor.Regular |> Phosphor.toHtml [] |> Html.fromUnstyled )

            else
                ( "password", Phosphor.eye Phosphor.Regular |> Phosphor.toHtml [] |> Html.fromUnstyled )
    in
    Html.div [ HtmlAttributes.class "access" ]
        [ Html.div [ HtmlAttributes.class "access__logo" ]
            [ View.Logo.logo 60 <| View.Theme.foregroundColor context.theme ]
        , Html.div [ HtmlAttributes.class "capsulen-tagline" ] [ Html.text <| i Translations.Tagline ]
        , Html.form [ HtmlEvents.onSubmit Submit, HtmlAttributes.class "access__form" ]
            [ Html.fieldset []
                [ Html.legend [] [ Html.text <| i Translations.Login ]
                , Html.div [ HtmlAttributes.class "access__input" ]
                    [ Html.label [ HtmlAttributes.for "username" ] [ Html.text <| i Translations.Username ]
                    , Html.input
                        ([ HtmlAttributes.type_ "text"
                         , HtmlAttributes.name "username"
                         , HtmlAttributes.id "username"
                         , HtmlAttributes.value model.usernameInput.raw
                         ]
                            ++ Form.inputEvents WithUsername
                        )
                        []
                    , Form.viewInputError i model.usernameInput
                    ]
                , Html.div [ HtmlAttributes.class "access__input" ]
                    [ Html.label [ HtmlAttributes.for "privateKey" ] [ Html.text <| i Translations.PrivateKey ]
                    , Html.input
                        ([ HtmlAttributes.type_ privateKeyInputType
                         , HtmlAttributes.name "privateKey"
                         , HtmlAttributes.id "privateKey"
                         , HtmlAttributes.value model.privateKeyInput.raw
                         ]
                            ++ Form.inputEvents WithPrivateKey
                        )
                        []
                    , Html.button
                        [ HtmlAttributes.type_ "button"
                        , HtmlEvents.onClick ToggleShowPrivateKey
                        , HtmlAttributes.class "btn btn--left-flat private-key-toggle"
                        ]
                        [ togglePrivateKeyIcon ]
                    , Form.viewInputError i model.privateKeyInput
                    ]
                , Html.div [ HtmlAttributes.class "notice" ] [ Html.text <| i Translations.PrivateKeyNotice ]
                , Html.button [ HtmlAttributes.class "btn btn--full" ] [ Html.text <| i Translations.Login ]
                ]
            ]
        , Html.a [ HtmlAttributes.href "/register", HtmlAttributes.class "btn btn--full btn--inverse" ] [ Html.text <| i Translations.RegisterNew ]
        ]


subscriptions : TaskPool -> Sub Msg
subscriptions pool =
    ConcurrentTask.onProgress
        { send = Port.taskSend
        , receive = Port.taskReceive
        , onProgress = OnTaskProgress
        }
        pool
