module Business.Username exposing (Username, encode, fromString, toString)

import Json.Encode
import Regex
import Translations


type Username
    = Username String


fromString : String -> Result Translations.Key Username
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
        Err Translations.UsernameEmpty

    else if username /= raw then
        Err Translations.UsernameInvalid

    else
        Ok (Username username)


toString : Username -> String
toString (Username username) =
    username


encode : Username -> Json.Encode.Value
encode (Username username) =
    Json.Encode.string username
