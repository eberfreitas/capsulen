module Json.Decode.Extra exposing (result)

import Json.Decode


result : Json.Decode.Decoder e -> Json.Decode.Decoder a -> Json.Decode.Decoder (Result e a)
result errorDecoder dataDecoder =
    Json.Decode.field "_kind" Json.Decode.string
        |> Json.Decode.andThen
            (\type_ ->
                case type_ of
                    "err" ->
                        Json.Decode.map Err <| Json.Decode.field "error" errorDecoder

                    "ok" ->
                        Json.Decode.map Ok <| Json.Decode.field "data" dataDecoder

                    _ ->
                        Json.Decode.fail <| "Unknown result type: " ++ type_
            )
