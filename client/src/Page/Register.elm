module Page.Register exposing (FormInput, Model, Msg, UserData, init, subscriptions, update, view)

import Alert
import Business.PrivateKey
import Business.Username
import Effect
import Html
import Html.Attributes
import Html.Events
import Http
import Json.Decode
import Json.Decode.Extra
import Json.Encode
import Phosphor
import Port


type InputEvent
    = Focus
    | Blur
    | Input String


type Msg
    = WithUsername InputEvent
    | WithPrivateKey InputEvent
    | ToggleShowPrivateKey
    | Submit
    | GotAccessRequest (Result Http.Error (Result String AccessRequest))
    | GotChallengeEncrypted Json.Decode.Value
    | GotUserCreated (Result Http.Error (Result String User))


type alias AccessRequest =
    { username : Business.Username.Username
    , nonce : String
    , challenge : String
    }


type alias User =
    { username : Business.Username.Username
    , nonce : String
    , challenge : String
    , challengeEncrypted : String
    }


type alias Model =
    { usernameInput : FormInput Business.Username.Username
    , privateKeyInput : FormInput Business.PrivateKey.PrivateKey
    , showPrivateKey : Bool
    , userData : Maybe UserData
    }


type alias FormInput a =
    { raw : String
    , valid : Maybe (Result String a)
    }


type alias UserData =
    { username : Business.Username.Username
    , privateKey : Business.PrivateKey.PrivateKey
    }


baseModel : Model
baseModel =
    { usernameInput = { raw = "", valid = Nothing }
    , privateKeyInput = { raw = "", valid = Nothing }
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
                        | usernameInput = parseInput Business.Username.fromString model.usernameInput
                        , privateKeyInput = parseInput Business.PrivateKey.fromString model.privateKeyInput
                    }

                ( modelUserData, effects, cmds ) =
                    case buildUserData newModel of
                        Ok userData ->
                            let
                                cmd : Cmd Msg
                                cmd =
                                    Http.post
                                        { url = "/api/users/request_access"
                                        , body = Http.jsonBody <| encodeUserData userData
                                        , expect = Http.expectJson GotAccessRequest decodeAccessRequestResult
                                        }
                            in
                            -- TODO: Use loader effect here, to show fake progress bar
                            ( Just userData, Effect.none, cmd )

                        Err submissionError ->
                            ( Nothing
                            , Effect.addAlert (Alert.new Alert.Error submissionError)
                            , Cmd.none
                            )
            in
            ( { newModel | userData = modelUserData }, effects, cmds )

        GotAccessRequest result ->
            case ( result, model.userData ) of
                ( Ok (Ok accessRequest), Just userData ) ->
                    ( model
                    , Effect.none
                    , Port.sendAccessRequest <| encodeAccessRequestWithPrivateKey accessRequest userData.privateKey
                    )

                ( Ok (Err errorMsg), _ ) ->
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
            , Http.post
                { url = "/api/users/create_user"
                , body = Http.jsonBody raw
                , expect = Http.expectJson GotUserCreated decodeUser
                }
            )

        GotUserCreated _ ->
            ( model, Effect.none, Cmd.none )


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


parseInput : (String -> Result String a) -> FormInput a -> FormInput a
parseInput parser input =
    { input | valid = Just <| parser input.raw }


updateUsername :
    InputEvent
    -> FormInput Business.Username.Username
    -> FormInput Business.Username.Username
updateUsername event input =
    case event of
        Input raw ->
            { input | raw = String.trim raw }

        Focus ->
            { input | valid = Nothing }

        Blur ->
            parseInput Business.Username.fromString input


updatePrivateKey :
    InputEvent
    -> FormInput Business.PrivateKey.PrivateKey
    -> FormInput Business.PrivateKey.PrivateKey
updatePrivateKey event input =
    case event of
        Input raw ->
            { input | raw = String.trim raw }

        Focus ->
            { input | valid = Nothing }

        Blur ->
            parseInput Business.PrivateKey.fromString input


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
                                ++ inputEvents WithUsername
                            )
                            []
                        , viewInputError usernameInput
                        ]
                    ]
                , Html.label []
                    [ Html.div []
                        [ Html.text "Private key"
                        , Html.input
                            ([ Html.Attributes.type_ privateKeyInputType
                             , Html.Attributes.value privateKeyInput.raw
                             ]
                                ++ inputEvents WithPrivateKey
                            )
                            []
                        , Html.a
                            [ Html.Events.onClick ToggleShowPrivateKey ]
                            [ togglePrivateKeyIcon ]
                        , viewInputError privateKeyInput
                        , Html.div [] [ Html.text "Your private key will *never* be sent over the network." ]
                        ]
                    ]
                , Html.button [] [ Html.text "Submit" ]
                ]
            ]
        ]


inputEvents : (InputEvent -> msg) -> List (Html.Attribute msg)
inputEvents msg =
    [ Html.Events.onInput (Input >> msg)
    , Html.Events.onBlur (msg Blur)
    , Html.Events.onFocus (msg Focus)
    ]


viewInputError : FormInput a -> Html.Html msg
viewInputError input =
    case input.valid of
        Just (Err msg) ->
            Html.div [] [ Html.text msg ]

        _ ->
            Html.text ""


encodeUserData : UserData -> Json.Encode.Value
encodeUserData { username } =
    Json.Encode.object
        [ ( "username", Business.Username.encode username ) ]


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


decodeAccessRequestResult : Json.Decode.Decoder (Result String AccessRequest)
decodeAccessRequestResult =
    Json.Decode.Extra.result
        Json.Decode.string
        decodeAccessRequest


decodeUser : Json.Decode.Decoder (Result String User)
decodeUser =
    Json.Decode.Extra.result
        Json.Decode.string
        (Json.Decode.map4 User
            (Json.Decode.field "username" Business.Username.decode)
            (Json.Decode.field "nonce" Json.Decode.string)
            (Json.Decode.field "challenge" Json.Decode.string)
            (Json.Decode.field "challengeEncrypted" Json.Decode.string)
        )
