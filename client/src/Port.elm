port module Port exposing
    ( getChallengeEncrypted
    , getError
    , getLoginChallenge
    , getPost
    , getPosts
    , sendAccessRequest
    , sendLoginRequest
    , sendPost
    , sendPostsRequest
    , sendToken
    )

import Json.Decode
import Json.Encode


port taskSend : Json.Decode.Value -> Cmd msg


port taskReceive : (Json.Decode.Value -> msg) -> Sub msg


port sendAccessRequest : Json.Encode.Value -> Cmd msg


port sendLoginRequest : Json.Encode.Value -> Cmd msg


port sendToken : Json.Encode.Value -> Cmd msg


port sendPost : Json.Encode.Value -> Cmd msg


port sendPostsRequest : Json.Encode.Value -> Cmd msg


port getChallengeEncrypted : (Json.Decode.Value -> msg) -> Sub msg


port getLoginChallenge : (Json.Decode.Value -> msg) -> Sub msg


port getPost : (Json.Decode.Value -> msg) -> Sub msg


port getPosts : (Json.Decode.Value -> msg) -> Sub msg


port getError : (String -> msg) -> Sub msg
