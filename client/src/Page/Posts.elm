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
import AppUrl
import Browser.Events
import Business.Post
import Business.User
import Color.Extra
import ConcurrentTask
import ConcurrentTask.Http
import ConcurrentTask.Http.Extra
import Context
import Css
import DateFormat
import DateFormat.Extra.Deutsch
import DateFormat.Languages
import Dict
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
import Regex
import Task
import Time
import Translations
import Url
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
    , postImages : List String
    , postFormState : Form.FormState
    , posts : List Business.Post.Post
    , loadingState : PostsLoading
    , gallery : ( Int, List String )
    }


type Msg
    = WithPostInput Form.InputEvent
    | RequestImages
    | GotImages File.File (List File.File)
    | GotImagesUrls (Result () (List String))
    | RemoveImage Int
    | Submit
    | LoadMore
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
                         , HtmlAttributes.css
                            [ Css.border <| Css.px 0
                            , Css.borderRadius <| Css.rem 0.5
                            , Css.marginBottom <| Css.rem 1.5
                            , Css.padding <| Css.rem 1
                            , Css.resize Css.vertical
                            , Css.width <| Css.pct 100
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
                                    [ Css.display Css.grid_
                                    , Css.property "grid-template-columns" "repeat(4, 1fr)"
                                    , Css.columnGap <| Css.rem 0.5
                                    , Css.rowGap <| Css.rem 0.5
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
                                                        , Css.objectFit Css.cover
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
                            [ Css.display Css.flex_
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
                            [ HtmlAttributes.css [ Css.display Css.flex_ ] ]
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
                        [ Html.div [] (posts |> List.map (viewPost context.timeZone context.language context.theme))
                        , Html.div []
                            [ loadMoreBtn i context.theme model.loadingState ]
                        ]
                )
            , case model.gallery of
                ( _, [] ) ->
                    Html.text ""

                ( index, gallery ) ->
                    viewGallery context.theme index gallery
            ]


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
            , Css.display Css.flex_
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
                                , Css.display Css.flex_
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

        btnStyle : Css.Style
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


viewPost : Time.Zone -> Translations.Language -> View.Theme.Theme -> Business.Post.Post -> Html.Html Msg
viewPost timeZone language theme post =
    Html.div
        [ HtmlAttributes.css
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
            [ Html.div [ HtmlAttributes.css [ Css.display Css.flex_, Css.alignItems Css.center ] ]
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
                            Html.div
                                [ HtmlAttributes.css
                                    [ Css.lineHeight <| Css.num 1.5
                                    , Css.fontSize <| Css.rem 1.25
                                    , Css.marginBottom <| Css.rem 1
                                    ]
                                ]
                                (processBody theme body)
                    , case content.images of
                        [] ->
                            Html.text ""

                        images ->
                            viewPostImages images
                    ]

                Business.Post.Encrypted ->
                    [ Html.text "" ]
            )
        ]


