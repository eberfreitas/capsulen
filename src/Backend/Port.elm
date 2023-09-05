port module Backend.Port exposing
    ( errorPort
    , poolPort
    , requestPort
    , responsePort
    , userRequestAccess
    )

import Json.Decode
import Json.Encode


port requestPort : (Json.Decode.Value -> msg) -> Sub.Sub msg


port poolPort : (String -> msg) -> Sub.Sub msg


port responsePort : Json.Encode.Value -> Cmd.Cmd msg


port errorPort : String -> Cmd.Cmd msg


port userRequestAccess : Json.Decode.Value -> Cmd msg
