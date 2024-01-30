port module Port exposing
    ( getPost
    , requestPost
    , setTheme
    , taskReceive
    , taskSend
    , toggleLoader
    )

import Json.Decode
import Json.Encode


port taskSend : Json.Encode.Value -> Cmd msg


port taskReceive : (Json.Decode.Value -> msg) -> Sub msg


port setTheme : Json.Encode.Value -> Cmd msg


port toggleLoader : () -> Cmd msg


port requestPost : Json.Encode.Value -> Cmd msg


port getPost : (Json.Decode.Value -> msg) -> Sub msg
