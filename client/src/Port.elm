port module Port exposing (..)

import Json.Decode
import Json.Encode


port sendAccessRequest : Json.Encode.Value -> Cmd msg


port getChallengeEncrypted : (Json.Decode.Value -> msg) -> Sub msg
