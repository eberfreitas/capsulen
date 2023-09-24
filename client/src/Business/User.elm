module Business.User exposing (User)

import Business.Username
import Json.Encode


type alias User =
    { username : Business.Username.Username
    , privateKey : Json.Encode.Value
    , token : String
    }
