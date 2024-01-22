module Business.InviteCode exposing (InviteCode, encode, fromString)

import Json.Encode
import Translations


type InviteCode
    = InviteCode String


length : Int
length =
    8


fromString : String -> Result Translations.Key InviteCode
fromString str =
    if String.length str /= length then
        Err Translations.InviteCodeInvalid

    else
        Ok (InviteCode str)


toString : InviteCode -> String
toString (InviteCode code) =
    code


encode : InviteCode -> Json.Encode.Value
encode code =
    code |> toString |> Json.Encode.string
