module Frontend.View exposing (template)

import Html


template : List (Html.Html msg) -> Html.Html msg
template html =
    Html.div
        []
        [ Html.h1 [] [ Html.text "Capsulen" ], Html.div [] html ]
