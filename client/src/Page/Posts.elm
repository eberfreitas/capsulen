module Page.Posts exposing (Model, Msg, TaskOutput, TaskPool, init, subscriptions, update, view)

import Alert
import Business.Post
import Business.User
import Color.Extra
import ConcurrentTask
import ConcurrentTask.Http
import Context
import Css
import DateFormat
import DateFormat.Languages
import Effect
import Form
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Html.Styled.Events as HtmlEvents
import Iso8601
import Json.Decode
import Json.Encode
import List.Extra
import Page
import Phosphor
import Port
import Time
import Translations
import View.Logo
import View.Style
import View.Theme


type TaskOutput
    = Posted Business.Post.Post
    | PostsLoaded (List Business.Post.Post)
    | MorePostsLoaded (List Business.Post.Post)
    | DeleteConfirm (Maybe String)
    | BlackHole ()


type alias TaskPool =
    ConcurrentTask.Pool Msg Page.TaskError TaskOutput


type PostsLoading
    = Loading
    | Loaded
    | NoMore


type alias Model =
    { tasks : TaskPool
    , postInput : Form.Input String
    , posts : List Business.Post.Post
    , loadingState : PostsLoading
    }


type Msg
    = WithPostInput Form.InputEvent
    | Submit
    | LoadMore
    | Logout
    | Delete String
    | OnTaskProgress ( TaskPool, Cmd Msg )
    | OnTaskComplete (ConcurrentTask.Response Page.TaskError TaskOutput)


view : Translations.Helper -> Context.Context -> Model -> Html.Html Msg
view i context model =
    context.user
        |> Maybe.map (\user -> viewWithUser i user context model)
        |> Maybe.withDefault (Html.text "")


viewWithUser :
    Translations.Helper
    -> Business.User.User
    -> Context.Context
    -> Model
    -> Html.Html Msg
viewWithUser i _ context model =
    Html.div
        [ HtmlAttributes.css
            [ Css.maxWidth <| Css.px 600
            , Css.width <| Css.pct 100
            ]
        ]
        [ Html.div [ HtmlAttributes.css [ Css.marginBottom <| Css.rem 2, Css.position Css.relative ] ]
            [ Html.div []
                [ View.Logo.logo 40 <| View.Theme.foregroundColor context.theme ]
            , Html.div
                [ HtmlAttributes.css
                    [ Css.position Css.absolute
                    , Css.right <| Css.px 0
                    , Css.top <| Css.px 0
                    ]
                ]
                [ Html.button
                    [ HtmlEvents.onClick Logout
                    , HtmlAttributes.css
                        [ View.Style.btn context.theme
                        , View.Style.btnInverse context.theme
                        , View.Style.btnShort
                        ]
                    ]
                    [ Html.text <| i Translations.Logout ]
                ]
            ]
        , Html.form
            [ HtmlEvents.onSubmit Submit
            , HtmlAttributes.css [ Css.marginBottom <| Css.rem 1.5 ]
            ]
            [ Html.fieldset
                [ HtmlAttributes.css
                    [ Css.border <| Css.px 0
                    , Css.margin <| Css.px 0
                    , Css.padding <| Css.px 0
                    ]
                ]
                [ Html.legend
                    [ HtmlAttributes.css
                        [ Css.color (context.theme |> View.Theme.foregroundColor |> Color.Extra.toCss)
                        , Css.display Css.block
                        , Css.fontVariant Css.allPetiteCaps
                        , Css.marginBottom <| Css.rem 0.5
                        , Css.width <| Css.pct 100
                        ]
                    ]
                    [ Html.text <| i Translations.PostAbout ]
                , Html.textarea
                    ([ HtmlAttributes.value model.postInput.raw
                     , HtmlAttributes.css
                        [ Css.border <| Css.px 0
                        , Css.borderRadius <| Css.rem 0.5
                        , Css.marginBottom <| Css.rem 1.5
                        , Css.padding <| Css.rem 1
                        , Css.resize Css.vertical
                        , Css.width <| Css.pct 100
                        ]
                     ]
                        ++ Form.inputEvents WithPostInput
                    )
                    []
                , Html.button [ HtmlAttributes.css [ View.Style.btn context.theme ] ]
                    [ Html.text <| i Translations.ToPost ]
                ]
            ]
        , Html.div []
            (case model.posts of
                [] ->
                    [ Html.div
                        [ HtmlAttributes.css
                            [ Css.fontSize <| Css.rem 2
                            , Css.textAlign Css.center
                            , Css.fontWeight Css.bold
                            , Css.color
                                (context.theme
                                    |> View.Theme.textColor
                                    |> Color.Extra.withAlpha 0.5
                                    |> Color.Extra.toCss
                                )
                            ]
                        ]
                        [ Html.text "No posts" ]
                    ]

                posts ->
                    [ Html.div [] (posts |> List.map (viewPost context.language context.theme))
                    , Html.div []
                        [ loadMoreBtn i context.theme model.loadingState ]
                    ]
            )
        ]


