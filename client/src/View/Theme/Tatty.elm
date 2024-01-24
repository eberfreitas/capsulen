module View.Theme.Tatty exposing (palette)

import Color
import View.Theme.Palette


palette : View.Theme.Palette.Palette
palette =
    { background = Color.rgb255 255 215 215
    , foreground = Color.rgb255 241 84 124
    , text = Color.rgb255 94 76 90
    , error = Color.rgb255 200 90 90
    , warning = Color.rgb255 245 215 120
    , success = Color.rgb255 110 200 245
    }
