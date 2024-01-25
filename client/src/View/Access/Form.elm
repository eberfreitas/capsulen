module View.Access.Form exposing (form, inviteCodeField, privateKeyField, usernameField)

import Business.InviteCode
import Business.PrivateKey
import Business.Username
import Color.Extra
import Css
import Form
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Html.Styled.Events as HtmlEvents
import Phosphor
import Translations
import View.Style
import View.Theme


inputWrapperStyle : Css.Style
inputWrapperStyle =
    Css.batch
        [ Css.marginBottom <| Css.rem 1.5
        , Css.position Css.relative
        ]


inputLabelStyle : Css.Style
inputLabelStyle =
    Css.batch
        [ Css.display Css.block
        , Css.fontVariant Css.allPetiteCaps
        , Css.marginBottom <| Css.rem 0.5
        ]


inputStyle : Css.Style
inputStyle =
    Css.batch
        [ Css.border <| Css.px 0
        , Css.borderRadius <| Css.rem 0.5
        , Css.padding <| Css.rem 1
        , Css.width <| Css.pct 100
        ]


inviteCodeField :
    Translations.Helper
    -> View.Theme.Theme
    -> (Form.InputEvent -> msg)
    -> Int
    -> Form.Input Business.InviteCode.InviteCode
    -> Html.Html msg
inviteCodeField i theme msg index input =
    Html.div [ HtmlAttributes.css [ inputWrapperStyle ] ]
        [ Html.label
            [ HtmlAttributes.for "inviteCode"
            , HtmlAttributes.css [ inputLabelStyle ]
            ]
            [ Html.text <| i Translations.InviteCode ]
        , Html.input
            ([ HtmlAttributes.css [ inputStyle ]
             , HtmlAttributes.type_ "text"
             , HtmlAttributes.name "inviteCode"
             , HtmlAttributes.id "inviteCode"
             , HtmlAttributes.value input.raw
             , HtmlAttributes.tabindex index
             ]
                ++ Form.inputEvents msg
            )
            []
        , Form.viewInputError i theme input
        ]


usernameField :
    Translations.Helper
    -> View.Theme.Theme
    -> (Form.InputEvent -> msg)
    -> Int
    -> Form.Input Business.Username.Username
    -> Html.Html msg
usernameField i theme msg index input =
    Html.div [ HtmlAttributes.css [ inputWrapperStyle ] ]
        [ Html.label
            [ HtmlAttributes.for "username"
            , HtmlAttributes.css [ inputLabelStyle ]
            ]
            [ Html.text <| i Translations.Username ]
        , Html.input
            ([ HtmlAttributes.css [ inputStyle ]
             , HtmlAttributes.type_ "text"
             , HtmlAttributes.name "username"
             , HtmlAttributes.id "username"
             , HtmlAttributes.value input.raw
             , HtmlAttributes.tabindex index
             ]
                ++ Form.inputEvents msg
            )
            []
        , Form.viewInputError i theme input
        ]


privateKeyField :
    Translations.Helper
    -> View.Theme.Theme
    -> (Form.InputEvent -> msg)
    -> msg
    -> Bool
    -> Int
    -> Form.Input Business.PrivateKey.PrivateKey
    -> Html.Html msg
privateKeyField i theme msg toggleMsg showPrivateKey index input =
    let
        ( privateKeyInputType, togglePrivateKeyIcon ) =
            if showPrivateKey then
                ( "text", Phosphor.eyeClosed Phosphor.Regular |> Phosphor.toHtml [] |> Html.fromUnstyled )

            else
                ( "password", Phosphor.eye Phosphor.Regular |> Phosphor.toHtml [] |> Html.fromUnstyled )
    in
    Html.div [ HtmlAttributes.css [ inputWrapperStyle ] ]
        [ Html.label
            [ HtmlAttributes.for "privateKey"
            , HtmlAttributes.css [ inputLabelStyle ]
            ]
            [ Html.text <| i Translations.PrivateKey ]
        , Html.input
            ([ HtmlAttributes.css [ inputStyle ]
             , HtmlAttributes.type_ privateKeyInputType
             , HtmlAttributes.name "privateKey"
             , HtmlAttributes.id "privateKey"
             , HtmlAttributes.value input.raw
             , HtmlAttributes.tabindex index
             ]
                ++ Form.inputEvents msg
            )
            []
        , Html.button
            [ HtmlAttributes.type_ "button"
            , HtmlEvents.onClick toggleMsg
            , HtmlAttributes.tabindex <| index + 1
            , HtmlAttributes.css
                [ View.Style.btn theme
                , Css.borderRadius4 (Css.rem 0) (Css.rem 0.5) (Css.rem 0.5) (Css.rem 0)
                , Css.position Css.absolute
                , Css.right <| Css.px 0
                , Css.top <| Css.rem 1.65
                , Css.lineHeight <| Css.num 0
                , Css.padding <| Css.rem 0.9
                ]
            ]
            [ togglePrivateKeyIcon ]
        , Form.viewInputError i theme input
        ]


form :
    Translations.Helper
    -> View.Theme.Theme
    -> Translations.Key
    -> msg
    -> Form.FormState
    -> Int
    -> List (Html.Html msg)
    -> Html.Html msg
form i theme actionKey msg state submitBtnIndex fields =
    let
        ( btnStyles, btnAttrs ) =
            Form.submitBtnByState state
    in
    Html.form
        [ HtmlEvents.onSubmit msg
        , HtmlAttributes.css
            [ Css.marginBottom <| Css.rem 1.5
            , Css.position Css.relative
            ]
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
                    [ Css.color (theme |> View.Theme.foregroundColor |> Color.Extra.toCss)
                    , Css.display Css.block
                    , Css.fontSize <| Css.rem 2
                    , Css.fontWeight Css.bold
                    , Css.marginBottom <| Css.rem 2
                    , Css.textAlign Css.center
                    , Css.width <| Css.pct 100
                    ]
                ]
                [ Html.text <| i actionKey ]
            , Html.div [] fields
            , Html.div
                [ HtmlAttributes.css
                    [ Css.marginBottom <| Css.rem 1.5
                    , Css.textAlign Css.center
                    ]
                ]
                [ Html.text <| i Translations.PrivateKeyNotice ]
            , Html.button
                ([ HtmlAttributes.css
                    ([ View.Style.btn theme
                     , View.Style.btnFull
                     ]
                        ++ btnStyles
                    )
                 , HtmlAttributes.tabindex submitBtnIndex
                 ]
                    ++ btnAttrs
                )
                [ Html.text <| i actionKey ]
            ]
        ]
