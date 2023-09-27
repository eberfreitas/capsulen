module View.Theme exposing (..)

import View.Color


type Theme
    = Dark


type alias ThemeDefinition =
    { backgroundColor : View.Color.Color
    , foregroundColor : View.Color.Color
    }