processBody : View.Theme.Theme -> String -> List (Html.Html msg)
processBody theme body =
    let
        urlRegex : Regex.Regex
        urlRegex =
            Regex.fromString "^(https?:\\/\\/[^\\s]+)$"
                |> Maybe.withDefault Regex.never

        embedLink : String -> Html.Html msg
        embedLink url =
            Html.a
                [ HtmlAttributes.href url
                , HtmlAttributes.target "_blank"
                , HtmlAttributes.rel "noreferrer"
                , HtmlAttributes.css [ Css.color (theme |> View.Theme.textColor |> Color.Extra.toCss) ]
                ]
                [ Html.text url ]

        embedLinks : String -> List (Html.Html msg)
        embedLinks str =
            let
                mapperFn : String -> Html.Html msg
                mapperFn word =
                    if isUrl word then
                        embedLink word

                    else
                        Html.text word
            in
            str
                |> String.words
                |> List.map mapperFn
                |> List.intersperse (Html.text " ")

        embedYouTube : String -> Html.Html msg
        embedYouTube url =
            let
                videoId : Maybe String
                videoId =
                    url
                        |> Url.fromString
                        |> Maybe.map AppUrl.fromUrl
                        |> Maybe.andThen (.queryParameters >> Dict.get "v")
                        |> Maybe.andThen (List.Extra.getAt 0)
            in
            case videoId of
                Just videoId_ ->
                    Html.div []
                        [ Html.a
                            [ HtmlAttributes.href url
                            , HtmlAttributes.target "_blank"
                            , HtmlAttributes.rel "noreferrer"
                            , HtmlAttributes.css [ Css.display Css.block, Css.position Css.relative ]
                            ]
                            [ Html.img
                                [ HtmlAttributes.src <| "https://img.youtube.com/vi/" ++ videoId_ ++ "/hqdefault.jpg"
                                , HtmlAttributes.css
                                    [ Css.display Css.block
                                    , Css.width <| Css.pct 100
                                    , Css.property "aspect-ratio" "16/9"
                                    , Css.objectFit Css.cover
                                    , Css.borderRadius <| Css.rem 0.5
                                    ]
                                ]
                                []
                            , Html.div
                                [ HtmlAttributes.css
                                    [ Css.backgroundColor <| Css.hex "#F00"
                                    , Css.color <| Css.hex "#FFF"
                                    , Css.position Css.absolute
                                    , Css.top <| Css.px 0
                                    , Css.right <| Css.px 0
                                    , Css.fontSize <| Css.rem 4
                                    , Css.lineHeight <| Css.num 0
                                    , Css.padding2 (Css.rem 0.5) (Css.rem 1)
                                    , Css.borderRadius2 (Css.px 0) (Css.rem 0.5)
                                    ]
                                ]
                                [ Phosphor.youtubeLogo Phosphor.Regular |> Phosphor.toHtml [] |> Html.fromUnstyled ]
                            ]
                        ]

                Nothing ->
                    embedLink url

        embedImage : String -> Html.Html msg
        embedImage url =
            Html.div
                [ HtmlAttributes.css
                    [ Css.display Css.flex_
                    , Css.justifyContent Css.center
                    ]
                ]
                [ Html.a
                    [ HtmlAttributes.css [ Css.display Css.block ]
                    , HtmlAttributes.href url
                    , HtmlAttributes.target "_blank"
                    , HtmlAttributes.rel "noreferrer"
                    ]
                    [ Html.img
                        [ HtmlAttributes.src url
                        , HtmlAttributes.css
                            [ Css.display Css.block
                            , Css.maxWidth <| Css.pct 100
                            , Css.borderRadius <| Css.rem 0.5
                            ]
                        ]
                        []
                    ]
                ]

        isYouTube : String -> Bool
        isYouTube url =
            let
                youtubeDomains : List String
                youtubeDomains =
                    [ "https://www.youtube.com", "https://youtu.be" ]
            in
            youtubeDomains
                |> List.map (\domain -> String.startsWith domain url)
                |> List.member True

        isImage : String -> Bool
        isImage url =
            let
                imageExtensions : List String
                imageExtensions =
                    [ "png", "jpg", "jpeg", "gif", "webp" ]

                urlPath : String
                urlPath =
                    url
                        |> Url.fromString
                        |> Maybe.map .path
                        |> Maybe.withDefault ""
            in
            imageExtensions
                |> List.map (\ext -> String.endsWith ext urlPath)
                |> List.member True

        isUrl : String -> Bool
        isUrl str =
            let
                schemes : List String
                schemes =
                    [ "http://", "https://" ]
            in
            schemes
                |> List.map (\scheme -> String.startsWith scheme str)
                |> List.member True
    in
    body
        |> String.lines
        |> List.foldr
            (\line html ->
                if String.trim line == "" then
                    Html.br [] [] :: html

                else if Regex.contains urlRegex line then
                    if isYouTube line then
                        embedYouTube line :: html

                    else if isImage line then
                        embedImage line :: html

                    else
                        embedLink line :: Html.br [] [] :: html

                else
                    embedLinks line ++ (Html.br [] [] :: html)
            )
            []


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
            [ Css.display Css.grid_
            , Css.property "grid-template-columns" ("repeat(" ++ repeats ++ ", 1fr)")
            , Css.columnGap <| Css.rem 1
            , Css.rowGap <| Css.rem 1
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
                                , Css.objectFit Css.cover
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
            Internal.initEffect i context.user

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

        WithPostInput event ->
            ( { model | postInput = Form.updateInput event Page.nonEmptyInputParser model.postInput }
            , Effect.none
            , Cmd.none
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
            Internal.logout i model

        OnTaskProgress ( tasks, cmd ) ->
            ( { model | tasks = tasks }, Effect.none, cmd )

        OnTaskComplete (ConcurrentTask.Success (Posted post)) ->
            ( { model
                | posts = post :: model.posts
                , postImages = []
                , postInput = Form.newInput
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
                        task : ConcurrentTask.ConcurrentTask Page.TaskError TaskOutput
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
        ]
