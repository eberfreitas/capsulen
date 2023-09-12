module Business.Username exposing (Username, decode, encode, fromString, toString)

import Json.Decode
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
        Err "Username can't be empty."

    else if username /= raw then
        Err "Username must contain only letters, numbers and underscores (_)."

    else
        Ok (Username username)


toString : Username -> String
toString (Username username) =
    username


decode : Json.Decode.Decoder Username
decode =
    Json.Decode.string
        |> Json.Decode.andThen
            (\username ->
                case fromString username of
                    Ok username_ ->
                        Json.Decode.succeed username_

                    Err _ ->
                        Json.Decode.fail <| "Could not decode username: " ++ username
            )


encode : Username -> Json.Encode.Value
encode (Username username) =
    Json.Encode.string username
