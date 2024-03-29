module View.Style exposing (app, btn, btnDisabled, btnFull, btnInverse, btnShort, logo)

import Color.Extra
import Css
import Css.Global
import Html.Styled as Html
import View.Theme


app : View.Theme.Theme -> Html.Html msg
app theme =
    Css.Global.global
        [ Css.Global.everything [ Css.boxSizing Css.borderBox ]
        , Css.Global.html
            [ Css.backgroundColor (theme |> View.Theme.backgroundColor |> Color.Extra.toCss)
            , Css.color (theme |> View.Theme.textColor |> Color.Extra.toCss)
            , Css.fontFamily Css.sansSerif
            , Css.fontSize <| Css.px 12
            ]
        ]


logo : Css.Style
logo =
    Css.batch
        [ Css.marginBottom <| Css.rem 2
        , Css.textAlign Css.center
        ]


btn : View.Theme.Theme -> Css.Style
btn theme =
    Css.batch
        [ Css.backgroundColor (theme |> View.Theme.foregroundColor |> Color.Extra.toCss)
        , Css.border <| Css.px 2
        , Css.borderStyle Css.solid
        , Css.borderColor (theme |> View.Theme.foregroundColor |> Color.Extra.toCss)
        , Css.borderRadius <| Css.rem 0.5
        , Css.color (theme |> View.Theme.backgroundColor |> Color.Extra.toCss)
        , Css.cursor Css.pointer
        , Css.display Css.block
        , Css.fontVariant Css.allPetiteCaps
        , Css.fontWeight Css.bold
        , Css.property "padding" "calc(1rem - 2px)"
        , Css.textAlign Css.center
        , Css.textDecoration Css.none
        ]


btnFull : Css.Style
btnFull =
    Css.width <| Css.pct 100


btnShort : Css.Style
btnShort =
    Css.padding2 (Css.rem 0.5) (Css.rem 1)


btnInverse : View.Theme.Theme -> Css.Style
btnInverse theme =
    Css.batch
        [ Css.backgroundColor Css.transparent
        , Css.borderColor (theme |> View.Theme.foregroundColor |> Color.Extra.toCss)
        , Css.color (theme |> View.Theme.foregroundColor |> Color.Extra.toCss)
        ]


btnDisabled : Css.Style
btnDisabled =
    Css.batch
        [ Css.opacity <| Css.num 0.45
        , Css.cursor Css.notAllowed
        ]
