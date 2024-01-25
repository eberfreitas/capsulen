module Page.Settings exposing (Model, Msg, init, update, view)

import Business.User
import Color.Extra
import Context
import Css
import Effect
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Html.Styled.Events as HtmlEvents
import Internal
import LocalStorage
import Translations
import View.Style
import View.Theme


type Msg
    = Logout
    | Language Translations.Language
    | Theme View.Theme.Theme
    | AutoLogout Bool


type alias Model =
    ()


type alias Option a =
    ( a, Translations.Key )


view : Translations.Helper -> Context.Context -> Model -> Html.Html Msg
view i context model =
    Internal.view i context model viewWithUser


viewWithUser :
    Translations.Helper
    -> Context.Context
    -> Model
    -> Business.User.User
    -> Html.Html Msg
viewWithUser i context _ _ =
    Internal.template i context.theme Logout <|
        Html.div []
            [ Html.h1
                [ HtmlAttributes.css
                    [ Css.color (context.theme |> View.Theme.foregroundColor |> Color.Extra.toCss)
                    , Css.textAlign Css.center
                    , Css.fontSize <| Css.rem 2
                    , Css.fontWeight Css.bold
                    , Css.marginBottom <| Css.rem 2
                    , Css.width <| Css.pct 100
                    ]
                ]
                [ Html.text <| i Translations.Settings ]
            , Html.div [ HtmlAttributes.css [ Css.marginBottom <| Css.rem 2 ] ]
                [ Html.a
                    [ HtmlAttributes.css
                        [ View.Style.btn context.theme
                        , View.Style.btnInverse context.theme
                        , View.Style.btnFull
                        ]
                    , HtmlAttributes.href "/invites"
                    ]
                    [ Html.text <| i Translations.InviteCode ]
                ]
            , Html.div [ HtmlAttributes.css [ Css.lineHeight <| Css.num 1.5, Css.marginBottom <| Css.rem 2 ] ]
                [ Html.text <| i Translations.SettingsNotice ]
            , Html.div []
                [ settingsTitle i context.theme Translations.Language
                , languageOptions i context.theme context.language
                , settingsTitle i context.theme Translations.Theme
                , themeOptions i context.theme
                , settingsTitle i context.theme Translations.AutoLogout
                , Html.div [ HtmlAttributes.css [ Css.marginBottom <| Css.rem 1, Css.lineHeight <| Css.num 1.5 ] ]
                    [ Html.text <| i Translations.AutoLogoutHint ]
                , autoLogoutOptions i context.theme context.autoLogout
                ]
            ]


settingsTitle : Translations.Helper -> View.Theme.Theme -> Translations.Key -> Html.Html msg
settingsTitle i theme label =
    Html.h2
        [ HtmlAttributes.css
            [ Css.fontSize <| Css.rem 1.5
            , Css.fontWeight Css.bold
            , Css.color (theme |> View.Theme.textColor |> Color.Extra.toCss)
            , Css.marginBottom <| Css.rem 1
            ]
        ]
        [ Html.text <| i label ]


viewOptions : Translations.Helper -> View.Theme.Theme -> List (Option a) -> a -> (a -> msg) -> Html.Html msg
viewOptions i theme options selected msg =
    Html.ul
        [ HtmlAttributes.css
            [ Css.margin <| Css.px 0
            , Css.padding <| Css.px 0
            , Css.listStyle Css.none
            , Css.marginBottom <| Css.rem 2
            ]
        ]
        (options
            |> List.map
                (\( option, label ) ->
                    let
                        btnStyle : Css.Style
                        btnStyle =
                            if option /= selected then
                                View.Style.btnInverse theme

                            else
                                Css.batch []
                    in
                    Html.li
                        [ HtmlEvents.onClick <| msg option
                        , HtmlAttributes.css [ Css.marginBottom <| Css.rem 1, View.Style.btn theme, btnStyle ]
                        ]
                        [ Html.text <| i label ]
                )
        )


languageOptions : Translations.Helper -> View.Theme.Theme -> Translations.Language -> Html.Html Msg
languageOptions i theme selected =
    let
        options : List (Option Translations.Language)
        options =
            [ ( Translations.En, Translations.English )
            , ( Translations.Pt, Translations.Portuguese )
            ]
    in
    viewOptions i theme options selected Language


themeOptions : Translations.Helper -> View.Theme.Theme -> Html.Html Msg
themeOptions i theme =
    let
        options : List (Option View.Theme.Theme)
        options =
            [ ( View.Theme.Light, Translations.ThemeLight )
            , ( View.Theme.Dark, Translations.ThemeDark )
            , ( View.Theme.Tatty, Translations.ThemeTatty )
            ]
    in
    viewOptions i theme options theme Theme


autoLogoutOptions : Translations.Helper -> View.Theme.Theme -> Bool -> Html.Html Msg
autoLogoutOptions i theme selected =
    let
        options : List (Option Bool)
        options =
            [ ( False, Translations.No )
            , ( True, Translations.Yes )
            ]
    in
    viewOptions i theme options selected AutoLogout


init : Translations.Helper -> Context.Context -> ( Model, Effect.Effect, Cmd Msg )
init i context =
    let
        effect : Effect.Effect
        effect =
            Internal.initEffect i context.user
    in
    ( (), effect, Cmd.none )


update : Translations.Helper -> Context.Context -> Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update i context msg model =
    Internal.update i context msg model updateWithUser


updateWithUser : Translations.Helper -> Msg -> Model -> Business.User.User -> ( Model, Effect.Effect, Cmd Msg )
updateWithUser i msg model _ =
    case msg of
        Logout ->
            Internal.logout i model

        Language language ->
            ( model
            , Effect.language language
            , LocalStorage.set "language" (language |> Translations.languageToString |> LocalStorage.str)
            )

        Theme theme ->
            ( model
            , Effect.theme theme
            , LocalStorage.set "theme" (theme |> View.Theme.toString |> LocalStorage.str)
            )

        AutoLogout bool ->
            ( model
            , Effect.autoLogout bool
            , LocalStorage.set "autoLogout" (bool |> LocalStorage.bool)
            )
