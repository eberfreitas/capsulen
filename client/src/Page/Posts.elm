module Page.Posts exposing (Model, Msg, init, subscriptions, update, view)

import Alert
import Business.Post
import Business.User
import ConcurrentTask
import ConcurrentTask.Http
import Context
import Effect
import Form
import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Encode
import Page
import Port


type TaskOutput
    = Posted Business.Post.Post


type alias TaskPool =
    ConcurrentTask.Pool Msg Page.TaskError TaskOutput


type alias Model =
    { tasks : TaskPool
    , postInput : Form.Input String
    }


type Msg
    = WithPostInput Form.InputEvent
    | Submit
    | OnTaskProgress ( TaskPool, Cmd Msg )
    | OnTaskComplete (ConcurrentTask.Response Page.TaskError TaskOutput)


view : Context.Context -> Model -> Html.Html Msg
view context model =
    context.user
        |> Maybe.map (\user -> viewWithUser user model)
        |> Maybe.withDefault (Html.text "")


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


init : Context.Context -> ( Model, Effect.Effect, Cmd msg )
init context =
    let
        effect : Effect.Effect
        effect =
            context.user
                |> Maybe.map (always Effect.none)
                |> Maybe.withDefault
                    (Effect.batch
                        [ Effect.addAlert (Alert.new Alert.Error "FORBIDDEN_AREA")
                        , Effect.redirect "/"
                        ]
                    )
    in
    ( { tasks = ConcurrentTask.pool
      , postInput = Form.newInput
      }
    , effect
    , Cmd.none
    )


update : Context.Context -> Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update context msg model =
    context.user
        |> Maybe.map (updateWithUser msg model)
        |> Maybe.withDefault ( model, Effect.none, Cmd.none )


updateWithUser : Msg -> Model -> Business.User.User -> ( Model, Effect.Effect, Cmd Msg )
updateWithUser msg model user =
    case msg of
        WithPostInput event ->
            ( { model | postInput = Form.updateInput event Page.nonEmptyInputParser model.postInput }
            , Effect.none
            , Cmd.none
            )

        Submit ->
            let
                newModel =
                    { model | postInput = Form.parseInput Page.nonEmptyInputParser model.postInput }
            in
            case buildPostContent newModel of
                Ok postContent ->
                    let
                        encryptPost : ConcurrentTask.ConcurrentTask Page.TaskError String
                        encryptPost =
                            ConcurrentTask.define
                                { function = "posts:encryptPost"
                                , expect = ConcurrentTask.expectString
                                , errors = ConcurrentTask.expectErrors Json.Decode.string
                                , args =
                                    Json.Encode.object
                                        [ ( "privateKey", user.privateKey )
                                        , ( "postContent", Business.Post.encodePostContent postContent )
                                        ]
                                }
                                |> ConcurrentTask.mapError Page.Generic

                        persistPost : String -> ConcurrentTask.ConcurrentTask Page.TaskError TaskOutput
                        persistPost encryptedPost =
                            ConcurrentTask.Http.post
                                { url = "/api/posts"
                                , headers = [ ConcurrentTask.Http.header "authorization" ("Bearer " ++ user.token) ]
                                , body = ConcurrentTask.Http.stringBody "text/plain" encryptedPost
                                , expect = ConcurrentTask.Http.expectJson Business.Post.decode
                                , timeout = Nothing
                                }
                                |> ConcurrentTask.mapError Page.httpErrorMapper
                                |> ConcurrentTask.map Posted

                        postTask =
                            encryptPost |> ConcurrentTask.andThen persistPost

                        ( tasks, cmd ) =
                            ConcurrentTask.attempt
                                { pool = model.tasks
                                , send = Port.taskSend
                                , onComplete = OnTaskComplete
                                }
                                postTask
                    in
                    ( { newModel | tasks = tasks }, Effect.none, cmd )

                Err errorKey ->
                    ( newModel
                    , Effect.addAlert (Alert.new Alert.Error errorKey)
                    , Cmd.none
                    )

        OnTaskProgress ( tasks, cmd ) ->
            ( { model | tasks = tasks }, Effect.none, cmd )

        OnTaskComplete response ->
            let
                _ =
                    Debug.log "res" response
            in
            Page.done model


buildPostContent : Model -> Result String Business.Post.PostContent
buildPostContent model =
    case model.postInput.valid of
        Form.Valid body ->
            Ok { body = body }

        _ ->
            Err "INVALID_INPUTS"


subscriptions : TaskPool -> Sub Msg
subscriptions pool =
    ConcurrentTask.onProgress
        { send = Port.taskSend
        , receive = Port.taskReceive
        , onProgress = OnTaskProgress
        }
        pool
