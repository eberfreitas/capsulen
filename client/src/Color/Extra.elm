module Color.Extra exposing (toContrast, toCss, withAlpha)

import Color
import Css
import Css.Value


type alias Rgba =
    { red : Float
    , green : Float
    , blue : Float
    , alpha : Float
    }


type alias Hsla =
    { hue : Float
    , saturation : Float
    , lightness : Float
    , alpha : Float
    }


toCss : Color.Color -> Css.Value.Value { provides | rgba : Css.Value.Supported }
toCss color =
    let
        rgba : Rgba
        rgba =
            Color.toRgba color

        buildColor : Float -> Int
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
        hsla : Hsla
        hsla =
            Color.toHsla color

        lightness : Float
        lightness =
            if hsla.lightness < 0.5 then
                hsla.lightness + delta

            else
                hsla.lightness - delta
    in
    Color.fromHsla { hsla | lightness = lightness }


withAlpha : Float -> Color.Color -> Color.Color
withAlpha alpha color =
    let
        rgba : Rgba
        rgba =
            Color.toRgba color
    in
    Color.fromRgba { rgba | alpha = alpha }
