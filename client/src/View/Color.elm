module View.Color exposing (Color, new, toCss, withAlpha)


type Color
    = Color
        { r : Int
        , g : Int
        , b : Int
        , a : Float
        }


new : Int -> Int -> Int -> Float -> Color
new red green blue alpha =
    let
        rgbClamp =
            clamp 0 255
    in
    Color
        { r = rgbClamp red
        , g = rgbClamp green
        , b = rgbClamp blue
        , a = clamp 0 1.0 alpha
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
    Color { color | a = clamp 0 1.0 alpha }


toCss : Color -> String
toCss (Color color) =
    "rgb({r} {g} {b} / {a})"
        |> String.replace "{r}" (String.fromInt color.r)
        |> String.replace "{g}" (String.fromInt color.g)
        |> String.replace "{b}" (String.fromInt color.b)
        |> String.replace "{a}" (String.fromFloat color.a)
