module Internal exposing (initEffect, logout, template, update, view)

import Alert
import Business.User
import Context
import Css
import Effect
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Html.Styled.Events as HtmlEvents
import Translations
import View.Logo
import View.Style
import View.Theme


template :
    Translations.Helper
    -> View.Theme.Theme
    -> msg
    -> Html.Html msg
    -> Html.Html msg
template i theme logoutMsg content =
    Html.div
        [ HtmlAttributes.css
            [ Css.maxWidth <| Css.px 600
            , Css.width <| Css.pct 100
            ]
        ]
        [ Html.div [ HtmlAttributes.css [ Css.marginBottom <| Css.rem 2, Css.position Css.relative ] ]
            [ Html.div []
                [ Html.a [ HtmlAttributes.href "/posts" ] [ View.Logo.logo 40 <| View.Theme.foregroundColor theme ] ]
            , Html.div
                [ HtmlAttributes.css
                    [ Css.position Css.absolute
                    , Css.right <| Css.px 0
                    , Css.top <| Css.px 0
                    ]
                ]
                [ Html.button
                    [ HtmlEvents.onClick logoutMsg
                    , HtmlAttributes.css
                        [ View.Style.btn theme
                        , View.Style.btnInverse theme
                        , View.Style.btnShort
                        ]
                    ]
                    [ Html.text <| i Translations.Logout ]
                ]
            ]
        , content
        ]


view :
    Translations.Helper
    -> Context.Context
    -> model
    -> (Translations.Helper -> Context.Context -> model -> Business.User.User -> Html.Html msg)
    -> Html.Html msg
view i context model viewWithUser =
    context.user
        |> Maybe.map (viewWithUser i context model)
        |> Maybe.withDefault (Html.text "")


initEffect : Translations.Helper -> Maybe Business.User.User -> Effect.Effect
initEffect i user =
    user
        |> Maybe.map (always Effect.none)
        |> Maybe.withDefault
            (Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i Translations.ForbiddenArea)
                , Effect.redirect "/"
                ]
            )


update :
    Translations.Helper
    -> Context.Context
    -> msg
    -> model
    -> (Translations.Helper -> msg -> model -> Business.User.User -> ( model, Effect.Effect, Cmd msg ))
    -> ( model, Effect.Effect, Cmd msg )
update i context msg model updateWithUser =
    context.user
        |> Maybe.map (updateWithUser i msg model)
        |> Maybe.withDefault ( model, Effect.none, Cmd.none )


logout : Translations.Helper -> model -> ( model, Effect.Effect, Cmd msg )
logout i model =
    ( model
    , Effect.batch
        [ Effect.logout
        , Effect.redirect "/"
        , Effect.addAlert (Alert.new Alert.Success <| i Translations.LogoutSuccess)
        ]
    , Cmd.none
    )
