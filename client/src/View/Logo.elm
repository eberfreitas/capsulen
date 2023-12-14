module View.Logo exposing (logo)

import Html.Styled as Html
import Svg.Styled as Svg
import Svg.Styled.Attributes as SvgAttributes
import View.Color as Color


logo : Int -> Color.Color -> Html.Html msg
logo size color =
    Svg.svg
        [ SvgAttributes.viewBox "0 0 130 130"
        , SvgAttributes.fill "none"
        , SvgAttributes.width <| String.fromInt size
        , SvgAttributes.height <| String.fromInt size
        ]
        [ Svg.circle
            [ SvgAttributes.cx "87.5"
            , SvgAttributes.cy "65.5"
            , SvgAttributes.r "22.5"
            , SvgAttributes.fill <| Color.toString color
            ]
            []
        , Svg.path
            [ SvgAttributes.d "M65 0c35.874 0 65 29.126 65 65 0 35.874-29.126 65-65 65-35.874 0-65-29.126-65-65C0 29.126 29.126 0 65 0Zm0 10c-30.355 0-55 24.645-55 55s24.645 55 55 55 55-24.645 55-55-24.645-55-55-55Z"
            , SvgAttributes.fill <| Color.toString color
            ]
            []
        ]
