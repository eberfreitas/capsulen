module Page.Posts exposing (Model, Msg, init, subscriptions, update, view)

import Alert
import Business.Post exposing (Content(..))
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
import List.Extra
import Page
import Port
import View.Logo
import View.Theme


type TaskOutput
    = Posted Business.Post.Post
    | PostsLoaded (List Business.Post.Post)
    | MorePostsLoaded (List Business.Post.Post)


type alias TaskPool =
    ConcurrentTask.Pool Msg Page.TaskError TaskOutput


type alias Model =
    { tasks : TaskPool
    , postInput : Form.Input String
    , posts : List Business.Post.Post
    }


type Msg
    = WithPostInput Form.InputEvent
    | Submit
    | LoadMore
    | Logout
    | OnTaskProgress ( TaskPool, Cmd Msg )
    | OnTaskComplete (ConcurrentTask.Response Page.TaskError TaskOutput)


view : (String -> String) -> Context.Context -> Model -> Html.Html Msg
view i context model =
    context.user
        |> Maybe.map (\user -> viewWithUser i user context model)
        |> Maybe.withDefault (Html.text "")


viewWithUser :
    (String -> String)
    -> Business.User.User
    -> Context.Context
    -> Model
    -> Html.Html Msg
viewWithUser i _ context model =
    Html.div [ Html.Attributes.class "posts" ]
        [ Html.div [ Html.Attributes.class "posts__header" ]
            [ Html.div []
                [ View.Logo.logo 40 <| View.Theme.foregroundColor context.theme ]
            , Html.div [ Html.Attributes.class "posts__logout" ]
                [ Html.button
                    [ Html.Events.onClick Logout
                    , Html.Attributes.class "btn btn--inverse btn--short"
                    ]
                    [ Html.text <| i "LOGOUT" ]
                ]
            ]
        , Html.form [ Html.Events.onSubmit Submit, Html.Attributes.class "posts__form" ]
            [ Html.fieldset []
                [ Html.legend [] [ Html.text <| i "POST_ABOUT" ]
                , Html.textarea
                    ([ Html.Attributes.value model.postInput.raw
                     , Html.Attributes.class "posts__textarea"
                     ]
                        ++ Form.inputEvents WithPostInput
                    )
                    []
                , Html.button [ Html.Attributes.class "btn" ] [ Html.text <| i "TO_POST" ]
                ]
            ]
        , hr
        , Html.div [] (model.posts |> List.map (viewPost i))
        , Html.div []
            [ Html.button
                [ Html.Events.onClick LoadMore, Html.Attributes.class "btn btn--full" ]
                [ Html.text <| i "LOAD_MORE_POSTS" ]
            ]
        ]


viewPost : (String -> String) -> Business.Post.Post -> Html.Html Msg
viewPost i post =
    Html.div []
        [ Html.p [] [ Html.text post.createdAt ]
        , case post.content of
            Business.Post.Decrypted content ->
                Html.div []
                    (content.body
                        |> String.lines
                        |> List.map
                            (\line ->
                                if line == "" then
                                    Html.br [] []

                                else
                                    Html.text line
                            )
                    )

            Business.Post.Encrypted _ ->
                Html.div [] [ Html.text <| i "POST_ENCRYPTED" ]
        , hr
        ]


hr : Html.Html msg
hr =
    Html.div [ Html.Attributes.class "hr" ] []


loadPosts :
    (List Business.Post.Post -> TaskOutput)
    -> String
    -> Business.User.User
    -> ConcurrentTask.ConcurrentTask Page.TaskError TaskOutput
loadPosts output url user =
    let
        getPosts : ConcurrentTask.ConcurrentTask Page.TaskError Json.Decode.Value
        getPosts =
            ConcurrentTask.Http.get
                { url = url
                , headers = [ ConcurrentTask.Http.header "authorization" user.token ]
                , expect = ConcurrentTask.Http.expectJson Json.Decode.value
                , timeout = Nothing
                }
                |> ConcurrentTask.mapError Page.httpErrorMapper

        decryptPosts : Json.Decode.Value -> ConcurrentTask.ConcurrentTask Page.TaskError (List Business.Post.Post)
        decryptPosts value =
            ConcurrentTask.define
                { function = "posts:decryptPosts"
                , expect = ConcurrentTask.expectJson (Json.Decode.list Business.Post.decode)
                , errors = ConcurrentTask.expectErrors Json.Decode.string
                , args =
                    Json.Encode.object
                        [ ( "privateKey", user.privateKey )
                        , ( "posts", value )
                        ]
                }
                |> ConcurrentTask.mapError Page.Generic
    in
    getPosts
        |> ConcurrentTask.andThen decryptPosts
        |> ConcurrentTask.map output


init : Context.Context -> ( Model, Effect.Effect, Cmd Msg )
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

        tasks : TaskPool
        tasks =
            ConcurrentTask.pool

        ( newTasks, cmd ) =
            context.user
                |> Maybe.map
                    (\user ->
                        ConcurrentTask.attempt
                            { pool = tasks
                            , send = Port.taskSend
                            , onComplete = OnTaskComplete
                            }
                            (loadPosts PostsLoaded "/api/posts" user)
                    )
                |> Maybe.withDefault ( tasks, Cmd.none )
    in
    ( { tasks = newTasks
      , postInput = Form.newInput
      , posts = []
      }
    , effect
    , cmd
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
                                |> ConcurrentTask.map (\post -> Posted { post | content = Business.Post.Decrypted postContent })

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
                    ( { newModel | tasks = tasks }, Effect.toggleLoader, cmd )

                Err errorKey ->
                    ( newModel
                    , Effect.addAlert (Alert.new Alert.Error errorKey)
                    , Cmd.none
                    )

        LoadMore ->
            let
                url =
                    model.posts
                        |> List.Extra.last
                        |> Maybe.map .id
                        |> Maybe.map ((++) "/api/posts?from=")
                        |> Maybe.withDefault "/api/posts"

                ( tasks, cmd ) =
                    ConcurrentTask.attempt
                        { pool = model.tasks
                        , send = Port.taskSend
                        , onComplete = OnTaskComplete
                        }
                        (loadPosts MorePostsLoaded url user)
            in
            ( { model | tasks = tasks }, Effect.toggleLoader, cmd )

        Logout ->
            ( model
            , Effect.batch
                [ Effect.logout
                , Effect.redirect "/"
                , Effect.addAlert (Alert.new Alert.Success "LOGOUT_SUCCESS")
                ]
            , Cmd.none
            )

        OnTaskProgress ( tasks, cmd ) ->
            ( { model | tasks = tasks }, Effect.none, cmd )

        OnTaskComplete (ConcurrentTask.Success (Posted post)) ->
            ( { model | posts = post :: model.posts, postInput = Form.newInput }
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Success "POST_NEW")
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Success (PostsLoaded posts)) ->
            ( { model | posts = model.posts ++ posts }
            , Effect.none
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Success (MorePostsLoaded posts)) ->
            let
                effect =
                    if posts == [] then
                        Effect.addAlert (Alert.new Alert.Warning "POSTS_NO_MORE")

                    else
                        Effect.none
            in
            ( { model | posts = model.posts ++ posts }
            , Effect.batch [ effect, Effect.toggleLoader ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Error (Page.Generic errorMsgKey)) ->
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error errorMsgKey)
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Error (Page.RequestError _)) ->
            -- TODO: send error to monitoring tool
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error "REQUEST_ERROR")
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.UnexpectedError _) ->
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error "REQUEST_ERROR")
                , Effect.toggleLoader
                ]
            , Cmd.none
            )


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
