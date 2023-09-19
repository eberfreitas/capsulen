module Business.Post exposing (Post, decode)

import Json.Decode


type alias Content =
    { data : String
    }


type alias Post =
    { id : String
    , content : Content
    , createdAt : String
    }


decodeContent : Json.Decode.Decoder Content
decodeContent =
    Json.Decode.map Content
        (Json.Decode.field "body" Json.Decode.string)


decode : Json.Decode.Decoder Post
decode =
    Json.Decode.map3 Post
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "content" decodeContent)
        (Json.Decode.field "created_at" Json.Decode.string)
