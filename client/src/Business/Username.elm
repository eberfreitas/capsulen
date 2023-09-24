module Business.Username exposing (Username, encode, fromString, toString)

import Json.Encode
import Regex


type Username
    = Username String


fromString : String -> Result String Username
fromString raw =
    let
        username : String
        username =
            "[^A-Za-z0-9_]*"
                |> Regex.fromString
                |> Maybe.map (\regex -> Regex.replace regex (\_ -> "") raw)
                |> Maybe.withDefault ""
                |> String.trim
    in
    if username == "" then
        Err "USERNAME_EMPTY"

    else if username /= raw then
        Err "USERNAME_INVALID"

    else
        Ok (Username username)


toString : Username -> String
toString (Username username) =
    username


encode : Username -> Json.Encode.Value
encode (Username username) =
    Json.Encode.string username
