module Business.Post exposing
    ( Content(..)
    , Post
    , PostContent
    , decode
    , encodePostContent
    )

import Json.Decode
import Json.Encode


type alias PostContent =
    { body : String
    , images : List String
    }


type Content
    = Encrypted
    | Decrypted PostContent


type alias Post =
    { id : String
    , content : Content
    , createdAt : String
    }


encodePostContent : PostContent -> Json.Encode.Value
encodePostContent postContent =
    Json.Encode.object
        [ ( "body", Json.Encode.string postContent.body )
        , ( "images", Json.Encode.list Json.Encode.string postContent.images )
        ]


decodeDecryptedContent : Json.Decode.Decoder Content
decodeDecryptedContent =
    Json.Decode.map2 (\body images -> Decrypted { body = body, images = images })
        (Json.Decode.field "body" Json.Decode.string)
        (Json.Decode.field "images" (Json.Decode.list Json.Decode.string))


decodeEncryptedContent : Json.Decode.Decoder Content
decodeEncryptedContent =
    Json.Decode.succeed Encrypted


decodeContent : Json.Decode.Decoder Content
decodeContent =
    Json.Decode.oneOf [ decodeDecryptedContent, decodeEncryptedContent ]


decode : Json.Decode.Decoder Post
decode =
    Json.Decode.map3 Post
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "content" decodeContent)
        (Json.Decode.field "created_at" Json.Decode.string)
