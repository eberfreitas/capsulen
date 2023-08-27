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
    in
    if username == "" then
        Err "Username can't be empty or contain non-alphanumeric characters"

    else
        Ok (Username username)


toString : Username -> String
toString (Username username) =
    username
