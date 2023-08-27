module Frontend.Page.Register exposing (Model, Msg, init, update, view)

import Frontend.View
import Html


type Msg
    = FormMsg


type alias Model =
    { submitting : Bool }


init : ( Model, Cmd Msg )
init =
    ( { submitting = False }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormMsg ->
            ( model, Cmd.none )


view : Model -> Html.Html Msg
view _ =
    Frontend.View.template
        []
