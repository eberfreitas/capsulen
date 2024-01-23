module Business.InviteCode exposing
    ( Invite
    , InviteCode
    , InviteStatus(..)
    , decodeInvite
    , encode
    , fromString
    )

import Json.Decode
import Json.Encode
import Translations


type InviteCode
    = InviteCode String


type InviteStatus
    = Pending
    | Used


type alias Invite =
    { code : String
    , status : InviteStatus
    }


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


decodeInviteStatus : Json.Decode.Decoder InviteStatus
decodeInviteStatus =
    Json.Decode.string
        |> Json.Decode.andThen
            (\status ->
                case status of
                    "pending" ->
                        Json.Decode.succeed Pending

                    "used" ->
                        Json.Decode.succeed Used

                    _ ->
                        Json.Decode.fail <| "Incorrect value for invite status of: " ++ status
            )


decodeInvite : Json.Decode.Decoder Invite
decodeInvite =
    Json.Decode.map2 Invite
        (Json.Decode.field "code" Json.Decode.string)
        (Json.Decode.field "status" decodeInviteStatus)
