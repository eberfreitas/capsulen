module Backend exposing (main)

import AppUrl
import Backend.Endpoint.User
import Backend.Port
import Express
import Express.Conn
import Express.Request
import Express.Response
import Json.Decode


type Msg
    = UserMsg Backend.Endpoint.User.Msg


notFound : Express.Response.Response
notFound =
    Express.Response.new
        |> Express.Response.status Express.Response.NotFound
        |> Express.Response.text "Not found"


incoming : () -> Express.Request.Request -> Express.Response.Response -> ( Express.Conn.Conn (), Cmd msg )
incoming _ request response =
    let
        url : AppUrl.AppUrl
        url =
            AppUrl.fromUrl <| Express.Request.url request
    in
    case ( Express.Request.method request, url.path ) of
        ( Express.Request.Post, [ "api", "users", "request_access" ] ) ->
            Backend.Endpoint.User.requestAccess request response

        _ ->
            let
                conn : Express.Conn.Conn ()
                conn =
                    { request = request, response = notFound, model = () }
            in
            ( conn, conn |> Express.Conn.send |> Backend.Port.responsePort )


update : () -> Msg -> Express.Conn.Conn () -> ( Express.Conn.Conn (), Cmd Msg )
update _ msg conn =
    case msg of
        UserMsg subMsg ->
            let
                ( nextConn, cmds ) =
                    Backend.Endpoint.User.update subMsg conn
            in
            ( nextConn, cmds |> Cmd.map UserMsg )


decodeRequestId : Msg -> Result Json.Decode.Error String
decodeRequestId msg =
    case msg of
        UserMsg subMsg ->
            Backend.Endpoint.User.decodeRequestId subMsg


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Backend.Endpoint.User.subscriptions |> Sub.map UserMsg
        ]


main : Program () (Express.Model () ()) (Express.Msg Msg)
main =
    Express.application
        { init = \_ -> ()
        , requestPort = Backend.Port.requestPort
        , responsePort = Backend.Port.responsePort
        , errorPort = Backend.Port.errorPort
        , poolPort = Backend.Port.poolPort
        , incoming = incoming
        , subscriptions = subscriptions
        , update = update
        , middlewares = []
        , decodeRequestId = decodeRequestId
        }
