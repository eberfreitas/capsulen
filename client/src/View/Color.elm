module View.Color exposing (Color, encode, new, toCss)

import Json.Encode


type Color
    = Color
        { red : Int
        , green : Int
        , blue : Int
        , alpha : Float
        }


new : Int -> Int -> Int -> Float -> Color
new red green blue alpha =
    let
        rgbClamp =
            clamp 0 255
    in
    Color
        { red = rgbClamp red
        , green = rgbClamp green
        , blue = rgbClamp blue
        , alpha = clamp 0 1.0 alpha
        }


clamp : comparable -> comparable -> comparable -> comparable
clamp min max value =
    if value < min then
        min

    else if value > max then
        max

    else
        value


withAlpha : Float -> Color -> Color
withAlpha alpha (Color color) =
    Color { color | alpha = clamp 0 1.0 alpha }


toCss : Color -> String
toCss (Color color) =
    "rgb({r} {g} {b} / {a})"
        |> String.replace "{r}" (String.fromInt color.red)
        |> String.replace "{g}" (String.fromInt color.green)
        |> String.replace "{b}" (String.fromInt color.blue)
        |> String.replace "{a}" (String.fromFloat color.alpha)


encode : Color -> Json.Encode.Value
encode color =
    color |> toCss |> Json.Encode.string
