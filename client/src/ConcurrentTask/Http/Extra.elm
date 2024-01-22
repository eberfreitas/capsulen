module ConcurrentTask.Http.Extra exposing (errorToString)

import ConcurrentTask.Http
import Dict
import Json.Decode


errorToString : ConcurrentTask.Http.Error -> String
errorToString error =
    case error of
        ConcurrentTask.Http.BadUrl url ->
            "[BAD URL]" ++ url

        ConcurrentTask.Http.Timeout ->
            "[TIMEOUT]"

        ConcurrentTask.Http.NetworkError ->
            "[NETWORK ERROR]"

        ConcurrentTask.Http.BadStatus metadata _ ->
            "[BAD STATUS] {METADATA}"
                |> String.replace "{METADATA}" (metadataToString metadata)

        ConcurrentTask.Http.BadBody metadata _ errors ->
            "[BAD BODY] {METADATA} {ERRORS}"
                |> String.replace "{METADATA}" (metadataToString metadata)
                |> String.replace "{ERRORS}" (Json.Decode.errorToString errors)


headersToString : Dict.Dict String String -> String
headersToString headers =
    headers
        |> Dict.toList
        |> List.map (\( k, v ) -> k ++ ": " ++ v)
        |> String.join "; "


metadataToString : ConcurrentTask.Http.Metadata -> String
metadataToString metadata =
    "[METADATA] url: {URL}, status code: {CODE}, status text: {TEXT}, headers: { {HEADERS} }"
        |> String.replace "{URL}" metadata.url
        |> String.replace "{CODE}" (String.fromInt metadata.statusCode)
        |> String.replace "{TEXT}" metadata.statusText
        |> String.replace "{HEADERS}" (headersToString metadata.headers)
