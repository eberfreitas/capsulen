module View.Theme exposing
    ( Theme(..)
    , backgroundColor
    , encode
    , errorColor
    , foregroundColor
    , fromString
    , successColor
    , textColor
    , toString
    , warningColor
    )

import Color
import Json.Encode
import View.Theme.Dark
import View.Theme.Light
import View.Theme.Palette
import View.Theme.Tatty


type Theme
    = Dark
    | Light
    | Tatty


fromString : String -> Theme
fromString theme =
    case theme of
        "light" ->
            Light

        "dark" ->
            Dark

        "tatty" ->
            Tatty

        _ ->
            Light


toString : Theme -> String
toString theme =
    case theme of
        Light ->
            "light"

        Dark ->
            "dark"

        Tatty ->
            "tatty"


themePalette : Theme -> View.Theme.Palette.Palette
themePalette theme =
    case theme of
        Dark ->
            View.Theme.Dark.palette

        Light ->
            View.Theme.Light.palette

        Tatty ->
            View.Theme.Tatty.palette


backgroundColor : Theme -> Color.Color
backgroundColor theme =
    theme |> themePalette |> .background


foregroundColor : Theme -> Color.Color
foregroundColor theme =
    theme |> themePalette |> .foreground


textColor : Theme -> Color.Color
textColor theme =
    theme |> themePalette |> .text


errorColor : Theme -> Color.Color
errorColor theme =
    theme |> themePalette |> .error


warningColor : Theme -> Color.Color
warningColor theme =
    theme |> themePalette |> .warning


successColor : Theme -> Color.Color
successColor theme =
    theme |> themePalette |> .success


encode : Theme -> Json.Encode.Value
encode theme =
    theme
        |> themePalette
        |> View.Theme.Palette.encode
