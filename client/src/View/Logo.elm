module View.Logo exposing (..)

import Html
import Svg
import Svg.Attributes
import View.Color as Color


logo : Int -> Color.Color -> Html.Html msg
logo size color =
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 130 130"
        , Svg.Attributes.fill "none"
        , Svg.Attributes.width <| String.fromInt size
        , Svg.Attributes.height <| String.fromInt size
        ]
        [ Svg.circle
            [ Svg.Attributes.cx "87.5"
            , Svg.Attributes.cy "65.5"
            , Svg.Attributes.r "22.5"
            , Svg.Attributes.fill <| Color.toCss color
            ]
            []
        , Svg.path
            [ Svg.Attributes.d "M65 0c35.874 0 65 29.126 65 65 0 35.874-29.126 65-65 65-35.874 0-65-29.126-65-65C0 29.126 29.126 0 65 0Zm0 10c-30.355 0-55 24.645-55 55s24.645 55 55 55 55-24.645 55-55-24.645-55-55-55Z"
            , Svg.Attributes.fill <| Color.toCss color
            ]
            []
        ]
