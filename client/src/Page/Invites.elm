module Page.Invites exposing (Model, Msg, init, update, view)

import Business.InviteCode
import Business.User
import Color.Extra
import Context
import Css
import Effect
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Html.Styled.Events as HtmlEvents
import Internal
import Page
import RemoteData
import Translations
import View.Style
import View.Theme


type alias Model =
    { invites : RemoteData.RemoteData Page.TaskError (List Business.InviteCode.Invite) }


initModel : Model
initModel =
    { invites = RemoteData.NotAsked }


type Msg
    = Logout
    | Generate


init : Translations.Helper -> Context.Context -> ( Model, Effect.Effect, Cmd Msg )
init i context =
    let
        effect : Effect.Effect
        effect =
            Internal.initEffect i context.user
    in
    ( initModel, effect, Cmd.none )


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
        Html.div
            [ HtmlAttributes.css
                [ Css.color (context.theme |> View.Theme.textColor |> Color.Extra.toCss)
                , Css.lineHeight <| Css.num 1.5
                ]
            ]
            [ Html.div
                [ HtmlAttributes.css [ Css.marginBottom <| Css.rem 2 ] ]
                [ Html.text <| i Translations.InviteHelp ]
            , Html.div []
                [ Html.button
                    [ HtmlAttributes.css [ View.Style.btn context.theme ]
                    , HtmlEvents.onClick Generate
                    ]
                    [ Html.text <| i Translations.InviteGenerate ]
                ]
            ]


update : Translations.Helper -> Context.Context -> Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update i context msg model =
    Internal.update i context msg model updateWithUser


updateWithUser : Translations.Helper -> Msg -> Model -> Business.User.User -> ( Model, Effect.Effect, Cmd Msg )
updateWithUser i msg model _ =
    case msg of
        Logout ->
            Internal.logout i model

        Generate ->
            let
                _ =
                    Debug.log "Yes" "Let's do it!"
            in
            ( model, Effect.none, Cmd.none )
