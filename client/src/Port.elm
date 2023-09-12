port module Port exposing (..)

import Json.Encode


port gotAccessRequest : Json.Encode.Value -> Cmd msg
