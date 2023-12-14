module Business.User exposing (User, UserData, buildUserData, decode)

import Business.PrivateKey
import Business.Username
import Form
import Json.Decode
import Json.Encode
import Translations


type alias User =
    { username : String -- TODO: Make this an actual Business.Username
    , privateKey : Json.Encode.Value
    , token : String
    }


type alias UserData =
    { username : Business.Username.Username
    , privateKey : Business.PrivateKey.PrivateKey
    }


buildUserData :
    Form.Input Business.Username.Username
    -> Form.Input Business.PrivateKey.PrivateKey
    -> Result Translations.Key UserData
buildUserData usernameInput privateKeyInput =
    case ( usernameInput.valid, privateKeyInput.valid ) of
        ( Form.Valid username, Form.Valid privateKey ) ->
            Ok { username = username, privateKey = privateKey }

        _ ->
            Err Translations.InvalidInputs


decode : Json.Decode.Decoder User
decode =
    Json.Decode.map3 User
        (Json.Decode.field "username" Json.Decode.string)
        (Json.Decode.field "privateKey" Json.Decode.value)
        (Json.Decode.field "token" Json.Decode.string)
