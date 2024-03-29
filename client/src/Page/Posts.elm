module Page.Posts exposing
    ( Model
    , Msg
    , PostsLoading
    , TaskOutput
    , TaskPool
    , init
    , subscriptions
    , update
    , view
    )

import Alert
import Browser.Dom
import Browser.Events
import Business.Post
import Business.Post.Content
import Business.User
import Color.Extra
import ConcurrentTask
import ConcurrentTask.Http
import ConcurrentTask.Http.Extra
import Context
import Css
import Css.Animations
import DateFormat
import DateFormat.Extra.Deutsch
import DateFormat.Languages
import Effect
import File
import File.Select
import Form
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Html.Styled.Events as HtmlEvents
import Internal
import Iso8601
import Json.Decode
import Json.Encode
import List.Extra
import Logger
import Page
import Phosphor
import Port
import Task
import Time
import Translations
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
    , postInputHeight : Maybe Float
    , postImages : List String
    , postFormState : Form.FormState
    , posts : List Business.Post.Post
    , loadingState : PostsLoading
    , gallery : ( Int, List String )
    }


type Msg
    = WithPostInput Form.InputEvent
    | GotPostViewport (Result Browser.Dom.Error Browser.Dom.Viewport)
    | RequestImages
    | GotImages File.File (List File.File)
    | GotImagesUrls (Result () (List String))
    | RemoveImage Int
    | Submit
    | Logout
    | Delete String
    | OnTaskProgress ( TaskPool, Cmd Msg )
    | OnTaskComplete (ConcurrentTask.Response Page.TaskError TaskOutput)
    | GalleryOpen (List String) Int
    | GalleryClose
    | GalleryNav Int
    | GalleryKeys String
    | ClearPost
    | Paste (List File.File)
    | NoOp
    | GotPost Json.Decode.Value
    | OnScroll ()
    | GotViewport (Result () Browser.Dom.Viewport)


view : Translations.Helper -> Context.Context -> Model -> Html.Html Msg
view i context model =
    Internal.view i context model viewWithUser


viewWithUser :
    Translations.Helper
    -> Context.Context
    -> Model
    -> Business.User.User
    -> Html.Html Msg
