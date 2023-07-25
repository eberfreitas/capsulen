module Business.PrivateKey exposing (fromString, toString)


type PrivateKey
    = PrivateKey String


minLength : Int
minLength =
    4


fromString : String -> Result String PrivateKey
fromString raw =
    let
        privateKey =
            String.trim raw
    in
    if String.length privateKey < minLength then
        Err ("Private key must have more than " ++ String.fromInt minLength ++ " characters")

    else
        Ok (PrivateKey privateKey)


toString : PrivateKey -> String
toString (PrivateKey privateKey) =
    privateKey
