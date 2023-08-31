module Business.PrivateKey exposing (PrivateKey, fromString, toString)


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
        Err ("Private key must have more than " ++ String.fromInt minLength ++ " characters")

    else if raw /= String.trim raw then
        Err "Avoid spaces at the beginning and end of the private key."

    else
        Ok (PrivateKey privateKey)


toString : PrivateKey -> String
toString (PrivateKey privateKey) =
    privateKey
