module View.Style exposing (..)

import Css
import Css.Global
import Html.Styled as Html
import View.Theme
import View.Theme as Theme
import View.Color as Color


html : View.Theme.Theme -> Html.Html msg
html theme =
    Css.Global.global
        [ Css.Global.html
            [ Css.backgroundColor (theme |> Theme.backgroundColor |> Color.toCss)
            , Css.color (theme |> Theme.textColor |> Color.toCss)
            , Css.fontFamily Css.sansSerif
            , Css.fontSize <| Css.px 12
            ]
        ]
