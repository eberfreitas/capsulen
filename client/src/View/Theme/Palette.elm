module View.Theme.Palette exposing (Palette, encode)

import Json.Encode
import View.Color


type alias Palette =
    { backgroundColor : View.Color.Color
    , foregroundColor : View.Color.Color
    , textColor : View.Color.Color
    , errorColor : View.Color.Color
    }


encode : Palette -> Json.Encode.Value
encode palette =
    Json.Encode.object
        [ ( "backgroundColor", View.Color.encode palette.backgroundColor )
        , ( "foregroundColor", View.Color.encode palette.foregroundColor )
        , ( "textColor", View.Color.encode palette.textColor )
        , ( "errorColor", View.Color.encode palette.errorColor )
        ]
