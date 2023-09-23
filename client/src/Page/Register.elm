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
import Tasks


type Msg
    = WithUsername Form.InputEvent
    | WithPrivateKey Form.InputEvent
    | ToggleShowPrivateKey
    | Submit
    | TaskOnComplete (Result Tasks.Error Tasks.Output)


type alias Challenge =
    { nonce : String
    , challenge : String
    }


type alias Model =
    { taskOnCompleteMsg : Result Tasks.Error Tasks.Output -> Msg
    , usernameInput : Form.Input Business.Username.Username
    , privateKeyInput : Form.Input Business.PrivateKey.PrivateKey
    , showPrivateKey : Bool
    }


type alias UserData =
    { username : Business.Username.Username
    , privateKey : Business.PrivateKey.PrivateKey
    }


baseModel : Model
baseModel =
    { taskOnCompleteMsg = TaskOnComplete
    , usernameInput = Form.newInput
    , privateKeyInput = Form.newInput
    , showPrivateKey = False
    }


init : ( Model, Cmd Msg )
init =
    ( baseModel, Cmd.none )


update : Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update msg model =
    let
        done : Model -> ( Model, Effect.Effect, Cmd Msg )
        done model_ =
            ( model_, Effect.none, Cmd.none )
    in
    case msg of
        WithUsername event ->
            done { model | usernameInput = updateUsername event model.usernameInput }

        WithPrivateKey event ->
            done { model | privateKeyInput = updatePrivateKey event model.privateKeyInput }

        ToggleShowPrivateKey ->
            done { model | showPrivateKey = not model.showPrivateKey }

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
                        requestAccess : ConcurrentTask.ConcurrentTask Tasks.Error Challenge
                        requestAccess =
                            ConcurrentTask.Http.post
                                { url = "/api/users/request_access"
                                , headers = []
                                , body = ConcurrentTask.Http.stringBody "text/plain" <| Business.Username.toString userData.username
                                , expect = ConcurrentTask.Http.expectJson decodeChallenge
                                , timeout = Nothing
                                }
                                |> ConcurrentTask.mapError taskErrorMapper

                        encryptChallenge : Challenge -> ConcurrentTask.ConcurrentTask Tasks.Error Json.Decode.Value
                        encryptChallenge challenge =
                            ConcurrentTask.define
                                { function = "register:encryptChallenge"
                                , expect = ConcurrentTask.expectJson Json.Decode.value
                                , errors = ConcurrentTask.expectErrors Json.Decode.string
                                , args = encodeChallengeWithUserData challenge userData
                                }
                                |> ConcurrentTask.mapError Tasks.RegisterError

                        createUser : Json.Decode.Value -> ConcurrentTask.ConcurrentTask Tasks.Error ()
                        createUser value =
                            ConcurrentTask.Http.post
                                { url = "/api/users/create_user"
                                , headers = []
                                , body = ConcurrentTask.Http.jsonBody value
                                , expect = ConcurrentTask.Http.expectWhatever
                                , timeout = Nothing
                                }
                                |> ConcurrentTask.mapError taskErrorMapper

                        registrationTask : ConcurrentTask.ConcurrentTask Tasks.Error Tasks.Output
                        registrationTask =
                            requestAccess
                                |> ConcurrentTask.andThen encryptChallenge
                                |> ConcurrentTask.andThen createUser
                                |> ConcurrentTask.map Tasks.Register
                    in
                    -- TODO: Use loader effect here, to show fake progress bar
                    ( newModel
                    , Effect.task registrationTask
                    , Cmd.none
                    )

                Err submissionError ->
                    ( newModel
                    , Effect.addAlert (Alert.new Alert.Error submissionError)
                    , Cmd.none
                    )

        TaskOnComplete _ ->
            Debug.todo ""


taskErrorMapper : ConcurrentTask.Http.Error -> Tasks.Error
taskErrorMapper error =
    case error of
        ConcurrentTask.Http.BadStatus meta value ->
            if List.member meta.statusCode [ 400, 500 ] then
                value
                    |> Json.Decode.decodeValue Json.Decode.string
                    |> Result.toMaybe
                    |> Maybe.withDefault "Unknown error"
                    |> Tasks.RegisterError

            else
                Tasks.RegisterError "Unknown error"

        _ ->
            Tasks.RegisterError "Error while performing registration request. Please, try again."


subscriptions : Sub Msg
subscriptions =
    Sub.none


buildUserData : Model -> Result String UserData
buildUserData { usernameInput, privateKeyInput } =
    let
        errorMsg : String
        errorMsg =
            "One or more inputs are invalid. Check the messages in the form to fix and try again."
    in
    case ( usernameInput.valid, privateKeyInput.valid ) of
        ( Just username, Just privateKey ) ->
            Result.map2
                (\username_ privateKey_ -> { username = username_, privateKey = privateKey_ })
                username
                privateKey
                |> Result.mapError (always errorMsg)

        _ ->
            Err errorMsg


updateUsername :
    Form.InputEvent
    -> Form.Input Business.Username.Username
    -> Form.Input Business.Username.Username
updateUsername event input =
    case event of
        Form.OnInput raw ->
            { input | raw = String.trim raw }

        Form.OnFocus ->
            { input | valid = Nothing }

        Form.OnBlur ->
            Form.parseInput Business.Username.fromString input


updatePrivateKey :
    Form.InputEvent
    -> Form.Input Business.PrivateKey.PrivateKey
    -> Form.Input Business.PrivateKey.PrivateKey
updatePrivateKey event input =
    case event of
        Form.OnInput raw ->
            { input | raw = String.trim raw }

        Form.OnFocus ->
            { input | valid = Nothing }

        Form.OnBlur ->
            Form.parseInput Business.PrivateKey.fromString input


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
                [ Html.legend [] [ Html.text "Register" ]
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
                , Html.button [] [ Html.text "Register" ]
                ]
            ]
        , Html.a [ Html.Attributes.href "/" ] [ Html.text "Login" ]
        ]


encodeChallengeWithUserData : Challenge -> UserData -> Json.Encode.Value
encodeChallengeWithUserData challenge userData =
    Json.Encode.object
        [ ( "username", Business.Username.encode userData.username )
        , ( "privateKey", Business.PrivateKey.encode userData.privateKey )
        , ( "nonce", Json.Encode.string challenge.nonce )
        , ( "challenge", Json.Encode.string challenge.challenge )
        ]


decodeChallenge : Json.Decode.Decoder Challenge
decodeChallenge =
    Json.Decode.map2 Challenge
        (Json.Decode.field "nonce" Json.Decode.string)
        (Json.Decode.field "challenge" Json.Decode.string)