viewWithUser i context model _ =
    let
        ( btnStyles, btnAttrs ) =
            Form.submitBtnByState model.postFormState
    in
    Internal.template i context.theme Logout <|
        Html.div []
            [ Html.form
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
                         , HtmlAttributes.id "post-content"
                         , HtmlAttributes.css
                            [ Css.border <| Css.px 0
                            , Css.borderRadius <| Css.rem 0.5
                            , Css.marginBottom <| Css.rem 1.5
                            , Css.padding <| Css.rem 1
                            , Css.resize Css.none
                            , Css.width <| Css.pct 100
                            , Css.lineHeight <| Css.num 1.5
                            , case model.postInputHeight of
                                Just inputHeight ->
                                    Css.height <| Css.px inputHeight

                                Nothing ->
                                    Css.height <| Css.auto
                            , Css.fontSize <| Css.rem 1
                            ]
                         , HtmlEvents.on "paste"
                            (Json.Decode.map Paste
                                (Json.Decode.field "clipboardData"
                                    (Json.Decode.field "files"
                                        (Json.Decode.list File.decoder)
                                    )
                                )
                            )
                         ]
                            ++ Form.inputEvents WithPostInput
                        )
                        []
                    , case model.postImages of
                        [] ->
                            Html.text ""

                        _ ->
                            Html.div
                                [ HtmlAttributes.css
                                    [ Css.property "display" "grid"
                                    , Css.property "grid-template-columns" "repeat(4, 1fr)"
                                    , Css.property "column-gap" "0.5rem"
                                    , Css.property "row-gap" "0.5rem"
                                    , Css.marginBottom <| Css.rem 0.95
                                    ]
                                ]
                                (model.postImages
                                    |> List.indexedMap
                                        (\index image ->
                                            Html.div [ HtmlAttributes.css [ Css.position Css.relative ] ]
                                                [ Html.img
                                                    [ HtmlAttributes.src image
                                                    , HtmlAttributes.css
                                                        [ Css.width <| Css.pct 100
                                                        , Css.property "aspect-ratio" "1/1"
                                                        , Css.property "object-fit" "cover"
                                                        , Css.display Css.block
                                                        , Css.borderRadius <| Css.rem 0.5
                                                        ]
                                                    ]
                                                    []
                                                , Html.button
                                                    [ HtmlAttributes.type_ "button"
                                                    , HtmlAttributes.css
                                                        [ Css.border <| Css.px 0
                                                        , Css.backgroundColor (context.theme |> View.Theme.errorColor |> Color.Extra.toCss)
                                                        , Css.display Css.block
                                                        , Css.lineHeight <| Css.num 0
                                                        , Css.position Css.absolute
                                                        , Css.top <| Css.px 0
                                                        , Css.right <| Css.px 0
                                                        , Css.color (context.theme |> View.Theme.errorColor |> Color.Extra.toContrast 0.5 |> Color.Extra.toCss)
                                                        , Css.fontSize <| Css.rem 1.5
                                                        , Css.padding <| Css.rem 0.5
                                                        , Css.borderRadius2 (Css.rem 0) (Css.rem 0.5)
                                                        , Css.cursor Css.pointer
                                                        ]
                                                    , HtmlEvents.onClick (RemoveImage index)
                                                    ]
                                                    [ Phosphor.x Phosphor.Bold |> Phosphor.toHtml [] |> Html.fromUnstyled ]
                                                ]
                                        )
                                )
                    , Html.div
                        [ HtmlAttributes.css
                            [ Css.displayFlex
                            , Css.justifyContent Css.spaceBetween
                            ]
                        ]
                        [ Html.button
                            [ HtmlEvents.onClick RequestImages
                            , HtmlAttributes.type_ "button"
                            , HtmlAttributes.css
                                [ Css.border <| Css.px 0
                                , Css.backgroundColor Css.transparent
                                , Css.color (context.theme |> View.Theme.foregroundColor |> Color.Extra.toCss)
                                , Css.fontSize <| Css.rem 2.5
                                , Css.margin <| Css.px 0
                                , Css.padding <| Css.px 0
                                , Css.cursor Css.pointer
                                , Css.display Css.block
                                , Css.lineHeight <| Css.num 0
                                ]
                            ]
                            [ Phosphor.cameraPlus Phosphor.Bold |> Phosphor.toHtml [] |> Html.fromUnstyled ]
                        , Html.div
                            [ HtmlAttributes.css [ Css.displayFlex ] ]
                            [ case buildPostContent model of
                                Ok _ ->
                                    Html.button
                                        [ HtmlAttributes.css
                                            [ View.Style.btn context.theme
                                            , View.Style.btnInverse context.theme
                                            , Css.marginRight <| Css.rem 0.5
                                            ]
                                        , HtmlEvents.onClick ClearPost
                                        , HtmlAttributes.type_ "button"
                                        ]
                                        [ Html.text <| i Translations.ClearPost ]

                                _ ->
                                    Html.text ""
                            , Html.button
                                (HtmlAttributes.css (View.Style.btn context.theme :: btnStyles) :: btnAttrs)
                                [ Html.text <| i Translations.ToPost ]
                            ]
                        ]
                    ]
                ]
            , Html.div []
                (case ( model.posts, model.loadingState ) of
                    ( [], Loaded ) ->
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
                            [ Html.text <| i Translations.NoPost ]
                        ]

                    ( posts, _ ) ->
                        [ Html.div [] (posts |> List.map (viewPost i context.timeZone context.language context.theme))
                        , Html.div []
                            [ loadingIndicator i context.theme model.loadingState ]
                        ]
                )
            , case model.gallery of
                ( _, [] ) ->
                    Html.text ""

                ( index, gallery ) ->
                    viewGallery context.theme index gallery
            ]


