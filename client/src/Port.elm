port module Port exposing (taskReceive, taskSend, setTheme)

import Json.Decode
import Json.Encode


port taskSend : Json.Encode.Value -> Cmd msg


port taskReceive : (Json.Decode.Value -> msg) -> Sub msg


port setTheme : Json.Encode.Value -> Cmd msg
