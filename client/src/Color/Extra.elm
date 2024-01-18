module Color.Extra exposing (toContrast, toCss)

import Color
import Css
import Css.Value


toCss : Color.Color -> Css.Value.Value { provides | rgba : Css.Value.Supported }
toCss color =
    let
        rgba =
            Color.toRgba color

        buildColor =
            (*) 255 >> round
    in
    Css.rgba
        (buildColor rgba.red)
        (buildColor rgba.green)
        (buildColor rgba.blue)
        rgba.alpha


toContrast : Float -> Color.Color -> Color.Color
toContrast delta color =
    let
        hsla =
            Color.toHsla color

        lightness =
            if hsla.lightness < 0.5 then
                hsla.lightness + delta
            else
                hsla.lightness - delta
    in
    Color.fromHsla { hsla | lightness = lightness }
