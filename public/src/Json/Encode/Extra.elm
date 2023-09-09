module Json.Encode.Extra exposing (result)

import Json.Encode


result : (e -> Json.Encode.Value) -> (a -> Json.Encode.Value) -> Result e a -> Json.Encode.Value
result errorEncoder dataEncoder result_ =
    case result_ of
        Ok ok ->
            Json.Encode.object
                [ ( "type", Json.Encode.string "ok" )
                , ( "data", dataEncoder ok )
                ]

        Err err ->
            Json.Encode.object
                [ ( "type", Json.Encode.string "err" )
                , ( "error", errorEncoder err )
                ]
