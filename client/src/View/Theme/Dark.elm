module View.Theme.Dark exposing (palette)

import Color
import View.Theme.Palette


palette : View.Theme.Palette.Palette
palette =
    { background = Color.rgb255 23 23 23
    , foreground = Color.rgb255 154 134 163
    , text = Color.rgb255 234 221 239
    , error = Color.rgb255 100 0 40
    , warning = Color.rgb255 100 0 40
    , success = Color.rgb255 100 0 40
    }