loadMoreBtn : Translations.Helper -> View.Theme.Theme -> PostsLoading -> Html.Html Msg
loadMoreBtn i theme loading =
    let
        ( disabled, label ) =
            case loading of
                Loaded ->
                    ( False, Translations.LoadMorePosts )

                Loading ->
                    ( True, Translations.Loading )

                NoMore ->
                    ( True, Translations.AllPostsLoaded )

        btnStyle =
            if disabled then
                View.Style.btnDisabled

            else
                Css.batch []
    in
    Html.button
        [ HtmlEvents.onClick LoadMore
        , HtmlAttributes.css [ View.Style.btn theme, View.Style.btnFull, btnStyle ]
        , HtmlAttributes.disabled disabled
        ]
        [ Html.text <| i label ]


viewPost : Translations.Language -> View.Theme.Theme -> Business.Post.Post -> Html.Html Msg
viewPost language theme post =
    Html.div
        [ HtmlAttributes.css
            [ Css.backgroundColor
                (theme
                    |> View.Theme.textColor
                    |> Color.Extra.withAlpha 0.05
                    |> Color.Extra.toCss
                )
            , Css.padding <| Css.rem 1
            , Css.marginBottom <| Css.rem 1.5
            , Css.borderRadius <| Css.rem 0.5
            ]
        ]
        [ Html.div
            [ HtmlAttributes.css
                [ Css.marginBottom <| Css.rem 1
                , Css.fontSize <| Css.rem 0.75
                , Css.position Css.relative
                , Css.color (theme |> View.Theme.textColor |> Color.Extra.withAlpha 0.5 |> Color.Extra.toCss)
                ]
            ]
            [ Html.div [ HtmlAttributes.css [ Css.display Css.flex_, Css.alignItems Css.center ] ]
                [ Html.div [ HtmlAttributes.css [ Css.marginRight <| Css.rem 0.5 ] ]
                    [ Phosphor.clock Phosphor.Bold
                        |> Phosphor.withSize 1.5
                        |> Phosphor.withSizeUnit "em"
                        |> Phosphor.toHtml []
                        |> Html.fromUnstyled
                    ]
                , Html.text <| formatDate language post.createdAt
                ]
            , Html.div
                [ HtmlAttributes.css
                    [ Css.position Css.absolute
                    , Css.right <| Css.px 0
                    , Css.top <| Css.px 0
                    ]
                ]
                [ Html.button
                    [ HtmlAttributes.css
                        [ Css.backgroundColor Css.transparent
                        , Css.border <| Css.px 0
                        , Css.color (theme |> View.Theme.textColor |> Color.Extra.withAlpha 0.5 |> Color.Extra.toCss)
                        , Css.cursor Css.pointer
                        ]
                    , HtmlEvents.onClick <| Delete post.id
                    ]
                    [ Phosphor.trash Phosphor.Bold
                        |> Phosphor.withSize 1.5
                        |> Phosphor.withSizeUnit "em"
                        |> Phosphor.toHtml []
                        |> Html.fromUnstyled
                    ]
                ]
            ]
        , case post.content of
            Business.Post.Decrypted content ->
                Html.div
                    [ HtmlAttributes.css
                        [ Css.lineHeight <| Css.num 1.5
                        , Css.fontSize <| Css.rem 1.25
                        ]
                    ]
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

            Business.Post.Encrypted ->
                Html.text ""
        ]


