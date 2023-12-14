module View.Access.Form exposing (Msgs, form)

import Business.PrivateKey
import Business.Username
import Css
import Form
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Html.Styled.Events as HtmlEvents
import Phosphor
import Translations
import View.Color
import View.Style
import View.Theme


type alias Msgs msg =
    { submit : msg
    , username : Form.InputEvent -> msg
    , privateKey : Form.InputEvent -> msg
    , togglePrivateKey : msg
    }


form :
    Translations.Helper
    -> View.Theme.Theme
    -> Bool
    -> Translations.Key
    -> Msgs msg
    -> Form.Input Business.Username.Username
    -> Form.Input Business.PrivateKey.PrivateKey
    -> Html.Html msg
form i theme showPrivateKey actionKey msgs usernameInput privateKeyInput =
    let
        ( privateKeyInputType, togglePrivateKeyIcon ) =
            if showPrivateKey then
                ( "text", Phosphor.eyeClosed Phosphor.Regular |> Phosphor.toHtml [] |> Html.fromUnstyled )

            else
                ( "password", Phosphor.eye Phosphor.Regular |> Phosphor.toHtml [] |> Html.fromUnstyled )

        inputWrapperStyle =
            Css.batch
                [ Css.marginBottom <| Css.rem 1.5
                , Css.position Css.relative
                ]

        inputLabelStyle =
            Css.batch
                [ Css.display Css.block
                , Css.fontVariant Css.allPetiteCaps
                , Css.marginBottom <| Css.rem 0.5
                ]

        inputStyle =
            Css.batch
                [ Css.border <| Css.px 0
                , Css.borderRadius <| Css.rem 0.5
                , Css.padding <| Css.rem 1
                , Css.width <| Css.pct 100
                ]
    in
    Html.form
        [ HtmlEvents.onSubmit msgs.submit
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
                    [ Css.color (theme |> View.Theme.foregroundColor |> View.Color.toCss)
                    , Css.display Css.block
                    , Css.fontSize <| Css.rem 2
                    , Css.fontWeight Css.bold
                    , Css.marginBottom <| Css.rem 2
                    , Css.textAlign Css.center
                    , Css.width <| Css.pct 100
                    ]
                ]
                [ Html.text <| i actionKey ]
            , Html.div [ HtmlAttributes.css [ inputWrapperStyle ] ]
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
                     , HtmlAttributes.value usernameInput.raw
                     ]
                        ++ Form.inputEvents msgs.username
                    )
                    []
                , Form.viewInputError i usernameInput
                ]
            , Html.div [ HtmlAttributes.css [ inputWrapperStyle ] ]
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
                     , HtmlAttributes.value privateKeyInput.raw
                     ]
                        ++ Form.inputEvents msgs.privateKey
                    )
                    []
                , Html.button
                    [ HtmlAttributes.type_ "button"
                    , HtmlEvents.onClick msgs.togglePrivateKey
                    , HtmlAttributes.css
                        [ View.Style.btn theme
                        , Css.borderRadius4 (Css.rem 0) (Css.rem 0.5) (Css.rem 0.5) (Css.rem 0)
                        , Css.position Css.absolute
                        , Css.right <| Css.px 0
                        , Css.top <| Css.rem 1.65
                        ]
                    ]
                    [ togglePrivateKeyIcon ]
                , Form.viewInputError i privateKeyInput
                ]
            , Html.div
                [ HtmlAttributes.css
                    [ Css.marginBottom <| Css.rem 1.5
                    , Css.textAlign Css.center
                    ]
                ]
                [ Html.text <| i Translations.PrivateKeyNotice ]
            , Html.button
                [ HtmlAttributes.css [ View.Style.btn theme, View.Style.btnFull ] ]
                [ Html.text <| i actionKey ]
            ]
        ]
