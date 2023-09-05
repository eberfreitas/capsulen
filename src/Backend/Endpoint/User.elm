module Backend.Endpoint.User exposing (requestAccess)

import Express.Conn
import Express.Request
import Express.Response
import Json.Decode
import Json.Encode
import Backend.Port


requestAccess :
    Express.Request.Request
    -> Express.Response.Response
    -> ( Express.Conn.Conn (), Cmd msg )
requestAccess request response =
    let
        conn : Express.Conn.Conn ()
        conn =
            { request = request, response = response, model = () }

        username : Result Json.Decode.Error String
        username =
            request
                |> Express.Request.body
                |> Json.Decode.decodeString (Json.Decode.field "username" Json.Decode.string)
    in
    case username of
        Ok username_ ->
            let
                data : Json.Encode.Value
                data =
                    Json.Encode.object
                        [ ( "requestId", Json.Encode.string <| Express.Request.id request )
                        , ( "username", Json.Encode.string username_ )
                        ]
            in
            ( conn, Backend.Port.userRequestAccess data )

        Err _ ->
            ( conn, Cmd.none )
