port module Logger exposing (captureMessage)

import Json.Encode


port logMessage : Json.Encode.Value -> Cmd msg


captureMessage : String -> Cmd.Cmd msg
captureMessage msg =
    logMessage <| Json.Encode.string msg
