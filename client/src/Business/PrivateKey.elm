module Business.PrivateKey exposing (PrivateKey, encode, fromString)

import Json.Encode
import Translations


type PrivateKey
    = PrivateKey String


minLength : Int
minLength =
    4


fromString : String -> Result Translations.Key PrivateKey
fromString raw =
    let
        privateKey : String
        privateKey =
            String.trim raw
    in
    if String.length privateKey < minLength then
        Err Translations.PrivateKeyShort

    else if raw /= String.trim raw then
        Err Translations.PrivateKeyWs

    else
        Ok (PrivateKey privateKey)


encode : PrivateKey -> Json.Encode.Value
encode (PrivateKey privateKey) =
    Json.Encode.string privateKey
