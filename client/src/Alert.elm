module Alert exposing (Message, Severity(..), new, toHtml)

import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Html.Styled.Events as HtmlEvents
import Phosphor


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


toHtml : (Int -> msg) -> Int -> Message -> Html.Html msg
toHtml closeFn index (Message message) =
    Html.div
        [ HtmlAttributes.class <| messageClass message.severity ]
        [ Html.div [] [ Html.text <| message.body ]
        , Html.div []
            [ Html.button [ HtmlEvents.onClick <| closeFn index ]
                [ Phosphor.xCircle Phosphor.Regular |> Phosphor.toHtml [] |> Html.fromUnstyled ]
            ]
        ]
