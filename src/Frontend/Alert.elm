module Frontend.Alert exposing (Message, Severity(..), new, toHtml)

import Html
import Html.Attributes
import Html.Events
import Phosphor


type Severity
    = Success
    | Error
    | Warning
    | Info


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

        Info ->
            "info"


toHtml : (Int -> msg) -> Int -> Message -> Html.Html msg
toHtml closeFn index (Message message) =
    Html.div
        [ Html.Attributes.class <| messageClass message.severity ]
        [ Html.div [] [ Html.text message.body ]
        , Html.div []
            [ Html.a [ Html.Events.onClick <| closeFn index ]
                [ Phosphor.xCircle Phosphor.Regular |> Phosphor.toHtml [] ]
            ]
        ]
