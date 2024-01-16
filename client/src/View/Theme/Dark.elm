module View.Theme.Dark exposing (palette)

import View.Color
import View.Theme.Palette


palette : View.Theme.Palette.Palette
palette =
    { background = View.Color.new 23 23 23 1.0
    , foreground = View.Color.new 154 134 163 1.0
    , text = View.Color.new 234 221 239 1.0
    , error = View.Color.new 100 0 40 1.0
    }
