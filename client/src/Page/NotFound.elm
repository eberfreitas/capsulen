module Page.NotFound exposing (view)

import Color.Extra
import Css
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import View.Logo
import View.Theme


view : View.Theme.Theme -> Html.Html msg
view theme =
    Html.div
        [ HtmlAttributes.css
            [ Css.width <| Css.vw 100
            , Css.height <| Css.vh 100
            , Css.displayFlex
            , Css.flexDirection Css.column
            , Css.alignItems Css.center
            , Css.justifyContent Css.center
            ]
        ]
        [ Html.div
            [ HtmlAttributes.css
                [ Css.marginBottom <| Css.rem 2 ]
            ]
            [ Html.a [ HtmlAttributes.href "/" ] [ View.Logo.logo 72 (theme |> View.Theme.foregroundColor) ] ]
        , Html.div
            [ HtmlAttributes.css
                [ Css.fontSize <| Css.rem 8
                , Css.fontWeight Css.bold
                , Css.color (theme |> View.Theme.foregroundColor |> Color.Extra.withAlpha 0.25 |> Color.Extra.toCss)
                ]
            ]
            [ Html.text "404" ]
        ]
