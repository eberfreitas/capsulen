module Business.Post exposing (Content(..), Post, decode)

import Json.Decode


type Content
    = Encrypted String
    | Decrypted { data : String }


type alias Post =
    { id : String
    , content : Content
    , createdAt : String
    }


decodeDecryptedContent : Json.Decode.Decoder Content
decodeDecryptedContent =
    Json.Decode.map (\data -> Decrypted { data = data })
        (Json.Decode.field "data" Json.Decode.string)


decodeEncryptedContent : Json.Decode.Decoder Content
decodeEncryptedContent =
    Json.Decode.map Encrypted Json.Decode.string


decodeContent : Json.Decode.Decoder Content
decodeContent =
    Json.Decode.oneOf [ decodeDecryptedContent, decodeEncryptedContent ]


decode : Json.Decode.Decoder Post
decode =
    Json.Decode.map3 Post
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "content" decodeContent)
        (Json.Decode.field "created_at" Json.Decode.string)