formatDate : Translations.Language -> String -> String
formatDate language date =
    let
        dateFormatLanguage : DateFormat.Languages.Language
        dateFormatLanguage =
            case language of
                Translations.En ->
                    DateFormat.Languages.english

                Translations.Pt ->
                    DateFormat.Languages.portuguese

        dateFormatTokens : List DateFormat.Token
        dateFormatTokens =
            case language of
                Translations.En ->
                    [ DateFormat.dayOfWeekNameAbbreviated
                    , DateFormat.text ", "
                    , DateFormat.monthNameAbbreviated
                    , DateFormat.text " "
                    , DateFormat.dayOfMonthSuffix
                    , DateFormat.text ", "
                    , DateFormat.yearNumber
                    , DateFormat.text " - "
                    , DateFormat.hourFixed
                    , DateFormat.text ":"
                    , DateFormat.minuteFixed
                    , DateFormat.text " "
                    , DateFormat.amPmUppercase
                    ]

                Translations.Pt ->
                    [ DateFormat.dayOfWeekNameAbbreviated
                    , DateFormat.text ", "
                    , DateFormat.dayOfMonthFixed
                    , DateFormat.text " de "
                    , DateFormat.monthNameAbbreviated
                    , DateFormat.text " de "
                    , DateFormat.yearNumber
                    , DateFormat.text " - "
                    , DateFormat.hourMilitaryFixed
                    , DateFormat.text ":"
                    , DateFormat.minuteFixed
                    ]
    in
    date
        |> Iso8601.toTime
        |> Result.toMaybe
        |> Maybe.map
            (\posix ->
                DateFormat.formatWithLanguage dateFormatLanguage dateFormatTokens Time.utc posix
            )
        |> Maybe.withDefault ""


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
                |> ConcurrentTask.mapError (Translations.keyFromString >> Page.Generic)
    in
    getPosts
        |> ConcurrentTask.andThen decryptPosts
        |> ConcurrentTask.map output


init : Translations.Helper -> Context.Context -> ( Model, Effect.Effect, Cmd Msg )
init i context =
    let
        effect : Effect.Effect
        effect =
            context.user
                |> Maybe.map (always Effect.none)
                |> Maybe.withDefault
                    (Effect.batch
                        [ Effect.addAlert (Alert.new Alert.Error <| i Translations.ForbiddenArea)
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
      , loadingState = Loading
      }
    , effect
    , cmd
    )


update : Translations.Helper -> Context.Context -> Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update i context msg model =
    context.user
        |> Maybe.map (updateWithUser i msg model)
        |> Maybe.withDefault ( model, Effect.none, Cmd.none )


