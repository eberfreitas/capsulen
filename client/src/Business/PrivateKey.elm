module Business.PrivateKey exposing (PrivateKey, encode, fromString)

import Json.Encode


type PrivateKey
    = PrivateKey String


minLength : Int
minLength =
    4


fromString : String -> Result String PrivateKey
fromString raw =
    let
        privateKey : String
        privateKey =
            String.trim raw
    in
    if String.length privateKey < minLength then
        Err "PRIVATE_KEY_SHORT"

    else if raw /= String.trim raw then
        Err "PRIVATE_KEY_WS"

    else
        Ok (PrivateKey privateKey)


encode : PrivateKey -> Json.Encode.Value
encode (PrivateKey privateKey) =
    Json.Encode.string privateKey
