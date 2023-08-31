module Frontend.Flash exposing (Message, Severity, new, view)

import Html
import Html.Attributes


type Severity
    = Success
    | Error
    | Warning


type Message
    = Message { severity : Severity, body : String }


new : Severity -> String -> Message
new severity body =
    Message { severity = severity, body = body }


messageClass : Message -> String
messageClass (Message msg) =
    case msg.severity of
        Success ->
            "success"

        Error ->
            "error"

        Warning ->
            "warning"


messageBody : Message -> String
messageBody (Message msg) =
    msg.body


view : List Message -> Html.Html msg
view messages =
    Html.div []
        (messages
            |> List.map
                (\msg ->
                    Html.div
                        [ Html.Attributes.class <| messageClass msg ]
                        [ Html.text <| messageBody msg ]
                )
        )
