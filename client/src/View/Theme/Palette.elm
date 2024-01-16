module View.Theme.Palette exposing (Palette, encode)

import Json.Encode
import View.Color


type alias Palette =
    { background : View.Color.Color
    , foreground : View.Color.Color
    , text : View.Color.Color
    , error : View.Color.Color
    }


encode : Palette -> Json.Encode.Value
encode palette =
    Json.Encode.object
        [ ( "background", View.Color.encode palette.background )
        , ( "foreground", View.Color.encode palette.foreground )
        , ( "text", View.Color.encode palette.text )
        , ( "error", View.Color.encode palette.error )
        ]
