port module Backend.Endpoint.User exposing (Msg, decodeRequestId, requestAccess, subscriptions, update)

import Backend.Port
import Express.Conn
import Express.Request
import Express.Response
import Json.Decode
import Json.Encode
import Json.Encode.Extra


port gotAccessRequest : (Json.Encode.Value -> msg) -> Sub msg


type Msg
    = GotAccessRequest Json.Decode.Value


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


subscriptions : Sub Msg
subscriptions =
    gotAccessRequest GotAccessRequest


update : Msg -> Express.Conn.Conn () -> ( Express.Conn.Conn (), Cmd Msg )
update msg conn =
    case msg of
        GotAccessRequest raw ->
            case Json.Decode.decodeValue (Json.Decode.field "data" Json.Decode.value) raw of
                Ok result ->
                    let
                        newResponse =
                            conn.response |> Express.Response.json result

                        newConn =
                            { conn | response = newResponse }
                    in
                    ( newConn, newConn |> Express.Conn.send |> Backend.Port.responsePort )

                Err _ ->
                    let
                        result =
                            Err "There was an internal error decoding your user access request. Please, try again."
                                |> Json.Encode.Extra.result Json.Encode.string Json.Encode.string

                        newResponse =
                            conn.response |> Express.Response.json result

                        newConn =
                            { conn | response = newResponse }
                    in
                    ( newConn, newConn |> Express.Conn.send |> Backend.Port.responsePort )


decodeRequestId : Msg -> Result Json.Decode.Error String
decodeRequestId msg =
    case msg of
        GotAccessRequest raw ->
            Express.Request.decodeRequestId raw
