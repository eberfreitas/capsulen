module View.Theme.Dark exposing (palette)

import View.Color
import View.Theme.Palette


palette : View.Theme.Palette.Palette
palette =
    { backgroundColor = View.Color.new 23 23 23 1.0
    , foregroundColor = View.Color.new 154 134 163 1.0
    , textColor = View.Color.new 234 221 239 1.0
    }
