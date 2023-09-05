port module Backend.Port exposing (userRequestAccess)

import Json.Decode


port userRequestAccess : Json.Decode.Value -> Cmd msg
