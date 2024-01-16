module Alert exposing (Message, Severity(..), applyDecay, new, toHtml)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Html.Styled.Events as HtmlEvents
import Phosphor
import View.Color
import View.Theme


type Severity
    = Success
    | Error
    | Warning


type Message
    = Message { severity : Severity, body : String, decay : Float }


new : Severity -> String -> Message
new severity body =
    Message { severity = severity, body = body, decay = 10 * 1000 }


applyDecay : Float -> Message -> Maybe Message
applyDecay delta (Message msg) =
    let
        newDecay =
            msg.decay - delta
    in
    if newDecay < 0 then
        Nothing

    else
        Just (Message { msg | decay = newDecay })


messageClass : Severity -> String
messageClass severity =
    case severity of
        Success ->
            "success"

        Error ->
            "error"

        Warning ->
            "warning"


toHtml : View.Theme.Theme -> (Int -> msg) -> Int -> Message -> Html.Html msg
toHtml theme closeFn index (Message message) =
    Html.div
        [ HtmlAttributes.css
            [ Css.backgroundColor (theme |> View.Theme.foregroundColor |> View.Color.toCss)
            , Css.color (theme |> View.Theme.backgroundColor |> View.Color.toCss)
            , Css.fontWeight Css.bold
            , Css.padding <| Css.rem 1
            , Css.marginBottom <| Css.rem 1
            , Css.borderRadius <| Css.rem 1
            , Css.border3 (Css.rem 0.5) Css.solid (theme |> View.Theme.backgroundColor |> View.Color.toCss)
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
