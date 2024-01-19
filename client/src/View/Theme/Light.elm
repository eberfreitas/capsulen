module View.Theme.Light exposing (palette)

import Color
import View.Theme.Palette


palette : View.Theme.Palette.Palette
palette =
    { background = Color.rgb255 217 217 217
    , foreground = Color.rgb255 87 70 93
    , text = Color.rgb255 23 23 23
    , error = Color.rgb255 180 47 62
    , warning = Color.rgb255 240 185 110
    , success = Color.rgb255 87 180 193
    }
