module Form exposing
    ( Input
    , InputEvent(..)
    , InputState(..)
    , Validity(..)
    , inputEvents
    , newInput
    , parseInput
    , updateInput
    , viewInputError
    )

import Html
import Html.Attributes
import Html.Events
import Translations


type alias Input a =
    { raw : String
    , valid : Validity a
    , state : InputState
    }


type Validity a
    = Unparsed
    | Invalid Translations.Key
    | Valid a


type InputState
    = Idle
    | Active


type InputEvent
    = OnFocus
    | OnBlur
    | OnInput String


resultToValidity : Result String a -> Validity a
resultToValidity result =
    case result of
        Ok value ->
            Valid value

        Err error ->
            Invalid (error |> Translations.keyFromString)


parseInput : (String -> Result String a) -> Input a -> Input a
parseInput parser input =
    { input | valid = input.raw |> parser |> resultToValidity }


updateInput : InputEvent -> (String -> Result String a) -> Input a -> Input a
updateInput event parser input =
    case event of
        OnFocus ->
            { input | state = Active }

        OnBlur ->
            { input | state = Idle }

        OnInput value ->
            { input
                | raw = value
                , valid = value |> parser |> resultToValidity
                , state = Active
            }


inputEvents : (InputEvent -> msg) -> List (Html.Attribute msg)
inputEvents msg =
    [ Html.Events.onInput (OnInput >> msg)
    , Html.Events.onBlur (msg OnBlur)
    , Html.Events.onFocus (msg OnFocus)
    ]


newInput : Input a
newInput =
    { raw = "", valid = Unparsed, state = Idle }


viewInputError : Translations.Helper -> Input a -> Html.Html msg
viewInputError i input =
    case ( input.valid, input.state ) of
        ( Invalid msgKey, Idle ) ->
            Html.div [ Html.Attributes.class "input-error" ] [ Html.text <| i msgKey ]

        _ ->
            Html.text ""
