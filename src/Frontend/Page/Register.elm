module Frontend.Page.Register exposing (FormInput, Model, Msg, UserData, init, update, view)

import Business.PrivateKey
import Business.Username
import Frontend.View
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WithUsername event ->
            ( { model | usernameInput = updateUsername event model.usernameInput }, Cmd.none )

        WithPrivateKey event ->
            ( { model | privateKeyInput = updatePrivateKey event model.privateKeyInput }, Cmd.none )

        ToggleShowPrivateKey ->
            ( { model | showPrivateKey = not model.showPrivateKey }, Cmd.none )

        Submit ->
            ( model, Cmd.none )


updateUsername :
    InputEvent
    -> FormInput Business.Username.Username
    -> FormInput Business.Username.Username
updateUsername event input =
    case event of
        Input raw ->
            { input | raw = String.trim raw }

        Blur ->
            { input | valid = Just (Business.Username.fromString input.raw) }

        Focus ->
            { input | valid = Nothing }


updatePrivateKey :
    InputEvent
    -> FormInput Business.PrivateKey.PrivateKey
    -> FormInput Business.PrivateKey.PrivateKey
updatePrivateKey event input =
    case event of
        Input raw ->
            { input | raw = String.trim raw }

        Blur ->
            { input | valid = Just (Business.PrivateKey.fromString input.raw) }

        Focus ->
            { input | valid = Nothing }


view : Model -> Html.Html Msg
view { usernameInput, privateKeyInput, showPrivateKey } =
    let
        ( privateKeyInputType, togglePrivateKeyIcon ) =
            if showPrivateKey then
                ( "text", Phosphor.eyeClosed Phosphor.Regular |> Phosphor.toHtml [] )

            else
                ( "password", Phosphor.eye Phosphor.Regular |> Phosphor.toHtml [] )
    in
    Frontend.View.template
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
