module Page.Posts exposing (Model, Msg, init, subscriptions, update, view)

import Alert
import Business.Post
import Business.Username
import Context
import Effect
import Form
import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Decode.Extra
import Json.Encode
import Port


type alias Model =
    { postInput : Form.Input String
    , posts : List Business.Post.Post
    }


type Msg
    = WithPostInput Form.InputEvent
    | Submit
    | GotPost Json.Decode.Value


type alias Post =
    { body : String
    }


encodePost : Post -> Json.Encode.Value
encodePost post =
    Json.Encode.object
        [ ( "body", Json.Encode.string post.body )
        ]


view : Context.Context -> Model -> Html.Html Msg
view context model =
    context.user
        |> Maybe.andThen (Business.Username.fromString >> Result.toMaybe)
        |> Maybe.map (\username -> viewWithUser username model)
        |> Maybe.withDefault viewWithoutUser


viewWithUser : Business.Username.Username -> Model -> Html.Html Msg
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


init : ( Model, Cmd msg )
init =
    ( { postInput = Form.newInput
      , posts = []
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update msg model =
    case msg of
        WithPostInput (Form.OnInput raw) ->
            let
                postInput =
                    model.postInput

                newPostInput =
                    { postInput | raw = String.trim raw }
            in
            ( { model | postInput = newPostInput }, Effect.none, Cmd.none )

        WithPostInput _ ->
            ( model, Effect.none, Cmd.none )

        Submit ->
            let
                post =
                    { body = model.postInput.raw }
            in
            ( model, Effect.none, Port.sendPost <| encodePost post )

        GotPost raw ->
            case Json.Decode.decodeValue decodePostResult raw of
                Ok (Ok post) ->
                    ( { model | posts = post :: model.posts }
                    , Effect.addAlert (Alert.new Alert.Success "New post created.")
                    , Cmd.none
                    )

                Ok (Err errorMsg) ->
                    ( model
                    , Effect.addAlert (Alert.new Alert.Error errorMsg)
                    , Cmd.none
                    )

                Err _ ->
                    ( model
                    , Effect.addAlert (Alert.new Alert.Error "There was an error while saving your post. Please, try again.")
                    , Cmd.none
                    )


decodePostResult : Json.Decode.Decoder (Result String Business.Post.Post)
decodePostResult =
    Json.Decode.Extra.result
        Json.Decode.string
        Business.Post.decode


subscriptions : Sub Msg
subscriptions =
    Port.getPost GotPost