asyncLoadPosts : Business.User.User -> List Business.Post.Post -> Cmd.Cmd Msg
asyncLoadPosts user posts =
    posts
        |> List.filterMap
            (\post ->
                case post.content of
                    Business.Post.NotLoaded ->
                        Json.Encode.object
                            [ ( "id", Json.Encode.string post.id )
                            , ( "userToken", Json.Encode.string user.token )
                            , ( "privateKey", user.privateKey )
                            ]
                            |> Port.requestPost
                            |> Just

                    _ ->
                        Nothing
            )
        |> Cmd.batch


viewGallery : View.Theme.Theme -> Int -> List String -> Html.Html Msg
viewGallery theme index gallery =
    let
        image : String
        image =
            List.Extra.getAt index gallery |> Maybe.withDefault ""

        onClickNoPropagation : msg -> Html.Attribute msg
        onClickNoPropagation msg =
            HtmlEvents.stopPropagationOn "click" (Json.Decode.succeed ( msg, True ))
    in
    Html.div
        [ HtmlAttributes.css
            [ Css.position Css.fixed
            , Css.top <| Css.px 0
            , Css.bottom <| Css.px 0
            , Css.left <| Css.px 0
            , Css.right <| Css.px 0
            , Css.backgroundColor (theme |> View.Theme.backgroundColor |> Color.Extra.withAlpha 0.9 |> Color.Extra.toCss)
            , Css.displayFlex
            , Css.alignItems Css.center
            , Css.justifyContent Css.center
            ]
        , HtmlEvents.onClick GalleryClose
        ]
        (Html.img
            [ HtmlAttributes.src image
            , HtmlAttributes.css
                [ Css.maxWidth <| Css.pct 100
                , Css.maxHeight <| Css.pct 85
                , Css.display Css.block
                ]
            , onClickNoPropagation NoOp
            ]
            []
            :: (if List.length gallery > 1 then
                    let
                        navStyle : Css.Style
                        navStyle =
                            Css.batch
                                [ Css.position Css.absolute
                                , Css.top <| Css.px 0
                                , Css.bottom <| Css.px 0
                                , Css.border <| Css.px 0
                                , Css.backgroundColor Css.transparent
                                , Css.color (theme |> View.Theme.textColor |> Color.Extra.toCss)
                                , Css.displayFlex
                                , Css.alignItems Css.center
                                , Css.cursor Css.pointer
                                , Css.fontSize <| Css.rem 2
                                , Css.padding <| Css.rem 1
                                ]
                    in
                    [ Html.button
                        [ HtmlAttributes.css
                            [ navStyle
                            , Css.right <| Css.px 0
                            , Css.justifyContent Css.flexEnd
                            ]
                        , onClickNoPropagation (GalleryNav (index + 1))
                        ]
                        [ Phosphor.arrowRight Phosphor.Regular |> Phosphor.toHtml [] |> Html.fromUnstyled ]
                    , Html.button
                        [ HtmlAttributes.css
                            [ navStyle
                            , Css.left <| Css.px 0
                            , Css.justifyContent Css.flexStart
                            ]
                        , onClickNoPropagation (GalleryNav (index - 1))
                        ]
                        [ Phosphor.arrowLeft Phosphor.Regular |> Phosphor.toHtml [] |> Html.fromUnstyled ]
                    ]

                else
                    []
               )
            ++ [ Html.button
                    [ HtmlAttributes.css
                        [ Css.position Css.absolute
                        , Css.top <| Css.px 0
                        , Css.right <| Css.px 0
                        , Css.border <| Css.px 0
                        , Css.color (theme |> View.Theme.textColor |> Color.Extra.toCss)
                        , Css.backgroundColor Css.transparent
                        , Css.fontSize <| Css.rem 2
                        , Css.cursor Css.pointer
                        , Css.padding <| Css.rem 1
                        , Css.margin <| Css.rem 0
                        , Css.lineHeight <| Css.num 0
                        ]
                    , HtmlEvents.onClick GalleryClose
                    ]
                    [ Phosphor.x Phosphor.Regular |> Phosphor.toHtml [] |> Html.fromUnstyled ]
               ]
        )


