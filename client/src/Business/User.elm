module Business.User exposing (User, decode)

import Json.Decode
import Json.Encode


type alias User =
    { username : String
    , privateKey : Json.Encode.Value
    , token : String
    }


decode : Json.Decode.Decoder User
decode =
    Json.Decode.map3 User
        (Json.Decode.field "username" Json.Decode.string)
        (Json.Decode.field "privateKey" Json.Decode.value)
        (Json.Decode.field "token" Json.Decode.string)
