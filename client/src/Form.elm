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

import Color.Extra
import Css
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Html.Styled.Events as HtmlEvents
import Translations
import View.Theme


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


resultToValidity : Result Translations.Key a -> Validity a
resultToValidity result =
    case result of
        Ok value ->
            Valid value

        Err error ->
            Invalid error


parseInput : (String -> Result Translations.Key a) -> Input a -> Input a
parseInput parser input =
    { input | valid = input.raw |> parser |> resultToValidity }


updateInput : InputEvent -> (String -> Result Translations.Key a) -> Input a -> Input a
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
    [ HtmlEvents.onInput (OnInput >> msg)
    , HtmlEvents.onBlur (msg OnBlur)
    , HtmlEvents.onFocus (msg OnFocus)
    ]


newInput : Input a
newInput =
    { raw = "", valid = Unparsed, state = Idle }


viewInputError : Translations.Helper -> View.Theme.Theme -> Input a -> Html.Html msg
viewInputError i theme input =
    case ( input.valid, input.state ) of
        ( Invalid msgKey, Idle ) ->
            Html.div
                [ HtmlAttributes.css
                    [ Css.backgroundColor (theme |> View.Theme.errorColor |> Color.Extra.toCss)
                    , Css.color (theme |> View.Theme.errorColor |> Color.Extra.toContrast 0.75 |> Color.Extra.toCss)
                    , Css.borderRadius4 (Css.rem 0) (Css.rem 0) (Css.rem 0.5) (Css.rem 0.5)
                    , Css.fontWeight Css.bold
                    , Css.marginTop <| Css.rem -0.5
                    , Css.padding <| Css.rem 1
                    , Css.paddingTop <| Css.rem 1.5
                    ]
                ]
                [ Html.text <| i msgKey ]

        _ ->
            Html.text ""
