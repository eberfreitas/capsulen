module View.Theme.Palette exposing (Palette, encode)

import Color
import Json.Encode


type alias Palette =
    { background : Color.Color
    , foreground : Color.Color
    , text : Color.Color
    , error : Color.Color
    , warning : Color.Color
    , success : Color.Color
    }


encode : Palette -> Json.Encode.Value
encode palette =
    let
        encodeColor : Color.Color -> Json.Encode.Value
        encodeColor =
            Color.toCssString >> Json.Encode.string
    in
    Json.Encode.object
        [ ( "background", encodeColor palette.background )
        , ( "foreground", encodeColor palette.foreground )
        , ( "text", encodeColor palette.text )
        , ( "error", encodeColor palette.error )
        , ( "warning", encodeColor palette.warning )
        , ( "success", encodeColor palette.success )
        ]
