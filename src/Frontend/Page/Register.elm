module Frontend.Page.Register exposing (Model, Msg, init, update, view)

import Form
import Frontend.View
import Html


type Msg
    = FormMsg Form.Msg


type alias Model =
    { submitting : Bool }


init : ( Model, Cmd Msg )
init =
    ( { submitting = False }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormMsg formMsg ->
            let
                _ =
                    Debug.log "Form msg" formMsg
            in
            ( model, Cmd.none )


view : Model -> Html.Html Msg
view _ =
    Frontend.View.template
        []
