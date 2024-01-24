module Alert exposing (Message, Severity(..), applyDecay, new, toHtml)

import Color
import Color.Extra
import Css
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Html.Styled.Events as HtmlEvents
import Phosphor
import View.Theme


type Severity
    = Success
    | Error
    | Warning


type Message
    = Message { severity : Severity, body : String, decay : Float }


new : Severity -> String -> Message
new severity body =
    Message { severity = severity, body = body, decay = 7.5 * 1000 }


applyDecay : Float -> Message -> Maybe Message
applyDecay delta (Message msg) =
    let
        decay : Float
        decay =
            msg.decay - delta
    in
    if decay < 0 then
        Nothing

    else
        Just (Message { msg | decay = decay })


messageColor : View.Theme.Theme -> Severity -> Color.Color
messageColor theme severity =
    let
        fn : View.Theme.Theme -> Color.Color
        fn =
            case severity of
                Success ->
                    View.Theme.successColor

                Error ->
                    View.Theme.errorColor

                Warning ->
                    View.Theme.warningColor
    in
    fn theme


toHtml : View.Theme.Theme -> (Int -> msg) -> Int -> Message -> Html.Html msg
toHtml theme closeFn index (Message message) =
    let
        backgroundColor : Color.Color
        backgroundColor =
            message.severity |> messageColor theme

        textColor : Color.Color
        textColor =
            backgroundColor |> Color.Extra.toContrast 0.75
    in
    Html.div
        [ HtmlAttributes.css
            [ Css.backgroundColor (backgroundColor |> Color.Extra.toCss)
            , Css.color (textColor |> Color.Extra.toCss)
            , Css.fontWeight Css.bold
            , Css.padding <| Css.rem 1
            , Css.marginBottom <| Css.rem 1
            , Css.borderRadius <| Css.rem 1
            , Css.border3 (Css.rem 0.5) Css.solid (theme |> View.Theme.backgroundColor |> Color.Extra.toCss)
            , Css.position Css.relative
            ]
        ]
        [ Html.div [] [ Html.text <| message.body ]
        , Html.div []
            [ Html.button
                [ HtmlEvents.onClick <| closeFn index
                , HtmlAttributes.css
                    [ Css.position Css.absolute
                    , Css.top <| Css.px 0
                    , Css.right <| Css.px 0
                    , Css.backgroundColor Css.transparent
                    , Css.color (textColor |> Color.Extra.toCss)
                    , Css.border <| Css.px 0
                    , Css.fontSize <| Css.rem 2
                    , Css.margin <| Css.px 0
                    , Css.padding <| Css.rem 0.5
                    , Css.cursor Css.pointer
                    ]
                ]
                [ Phosphor.xCircle Phosphor.Regular |> Phosphor.toHtml [] |> Html.fromUnstyled ]
            ]
        ]
