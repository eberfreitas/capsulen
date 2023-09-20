module Page.Register exposing (Model, Msg, UserData, init, subscriptions, update, view)

import Alert
import Api
import Business.PrivateKey
import Business.Username
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


type Msg
    = WithUsername Form.InputEvent
    | WithPrivateKey Form.InputEvent
    | ToggleShowPrivateKey
    | Submit
    | GotAccessRequest (Result String AccessRequest)
    | GotChallengeEncrypted Json.Decode.Value
    | GotUserCreated (Result String ())


type alias AccessRequest =
    { username : Business.Username.Username
    , nonce : String
    , challenge : String
    }


type alias Model =
    { usernameInput : Form.Input Business.Username.Username
    , privateKeyInput : Form.Input Business.PrivateKey.PrivateKey
    , showPrivateKey : Bool
    , userData : Maybe UserData
    }


type alias UserData =
    { username : Business.Username.Username
    , privateKey : Business.PrivateKey.PrivateKey
    }


baseModel : Model
baseModel =
    { usernameInput = Form.newInput
    , privateKeyInput = Form.newInput
    , showPrivateKey = False
    , userData = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( baseModel, Cmd.none )


update : Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update msg model =
    case msg of
        WithUsername event ->
            ( { model | usernameInput = updateUsername event model.usernameInput }
            , Effect.none
            , Cmd.none
            )

        WithPrivateKey event ->
            ( { model | privateKeyInput = updatePrivateKey event model.privateKeyInput }
            , Effect.none
            , Cmd.none
            )

        ToggleShowPrivateKey ->
            ( { model | showPrivateKey = not model.showPrivateKey }
            , Effect.none
            , Cmd.none
            )

        Submit ->
            let
                newModel : Model
                newModel =
                    { model
                        | usernameInput = Form.parseInput Business.Username.fromString model.usernameInput
                        , privateKeyInput = Form.parseInput Business.PrivateKey.fromString model.privateKeyInput
                    }

                ( modelUserData, effects, cmds ) =
                    case buildUserData newModel of
                        Ok userData ->
                            -- TODO: Use loader effect here, to show fake progress bar
                            ( Just userData
                            , Effect.none
                            , Api.post
                                { url = "/api/users/request_access"
                                , body = Http.stringBody "text/plain" <| Business.Username.toString userData.username
                                , decoder = decodeAccessRequest
                                }
                                |> Task.attempt GotAccessRequest
                            )

                        Err submissionError ->
                            ( Nothing
                            , Effect.addAlert (Alert.new Alert.Error submissionError)
                            , Cmd.none
                            )
            in
            ( { newModel | userData = modelUserData }, effects, cmds )

        GotAccessRequest result ->
            case ( result, model.userData ) of
                ( Ok accessRequest, Just userData ) ->
                    ( model
                    , Effect.none
                    , Port.sendAccessRequest <| encodeAccessRequestWithPrivateKey accessRequest userData.privateKey
                    )

                ( Err errorMsg, _ ) ->
                    ( model
                    , Effect.addAlert (Alert.new Alert.Error errorMsg)
                    , Cmd.none
                    )

                _ ->
                    -- TODO: Notify alerting system here...
                    ( model
                    , Effect.addAlert
                        (Alert.new
                            Alert.Error
                            "There was an internal error processing your request. Please, try again."
                        )
                    , Cmd.none
                    )

        GotChallengeEncrypted raw ->
            ( model
            , Effect.none
            , Api.post
                { url = "/api/users/create_user"
                , body = Http.jsonBody raw
                , decoder = decodeUserCreation
                }
                |> Task.attempt GotUserCreated
            )

        GotUserCreated result ->
            case result of
                Ok _ ->
                    ( model
                    , Effect.batch
                        [ Effect.addAlert (Alert.new Alert.Success "Registration successful! Please log in now.")
                        , Effect.redirect "/"
                        ]
                    , Cmd.none
                    )

                Err errMsg ->
                    ( model, Effect.addAlert (Alert.new Alert.Error errMsg), Cmd.none )


subscriptions : Sub Msg
subscriptions =
    Port.getChallengeEncrypted GotChallengeEncrypted


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


encodeAccessRequestWithPrivateKey : AccessRequest -> Business.PrivateKey.PrivateKey -> Json.Encode.Value
encodeAccessRequestWithPrivateKey accessRequest privateKey =
    Json.Encode.object
        [ ( "username", Business.Username.encode accessRequest.username )
        , ( "privateKey", Business.PrivateKey.encode privateKey )
        , ( "nonce", Json.Encode.string accessRequest.nonce )
        , ( "challenge", Json.Encode.string accessRequest.challenge )
        ]


decodeAccessRequest : Json.Decode.Decoder AccessRequest
decodeAccessRequest =
    Json.Decode.map3 AccessRequest
        (Json.Decode.field "username" Business.Username.decode)
        (Json.Decode.field "nonce" Json.Decode.string)
        (Json.Decode.field "challenge" Json.Decode.string)


decodeUserCreation : Json.Decode.Decoder ()
decodeUserCreation =
    Json.Decode.succeed ()
