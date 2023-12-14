module View.Theme exposing (Theme(..), backgroundColor, encode, foregroundColor, textColor)

import Json.Encode
import View.Color
import View.Theme.Dark
import View.Theme.Palette


type Theme
    = Dark
    | Light


themePalette : Theme -> View.Theme.Palette.Palette
themePalette theme =
    case theme of
        Dark ->
            View.Theme.Dark.palette

        Light ->
            Debug.todo "Implement light theme"


backgroundColor : Theme -> View.Color.Color
backgroundColor theme =
    theme |> themePalette |> .backgroundColor


foregroundColor : Theme -> View.Color.Color
foregroundColor theme =
    theme |> themePalette |> .foregroundColor


textColor : Theme -> View.Color.Color
textColor theme =
    theme |> themePalette |> .textColor



-- errorColor : Theme -> View.Color.Color
-- errorColor theme =
--     theme |> themePalette |> .errorColor


encode : Theme -> Json.Encode.Value
encode theme =
    theme
        |> themePalette
        |> View.Theme.Palette.encode
