module Business.Username exposing (Username, fromString, toString)

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
    if username /= raw then
        Err "Username must contain only letters, numbers and underscores (_)."

    else
        Ok (Username username)


toString : Username -> String
toString (Username username) =
    username
