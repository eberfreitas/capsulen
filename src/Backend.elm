port module Backend exposing (main)

import Express
import Express.Conn
import Express.Request
import Express.Response
import Json.Decode
import Json.Encode


port requestPort : (Json.Decode.Value -> msg) -> Sub.Sub msg


port poolPort : (String -> msg) -> Sub.Sub msg


port responsePort : Json.Encode.Value -> Cmd.Cmd msg


port errorPort : String -> Cmd.Cmd msg


incoming : () -> Express.Request.Request -> Express.Response.Response -> ( Express.Conn.Conn (), Cmd msg )
incoming _ request response =
    let
        conn =
            { request = request, response = response |> Express.Response.text "Capsulen", model = () }
    in
    ( conn, conn |> Express.Conn.send |> responsePort )


update : () -> msg -> Express.Conn.Conn () -> ( Express.Conn.Conn (), Cmd msg )
update _ _ conn =
    ( conn, Cmd.none )


decodeRequestId : msg -> Result Json.Decode.Error String
decodeRequestId _ =
    Err <| Json.Decode.Failure "Decoder not implemented" Json.Encode.null


main : Program () (Express.Model () ()) (Express.Msg msg)
main =
    Express.application
        { init = \_ -> ()
        , requestPort = requestPort
        , responsePort = responsePort
        , errorPort = errorPort
        , poolPort = poolPort
        , incoming = incoming
        , subscriptions = Sub.none
        , update = update
        , middlewares = []
        , decodeRequestId = decodeRequestId
        }
