module Frontend.Page.Register exposing (FormInput, Model, Msg, UserData, init, update, view)

import Business.PrivateKey
import Business.Username
import Frontend.Alert
import Frontend.Effect
import Html
import Html.Attributes
import Html.Events
import Phosphor


type InputEvent
    = Focus
    | Blur
    | Input String


type Msg
    = WithUsername InputEvent
    | WithPrivateKey InputEvent
    | ToggleShowPrivateKey
    | Submit


type alias Model =
    { usernameInput : FormInput Business.Username.Username
    , privateKeyInput : FormInput Business.PrivateKey.PrivateKey
    , showPrivateKey : Bool
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
    }


init : ( Model, Cmd Msg )
init =
    ( baseModel, Cmd.none )


update : Msg -> Model -> ( Model, Frontend.Effect.Effect, Cmd Msg )
update msg model =
    case msg of
        WithUsername event ->
            ( { model | usernameInput = updateUsername event model.usernameInput }
            , Frontend.Effect.none
            , Cmd.none
            )

        WithPrivateKey event ->
            ( { model | privateKeyInput = updatePrivateKey event model.privateKeyInput }
            , Frontend.Effect.none
            , Cmd.none
            )

        ToggleShowPrivateKey ->
            ( { model | showPrivateKey = not model.showPrivateKey }
            , Frontend.Effect.none
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

                ( effects, cmds ) =
                    case buildUserData newModel of
                        Ok _ ->
                            ( Frontend.Effect.none, Cmd.none )

                        Err submissionError ->
                            ( Frontend.Effect.addAlert (Frontend.Alert.new Frontend.Alert.Error submissionError)
                            , Cmd.none
                            )
            in
            ( newModel, effects, cmds )


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