updateWithUser : Translations.Helper -> Msg -> Model -> Business.User.User -> ( Model, Effect.Effect, Cmd Msg )
updateWithUser i msg model user =
    case msg of
        WithPostInput event ->
            ( { model | postInput = Form.updateInput event Page.nonEmptyInputParser model.postInput }
            , Effect.none
            , Cmd.none
            )

        Submit ->
            let
                newModel : Model
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
                                |> ConcurrentTask.mapError (Translations.keyFromString >> Page.Generic)

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

                        postTask : ConcurrentTask.ConcurrentTask Page.TaskError TaskOutput
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
                    , Effect.addAlert (Alert.new Alert.Error (i errorKey))
                    , Cmd.none
                    )

        Delete hashId ->
            let
                task =
                    ConcurrentTask.define
                        { function = "posts:deleteConfirm"
                        , expect = ConcurrentTask.expectJson (Json.Decode.nullable Json.Decode.string)
                        , errors = ConcurrentTask.expectNoErrors
                        , args =
                            Json.Encode.object
                                [ ( "hashId", Json.Encode.string hashId )
                                , ( "confirmText", Json.Encode.string (i Translations.DeleteConfirm) )
                                ]
                        }
                        |> ConcurrentTask.mapError (Translations.keyFromString >> Page.Generic)
                        |> ConcurrentTask.map DeleteConfirm

                ( tasks, cmd ) =
                    ConcurrentTask.attempt
                        { pool = model.tasks
                        , send = Port.taskSend
                        , onComplete = OnTaskComplete
                        }
                        task
            in
            ( { model | tasks = tasks }, Effect.none, cmd )

        LoadMore ->
            let
                url : String
                url =
                    model.posts
                        |> List.Extra.last
                        |> Maybe.map .id
                        |> Maybe.map (\id -> "/api/posts?from=" ++ id)
                        |> Maybe.withDefault "/api/posts"

                ( tasks, cmd ) =
                    ConcurrentTask.attempt
                        { pool = model.tasks
                        , send = Port.taskSend
                        , onComplete = OnTaskComplete
                        }
                        (loadPosts MorePostsLoaded url user)
            in
            ( { model | tasks = tasks, loadingState = Loading }, Effect.toggleLoader, cmd )

        Logout ->
            ( model
            , Effect.batch
                [ Effect.logout
                , Effect.redirect "/"
                , Effect.addAlert (Alert.new Alert.Success <| i Translations.LogoutSuccess)
                ]
            , Cmd.none
            )

        OnTaskProgress ( tasks, cmd ) ->
            ( { model | tasks = tasks }, Effect.none, cmd )

        OnTaskComplete (ConcurrentTask.Success (Posted post)) ->
            ( { model | posts = post :: model.posts, postInput = Form.newInput }
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Success <| i Translations.PostNew)
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Success (PostsLoaded posts)) ->
            ( { model | posts = model.posts ++ posts, loadingState = Loaded }
            , Effect.none
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Success (MorePostsLoaded posts)) ->
            let
                ( effect, loading ) =
                    if posts == [] then
                        ( Effect.addAlert (Alert.new Alert.Warning <| i Translations.PostsNoMore)
                        , NoMore
                        )

                    else
                        ( Effect.none, Loaded )
            in
            ( { model | posts = model.posts ++ posts, loadingState = loading }
            , Effect.batch [ effect, Effect.toggleLoader ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Success (DeleteConfirm confirm)) ->
            case confirm of
                Nothing ->
                    ( model, Effect.none, Cmd.none )

                Just hashId ->
                    let
                        task =
                            ConcurrentTask.Http.post
                                { url = "/api/posts/" ++ hashId
                                , headers = [ ConcurrentTask.Http.header "authorization" user.token ]
                                , body = ConcurrentTask.Http.emptyBody
                                , expect = ConcurrentTask.Http.expectWhatever
                                , timeout = Nothing
                                }
                                |> ConcurrentTask.mapError Page.httpErrorMapper
                                |> ConcurrentTask.map BlackHole

                        posts =
                            model.posts |> List.filter (\post -> post.id /= hashId)

                        ( tasks, cmd ) =
                            ConcurrentTask.attempt
                                { pool = model.tasks
                                , send = Port.taskSend
                                , onComplete = OnTaskComplete
                                }
                                task
                    in
                    ( { model | posts = posts, tasks = tasks }, Effect.none, cmd )

        OnTaskComplete (ConcurrentTask.Success (BlackHole ())) ->
            ( model, Effect.none, Cmd.none )

        OnTaskComplete (ConcurrentTask.Error (Page.Generic errorKey)) ->
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i errorKey)
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Error (Page.RequestError _)) ->
            -- TODO: send error to monitoring tool
            ( { model | loadingState = Loaded }
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i Translations.RequestError)
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.UnexpectedError _) ->
            ( { model | loadingState = Loaded }
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i Translations.RequestError)
                , Effect.toggleLoader
                ]
            , Cmd.none
            )


buildPostContent : Model -> Result Translations.Key Business.Post.PostContent
buildPostContent model =
    case model.postInput.valid of
        Form.Valid body ->
            Ok { body = body }

        _ ->
            Err Translations.InvalidInputs


subscriptions : TaskPool -> Sub Msg
subscriptions pool =
    ConcurrentTask.onProgress
        { send = Port.taskSend
        , receive = Port.taskReceive
        , onProgress = OnTaskProgress
        }
        pool