loadingIndicator : Translations.Helper -> View.Theme.Theme -> PostsLoading -> Html.Html msg
loadingIndicator i theme loading =
    let
        label : String
        label =
            case loading of
                Loaded ->
                    ""

                Loading ->
                    i Translations.Loading

                NoMore ->
                    i Translations.AllPostsLoaded
    in
    Html.div
        [ HtmlAttributes.css
            [ Css.textAlign Css.center
            , Css.color (theme |> View.Theme.foregroundColor |> Color.Extra.withAlpha 0.5 |> Color.Extra.toCss)
            , Css.marginBottom <| Css.rem 2
            ]
        ]
        [ Html.text label ]


viewPost :
    Translations.Helper
    -> Time.Zone
    -> Translations.Language
    -> View.Theme.Theme
    -> Business.Post.Post
    -> Html.Html Msg
viewPost i timeZone language theme post =
    Html.div
        [ HtmlAttributes.id post.id
        , HtmlAttributes.css
            [ Css.backgroundColor
                (theme
                    |> View.Theme.textColor
                    |> Color.Extra.withAlpha 0.05
                    |> Color.Extra.toCss
                )
            , Css.padding <| Css.rem 1
            , Css.paddingBottom <| Css.px 1
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
            [ Html.div [ HtmlAttributes.css [ Css.displayFlex, Css.alignItems Css.center ] ]
                [ Html.div [ HtmlAttributes.css [ Css.marginRight <| Css.rem 0.5 ] ]
                    [ Phosphor.clock Phosphor.Bold
                        |> Phosphor.withSize 1.5
                        |> Phosphor.withSizeUnit "em"
                        |> Phosphor.toHtml []
                        |> Html.fromUnstyled
                    ]
                , Html.text <| formatDate timeZone language post.createdAt
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
        , Html.div []
            (case post.content of
                Business.Post.Decrypted content ->
                    [ case content.body of
                        "" ->
                            Html.text ""

                        body ->
                            let
                                nodes : List Business.Post.Content.Node
                                nodes =
                                    Business.Post.Content.parse body
                            in
                            Html.div
                                [ HtmlAttributes.css
                                    [ Css.lineHeight <| Css.num 1.5
                                    , Css.fontSize <| Css.rem 1.25
                                    , Css.marginBottom <| Css.rem 1
                                    ]
                                ]
                                (Business.Post.Content.toHtml theme nodes [])
                    , case content.images of
                        [] ->
                            Html.text ""

                        images ->
                            viewPostImages images
                    ]

                Business.Post.NotLoaded ->
                    [ Html.div
                        [ HtmlAttributes.css
                            [ Css.backgroundColor (theme |> View.Theme.textColor |> Color.Extra.withAlpha 0.05 |> Color.Extra.toCss)
                            , Css.borderRadius <| Css.rem 0.5
                            , Css.minHeight <| Css.rem 2
                            , Css.marginBottom <| Css.rem 1
                            , Css.animationName <|
                                Css.Animations.keyframes
                                    [ ( 0, [ Css.Animations.backgroundColor (theme |> View.Theme.textColor |> Color.Extra.withAlpha 0.05 |> Color.Extra.toCss) ] )
                                    , ( 50, [ Css.Animations.backgroundColor (theme |> View.Theme.textColor |> Color.Extra.withAlpha 0.3 |> Color.Extra.toCss) ] )
                                    , ( 100, [ Css.Animations.backgroundColor (theme |> View.Theme.textColor |> Color.Extra.withAlpha 0.05 |> Color.Extra.toCss) ] )
                                    ]
                            , Css.animationIterationCount Css.infinite
                            , Css.property "animation-timing-function" "linear"
                            , Css.animationDuration <| Css.ms 2000
                            ]
                        , HtmlAttributes.title <| i Translations.Loading ++ "..."
                        ]
                        [ Html.text "" ]
                    ]
            )
        ]


viewPostImages : List String -> Html.Html Msg
viewPostImages images =
    let
        ( repeats, aspectRatio ) =
            case List.length images of
                1 ->
                    ( "1", "16/9" )

                2 ->
                    ( "2", "3/4" )

                _ ->
                    ( "3", "1/1" )
    in
    Html.div
        [ HtmlAttributes.css
            [ Css.property "display" "grid"
            , Css.property "grid-template-columns" ("repeat(" ++ repeats ++ ", 1fr)")
            , Css.property "column-gap" "1rem"
            , Css.property "row-gap" "1rem"
            , Css.marginBottom <| Css.rem 1
            ]
        ]
        (images
            |> List.indexedMap
                (\index image ->
                    Html.div []
                        [ Html.img
                            [ HtmlAttributes.src image
                            , HtmlEvents.onClick <| GalleryOpen images index
                            , HtmlAttributes.css
                                [ Css.width <| Css.pct 100
                                , Css.property "aspect-ratio" aspectRatio
                                , Css.property "object-fit" "cover"
                                , Css.display Css.block
                                , Css.borderRadius <| Css.rem 0.5
                                , Css.cursor Css.zoomIn
                                ]
                            ]
                            []
                        ]
                )
        )


formatDate : Time.Zone -> Translations.Language -> String -> String
formatDate timeZone language date =
    date
        |> Iso8601.toTime
        |> Result.toMaybe
        |> Maybe.map
            (\posix ->
                let
                    dateFormatLanguage : DateFormat.Languages.Language
                    dateFormatLanguage =
                        case language of
                            Translations.En ->
                                DateFormat.Languages.english

                            Translations.Pt ->
                                DateFormat.Languages.portuguese

                            Translations.Es ->
                                DateFormat.Languages.spanish

                            Translations.Fr ->
                                DateFormat.Languages.french

                            Translations.De ->
                                DateFormat.Extra.Deutsch.deutsch

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
                                , DateFormat.text " at "
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
                                , DateFormat.text " às "
                                , DateFormat.hourMilitaryFixed
                                , DateFormat.text ":"
                                , DateFormat.minuteFixed
                                ]

                            Translations.Es ->
                                [ DateFormat.dayOfMonthNumber
                                , DateFormat.text " de "
                                , DateFormat.monthNameAbbreviated
                                , DateFormat.text " de "
                                , DateFormat.yearNumber
                                , DateFormat.text " a las "
                                , DateFormat.hourMilitaryFixed
                                , DateFormat.text ":"
                                , DateFormat.minuteFixed
                                ]

                            Translations.Fr ->
                                [ DateFormat.dayOfMonthNumber
                                , DateFormat.text " "
                                , DateFormat.monthNameAbbreviated
                                , DateFormat.text " "
                                , DateFormat.yearNumber
                                , DateFormat.text " à "
                                , DateFormat.hourMilitaryFixed
                                , DateFormat.text ":"
                                , DateFormat.minuteFixed
                                ]

                            Translations.De ->
                                [ DateFormat.dayOfMonthSuffix
                                , DateFormat.text " "
                                , DateFormat.monthNameAbbreviated
                                , DateFormat.text " "
                                , DateFormat.yearNumber
                                , DateFormat.text " um "
                                , DateFormat.hourMilitaryFixed
                                , DateFormat.text ":"
                                , DateFormat.minuteFixed
                                , DateFormat.text " Uhr"
                                ]
                in
                DateFormat.formatWithLanguage dateFormatLanguage dateFormatTokens timeZone posix
            )
        |> Maybe.withDefault ""


loadAllPosts :
    TaskPool
    -> Maybe String
    -> (List Business.Post.Post -> TaskOutput)
    -> Business.User.User
    -> ( TaskPool, Cmd.Cmd Msg )
loadAllPosts tasks from taskOutput user =
    let
        args : Json.Encode.Value
        args =
            case from of
                Nothing ->
                    Json.Encode.object
                        [ ( "userToken", Json.Encode.string user.token )
                        , ( "privateKey", user.privateKey )
                        ]

                Just id ->
                    Json.Encode.object
                        [ ( "userToken", Json.Encode.string user.token )
                        , ( "privateKey", user.privateKey )
                        , ( "from", Json.Encode.string id )
                        ]
    in
    ConcurrentTask.define
        { function = "posts:allPosts"
        , expect = ConcurrentTask.expectJson (Json.Decode.list Business.Post.decode)
        , errors = ConcurrentTask.expectErrors Json.Decode.string
        , args = args
        }
        |> ConcurrentTask.mapError (Translations.keyFromString >> Page.Generic)
        |> ConcurrentTask.map taskOutput
        |> ConcurrentTask.attempt
            { pool = tasks
            , send = Port.taskSend
            , onComplete = OnTaskComplete
            }


init : Translations.Helper -> Context.Context -> ( Model, Effect.Effect, Cmd Msg )
init i context =
    let
        effect : Effect.Effect
        effect =
            Internal.initEffect i context.user

        tasks : TaskPool
        tasks =
            ConcurrentTask.pool

        ( newTasks, cmd ) =
            context.user
                |> Maybe.map (loadAllPosts tasks Nothing PostsLoaded)
                |> Maybe.withDefault ( tasks, Cmd.none )
    in
    ( { tasks = newTasks
      , postInput = Form.newInput
      , postInputHeight = Nothing
      , postImages = []
      , postFormState = Form.Editing
      , posts = []
      , loadingState = Loading
      , gallery = ( 0, [] )
      }
    , effect
    , cmd
    )


update : Translations.Helper -> Context.Context -> Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update i context msg model =
    Internal.update i context msg model updateWithUser


imageMimes : List String
imageMimes =
    [ "image/png", "image/jpg", "image/jpeg" ]


updateWithUser : Translations.Helper -> Msg -> Model -> Business.User.User -> ( Model, Effect.Effect, Cmd Msg )
updateWithUser i msg model user =
    case msg of
        NoOp ->
            ( model, Effect.none, Cmd.none )

        GotPostViewport (Ok { scene, viewport }) ->
            let
                newHeight : Maybe Float
                newHeight =
                    case ( model.postInputHeight, scene.height > viewport.height ) of
                        ( Nothing, False ) ->
                            Nothing

                        ( Nothing, True ) ->
                            Just scene.height

                        ( Just _, False ) ->
                            model.postInputHeight

                        ( Just _, True ) ->
                            Just scene.height
            in
            ( { model | postInputHeight = newHeight }, Effect.none, Cmd.none )

        GotPostViewport (Err _) ->
            ( model, Effect.none, Cmd.none )

        OnScroll () ->
            ( model, Effect.none, Browser.Dom.getViewport |> Task.attempt GotViewport )

        GotViewport res ->
            case res of
                Ok { scene, viewport } ->
                    let
                        maxY : Float
                        maxY =
                            scene.height - viewport.height

                        triggerLoadMore : Bool
                        triggerLoadMore =
                            viewport.y >= (maxY - 200)
                    in
                    case ( triggerLoadMore, model.posts, model.loadingState ) of
                        ( True, _ :: _, Loaded ) ->
                            let
                                from : Maybe String
                                from =
                                    model.posts
                                        |> List.Extra.last
                                        |> Maybe.map .id

                                ( tasks, cmd ) =
                                    loadAllPosts model.tasks from MorePostsLoaded user
                            in
                            ( { model
                                | tasks = tasks
                                , loadingState = Loading
                              }
                            , Effect.toggleLoader
                            , cmd
                            )

                        _ ->
                            ( model, Effect.none, Cmd.none )

                Err _ ->
                    ( model, Effect.none, Cmd.none )

        WithPostInput event ->
            ( { model | postInput = Form.updateInput event Page.nonEmptyInputParser model.postInput }
            , Effect.none
            , Browser.Dom.getViewportOf "post-content" |> Task.attempt GotPostViewport
            )

        RequestImages ->
            ( model
            , Effect.none
            , File.Select.files imageMimes GotImages
            )

        GotImages file files ->
            ( model
            , Effect.none
            , Task.attempt GotImagesUrls (Task.sequence (file :: files |> List.map File.toUrl))
            )

        GotImagesUrls result ->
            case result of
                Ok images ->
                    ( { model | postImages = model.postImages ++ images }, Effect.none, Cmd.none )

                _ ->
                    ( model, Effect.none, Cmd.none )

        RemoveImage index ->
            ( { model | postImages = model.postImages |> List.Extra.removeAt index }
            , Effect.none
            , Cmd.none
            )

        Submit ->
            let
                newModel : Model
                newModel =
                    { model
                        | postInput = Form.parseInput Page.nonEmptyInputParser model.postInput
                        , postFormState = Form.Submitting
                    }
            in
            case buildPostContent newModel of
                Ok postContent ->
                    let
                        ( tasks, cmd ) =
                            ConcurrentTask.define
                                { function = "posts:createPost"
                                , expect = ConcurrentTask.expectJson Business.Post.decode
                                , errors = ConcurrentTask.expectErrors Json.Decode.string
                                , args =
                                    Json.Encode.object
                                        [ ( "privateKey", user.privateKey )
                                        , ( "postContent", Business.Post.encodePostContent postContent )
                                        , ( "userToken", Json.Encode.string user.token )
                                        ]
                                }
                                |> ConcurrentTask.mapError (Translations.keyFromString >> Page.Generic)
                                |> ConcurrentTask.map Posted
                                |> ConcurrentTask.attempt
                                    { pool = model.tasks
                                    , send = Port.taskSend
                                    , onComplete = OnTaskComplete
                                    }
                    in
                    ( { newModel | tasks = tasks }, Effect.toggleLoader, cmd )

                Err errorKey ->
                    ( { newModel | postFormState = Form.Editing }
                    , Effect.addAlert (Alert.new Alert.Error (i errorKey))
                    , Cmd.none
                    )

        Delete hashId ->
            let
                task : ConcurrentTask.ConcurrentTask Page.TaskError TaskOutput
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

        Logout ->
            Internal.logout i model

        OnTaskProgress ( tasks, cmd ) ->
            ( { model | tasks = tasks }, Effect.none, cmd )

        OnTaskComplete (ConcurrentTask.Success (Posted post)) ->
            ( { model
                | posts = post :: model.posts
                , postImages = []
                , postInput = Form.newInput
                , postInputHeight = Nothing
                , postFormState = Form.Editing
              }
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Success <| i Translations.PostNew)
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Success (PostsLoaded posts)) ->
            ( { model | posts = model.posts ++ posts, loadingState = Loaded }
            , Effect.none
            , asyncLoadPosts user posts
            )

        OnTaskComplete (ConcurrentTask.Success (MorePostsLoaded posts)) ->
            let
                loading : PostsLoading
                loading =
                    if posts == [] then
                        NoMore

                    else
                        Loaded
            in
            ( { model | posts = model.posts ++ posts, loadingState = loading }
            , Effect.toggleLoader
            , asyncLoadPosts user posts
            )

        OnTaskComplete (ConcurrentTask.Success (DeleteConfirm confirm)) ->
            case confirm of
                Nothing ->
                    ( model, Effect.none, Cmd.none )

                Just hashId ->
                    let
                        task : ConcurrentTask.ConcurrentTask Page.TaskError TaskOutput
                        task =
                            ConcurrentTask.Http.request
                                { method = "DELETE"
                                , url = "/api/posts/" ++ hashId
                                , headers = [ ConcurrentTask.Http.header "authorization" user.token ]
                                , body = ConcurrentTask.Http.emptyBody
                                , expect = ConcurrentTask.Http.expectWhatever
                                , timeout = Nothing
                                }
                                |> ConcurrentTask.mapError Page.httpErrorMapper
                                |> ConcurrentTask.map BlackHole

                        posts : List Business.Post.Post
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
            ( { model | loadingState = Loaded, postFormState = Form.Editing }
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i errorKey)
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Error (Page.RequestError httpError)) ->
            ( { model | loadingState = Loaded, postFormState = Form.Editing }
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i Translations.RequestError)
                , Effect.toggleLoader
                ]
            , Logger.captureMessage <| ConcurrentTask.Http.Extra.errorToString httpError
            )

        OnTaskComplete (ConcurrentTask.UnexpectedError _) ->
            ( { model | loadingState = Loaded, postFormState = Form.Editing }
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i Translations.RequestError)
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        GalleryOpen gallery index ->
            ( { model | gallery = ( index, gallery ) }, Effect.none, Cmd.none )

        GalleryNav index ->
            let
                nextGallery : ( Int, List String )
                nextGallery =
                    galleryGoTo index model.gallery
            in
            ( { model | gallery = nextGallery }, Effect.none, Cmd.none )

        GalleryClose ->
            ( { model | gallery = ( 0, [] ) }, Effect.none, Cmd.none )

        GalleryKeys key ->
            let
                ( galleryCurrentIndex, _ ) =
                    model.gallery
            in
            case key of
                "ArrowRight" ->
                    ( { model | gallery = galleryGoTo (galleryCurrentIndex + 1) model.gallery }
                    , Effect.none
                    , Cmd.none
                    )

                "ArrowLeft" ->
                    ( { model | gallery = galleryGoTo (galleryCurrentIndex - 1) model.gallery }
                    , Effect.none
                    , Cmd.none
                    )

                "Escape" ->
                    ( { model | gallery = ( 0, [] ) }
                    , Effect.none
                    , Cmd.none
                    )

                _ ->
                    ( model, Effect.none, Cmd.none )

        ClearPost ->
            ( { model | postImages = [], postInput = Form.newInput }, Effect.none, Cmd.none )

        Paste files ->
            case files of
                [] ->
                    ( model, Effect.none, Cmd.none )

                imageFiles ->
                    let
                        filteredFiles : List File.File
                        filteredFiles =
                            imageFiles |> List.filter (\file -> imageMimes |> List.member (File.mime file))
                    in
                    ( model
                    , Effect.none
                    , Task.attempt GotImagesUrls (Task.sequence (filteredFiles |> List.map File.toUrl))
                    )

        GotPost raw ->
            case Json.Decode.decodeValue Business.Post.decode raw of
                Ok post ->
                    let
                        posts : List Business.Post.Post
                        posts =
                            model.posts
                                |> List.map
                                    (\existingPost ->
                                        if existingPost.id == post.id then
                                            post

                                        else
                                            existingPost
                                    )
                    in
                    ( { model | posts = posts }, Effect.none, Cmd.none )

                Err _ ->
                    ( model, Effect.none, Cmd.none )


