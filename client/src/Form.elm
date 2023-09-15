module Form exposing
    ( Input
    , InputEvent(..)
    , inputError
    , inputEvents
    , newInput
    , parseInput
    , viewInputError
    )

import Html
import Html.Events


type alias Input a =
    { raw : String
    , valid : Maybe (Result String a)
    }


type InputEvent
    = OnFocus
    | OnBlur
    | OnInput String


parseInput : (String -> Result String a) -> Input a -> Input a
parseInput parser input =
    { input | valid = Just <| parser input.raw }


inputEvents : (InputEvent -> msg) -> List (Html.Attribute msg)
inputEvents msg =
    [ Html.Events.onInput (OnInput >> msg)
    , Html.Events.onBlur (msg OnBlur)
    , Html.Events.onFocus (msg OnFocus)
    ]


newInput : Input a
newInput =
    { raw = "", valid = Nothing }


viewInputError : Input a -> Html.Html msg
viewInputError input =
    case input.valid of
        Just (Err msg) ->
            Html.div [] [ Html.text msg ]

        _ ->
            Html.text ""


inputError : String -> Input a -> Input a
inputError error input =
    { input | valid = Just <| Err error }
