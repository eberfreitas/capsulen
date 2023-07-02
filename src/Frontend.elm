module Frontend exposing (main)

import Browser
import Html


type Model
    = Homepage


view : Model -> Html.Html msg
view _ =
    Html.div [] [ Html.h1 [] [ Html.text "Capsulen" ] ]


update : msg -> Model -> ( Model, Cmd msg )
update _ model =
    ( model, Cmd.none )


main : Program () Model msg
main =
    Browser.element
        { init = \() -> ( Homepage, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
