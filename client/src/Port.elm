port module Port exposing
    ( getChallengeEncrypted
    , getLoginChallenge
    , getPost
    , sendAccessRequest
    , sendLoginRequest
    , sendPost
    , sendToken
    )

import Json.Decode
import Json.Encode


port sendAccessRequest : Json.Encode.Value -> Cmd msg


port sendLoginRequest : Json.Encode.Value -> Cmd msg


port sendToken : Json.Encode.Value -> Cmd msg


port sendPost : Json.Encode.Value -> Cmd msg


port getChallengeEncrypted : (Json.Decode.Value -> msg) -> Sub msg


port getLoginChallenge : (Json.Decode.Value -> msg) -> Sub msg


port getPost : (Json.Decode.Value -> msg) -> Sub msg
