module Api exposing (post)

import Http
import Task


post : { url : String, body : Http.Body, decoder : (String -> Result err a) } -> Task.Task String a
post params =
    Http.task
        { method = "POST"
        , headers = []
        , url = params.url
        , body = params.body
        , resolver = resolver params.decoder
        , timeout = Nothing
        }


resolver : (String -> Result err a) -> Http.Resolver String a
resolver decoder =
    let
        defaultErrorMsg =
            "Unknown error"
    in
    Http.stringResolver <|
        \response ->
            case response of
                Http.BadStatus_ meta body ->
                    if List.member meta.statusCode [ 400, 500 ] then
                        Err <| String.trim body

                    else
                        Err defaultErrorMsg

                Http.GoodStatus_ _ body ->
                    body
                        |> decoder
                        |> Result.toMaybe
                        |> Maybe.map Ok
                        |> Maybe.withDefault (Err defaultErrorMsg)

                _ ->
                    Err "Error while performing request. Please, try again."