galleryGoTo : Int -> ( Int, List String ) -> ( Int, List String )
galleryGoTo index gallery =
    let
        ( _, images ) =
            gallery

        lastIndex : Int
        lastIndex =
            List.length images - 1

        nextId : Int
        nextId =
            if index < 0 then
                lastIndex

            else if index > lastIndex then
                0

            else
                index
    in
    ( nextId, images )


buildPostContent : Model -> Result Translations.Key Business.Post.PostContent
buildPostContent model =
    case ( model.postInput.valid, model.postImages ) of
        ( Form.Valid body, images ) ->
            Ok { body = body, images = images }

        ( _, [] ) ->
            Err Translations.InvalidInputs

        ( _, images ) ->
            Ok { body = "", images = images }


keyDecoder : Json.Decode.Decoder Msg
keyDecoder =
    Json.Decode.field "key" Json.Decode.string
        |> Json.Decode.andThen (GalleryKeys >> Json.Decode.succeed)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ ConcurrentTask.onProgress
            { send = Port.taskSend
            , receive = Port.taskReceive
            , onProgress = OnTaskProgress
            }
            model.tasks
        , case model.gallery of
            ( _, [] ) ->
                Sub.none

            _ ->
                Browser.Events.onKeyDown keyDecoder
        , Port.getPost GotPost
        , Port.onScroll OnScroll
        ]
