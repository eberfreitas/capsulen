module Alert exposing (Message, Severity(..), new, toHtml)

import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Html.Styled.Events as HtmlEvents
import Phosphor
import Css
import View.Theme
import View.Color


type Severity
    = Success
    | Error
    | Warning


type Message
    = Message { severity : Severity, body : String }


new : Severity -> String -> Message
new severity body =
    Message { severity = severity, body = body }


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
            [ Css.bottom <| Css.px 0
            , Css.left <| Css.pct 50
            , Css.maxWidth <| Css.px 700
            , Css.position Css.fixed
            , Css.transform <| Css.translate (Css.pct -50)
            , Css.width <| Css.pct 100
            , Css.margin2 (Css.px 0) (Css.auto)
            , Css.backgroundColor (theme |> View.Theme.foregroundColor |> View.Color.toCss)
            , Css.color (theme |> View.Theme.backgroundColor |> View.Color.toCss)
            , Css.fontWeight Css.bold
            , Css.padding <| Css.rem 1
            ]
        ]
        [ Html.div [] [ Html.text <| message.body ]
        , Html.div []
            [ Html.button [ HtmlEvents.onClick <| closeFn index ]
                [ Phosphor.xCircle Phosphor.Regular |> Phosphor.toHtml [] |> Html.fromUnstyled ]
            ]
        ]
