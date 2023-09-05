port module Backend exposing (main)

import AppUrl
import Backend.Endpoint.User
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


notFound : Express.Response.Response
notFound =
    Express.Response.new
        |> Express.Response.status Express.Response.NotFound
        |> Express.Response.text "Not found"


incoming : () -> Express.Request.Request -> Express.Response.Response -> ( Express.Conn.Conn (), Cmd msg )
incoming _ request response =
    let
        url =
            AppUrl.fromUrl <| Express.Request.url request
    in
    case ( Express.Request.method request, url.path ) of
        ( Express.Request.Post, [ "api", "users", "request_access" ] ) ->
            let
                ( conn, cmds ) =
                    Backend.Endpoint.User.requestAccess request response
            in
            ( conn, cmds )

        _ ->
            let
                conn : Express.Conn.Conn ()
                conn =
                    { request = request, response = notFound, model = () }
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
