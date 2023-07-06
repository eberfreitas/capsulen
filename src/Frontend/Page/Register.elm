module Frontend.Page.Register exposing (Model, Msg, init, update, view)

import Form
import Form.Field
import Form.FieldView
import Form.Validation
import Frontend.View
import Html


type Msg
    = FormMsg (Form.Msg Msg)
    | OnSubmit
        { fields : List ( String, String )
        , method : Form.Method
        , action : String
        , parsed : Form.Validated String FormData
        }


type alias Model =
    { formModel : Form.Model
    , submitting : Bool
    }


type alias FormData =
    { username : String
    , privateKey : String
    }


init : ( Model, Cmd Msg )
init =
    ( { formModel = Form.init, submitting = False }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormMsg formMsg ->
            let
                ( updatedFormModel, cmd ) =
                    Form.update formMsg model.formModel
            in
            ( { model | formModel = updatedFormModel }, cmd )

        OnSubmit parsed ->
            let
                _ =
                    Debug.log "OnSubmit!" parsed
            in
            ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    Frontend.View.template
        [ form
            |> Form.renderHtml
                { submitting = model.submitting
                , state = model.formModel
                , toMsg = FormMsg
                }
                (Form.options "register" |> Form.withOnSubmit OnSubmit)
                []
        ]


fieldView : String -> Form.Validation.Field error parsed Form.FieldView.Input -> Html.Html msg
fieldView label field =
    Html.label []
        [ Html.text label
        , Form.FieldView.input [] field
        ]


form : Form.HtmlForm String FormData input Msg
form =
    (\username privateKey ->
        { combine =
            Form.Validation.succeed FormData
                |> Form.Validation.andMap username
                |> Form.Validation.andMap privateKey
        , view =
            \_ ->
                [ Html.fieldset []
                    [ Html.legend [] [ Html.text "Register" ]
                    , fieldView "Username" username
                    , fieldView "Private Key" privateKey
                    , Html.button [] [ Html.text "Submit" ]
                    ]
                ]
        }
    )
        |> Form.form
        |> Form.field "username" (Form.Field.text |> Form.Field.required "Required field")
        |> Form.field "privateKey" (Form.Field.text |> Form.Field.required "Required field")
