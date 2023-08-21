port module Frontend.Port exposing (login)

import Json.Encode


port login : Json.Encode.Value -> Cmd msg
