port module Frontend.Port exposing (..)

import Json.Encode


port login : Json.Encode.Value -> Cmd msg
