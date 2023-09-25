port module Port exposing (taskReceive, taskSend)

import Json.Decode
import Json.Encode


port taskSend : Json.Encode.Value -> Cmd msg


port taskReceive : (Json.Decode.Value -> msg) -> Sub msg
