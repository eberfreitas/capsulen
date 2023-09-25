module Page.Posts exposing (Model, Msg, init, update, view)

import Alert
import Business.User
import Context
import Effect
import Form
import Html
import Html.Attributes
import Html.Events
import Page


type alias Model =
    { postInput : Form.Input String }


type Msg
    = WithPostInput Form.InputEvent
    | Submit


view : Context.Context -> Model -> Html.Html Msg
view context model =
    context.user
        |> Maybe.map (\user -> viewWithUser user model)
        |> Maybe.withDefault viewWithoutUser


viewWithUser : Business.User.User -> Model -> Html.Html Msg
viewWithUser _ model =
    Html.div []
        [ Html.form [ Html.Events.onSubmit Submit ]
            [ Html.fieldset []
                [ Html.legend [] [ Html.text "Write your thoughts..." ]
                , Html.textarea
                    (Html.Attributes.value model.postInput.raw :: Form.inputEvents WithPostInput)
                    []
                , Html.button [] [ Html.text "Post" ]
                ]
            ]
        ]


viewWithoutUser : Html.Html msg
viewWithoutUser =
    -- TODO: make it good here...
    Html.div [] [ Html.text "Can't see this..." ]


init : Context.Context -> ( Model, Effect.Effect, Cmd msg )
init context =
    let
        effect : Effect.Effect
        effect =
            case context.user of
                Just _ ->
                    Effect.none

                Nothing ->
                    Effect.batch
                        [ Effect.addAlert (Alert.new Alert.Error "FORBIDDEN_AREA")
                        , Effect.redirect "/"
                        ]
    in
    ( { postInput = Form.newInput }
    , effect
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update msg model =
    case msg of
        WithPostInput event ->
            ( { model | postInput = Form.updateInput event Page.plainParser model.postInput }
            , Effect.none
            , Cmd.none
            )

        Submit ->
            Debug.todo "Submit post!"
