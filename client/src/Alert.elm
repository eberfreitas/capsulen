module Alert exposing (Message, Severity(..), new, toHtml)

import Html
import Html.Attributes
import Html.Events
import Phosphor


type Severity
    = Success
    | Error


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


toHtml : (String -> String) -> (Int -> msg) -> Int -> Message -> Html.Html msg
toHtml i closeFn index (Message message) =
    Html.div
        [ Html.Attributes.class <| messageClass message.severity ]
        [ Html.div [] [ Html.text <| i message.body ]
        , Html.div []
            [ Html.button [ Html.Events.onClick <| closeFn index ]
                [ Phosphor.xCircle Phosphor.Regular |> Phosphor.toHtml [] ]
            ]
        ]
