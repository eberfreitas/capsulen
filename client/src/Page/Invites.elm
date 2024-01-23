module Page.Invites exposing (Model, Msg, init, subscriptions, update, view)

import Alert
import Business.InviteCode
import Business.User
import Color.Extra
import ConcurrentTask
import ConcurrentTask.Http
import ConcurrentTask.Http.Extra
import Context
import Css
import Effect
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Html.Styled.Events as HtmlEvents
import Internal
import Json.Decode
import Logger
import Page
import Phosphor
import Port
import Translations
import View.Style
import View.Theme


type Generating
    = Idle
    | Running


type alias Model =
    { invites : List Business.InviteCode.Invite
    , tasks : TaskPool
    , generating : Generating
    }


type Msg
    = Logout
    | Generate
    | OnTaskProgress ( TaskPool, Cmd Msg )
    | OnTaskComplete (ConcurrentTask.Response Page.TaskError TaskOutput)


type TaskOutput
    = Generated Business.InviteCode.Invite
    | Invites (List Business.InviteCode.Invite)


type alias TaskPool =
    ConcurrentTask.Pool Msg Page.TaskError TaskOutput


init : Translations.Helper -> Context.Context -> ( Model, Effect.Effect, Cmd Msg )
init i context =
    let
        effect : Effect.Effect
        effect =
            Internal.initEffect i context.user

        tasks : TaskPool
        tasks =
            ConcurrentTask.pool

        fetchInvites : Business.User.User -> ConcurrentTask.ConcurrentTask Page.TaskError TaskOutput
        fetchInvites user =
            ConcurrentTask.Http.get
                { url = "/api/invites"
                , headers = [ ConcurrentTask.Http.header "authorization" ("Bearer " ++ user.token) ]
                , expect = ConcurrentTask.Http.expectJson <| Json.Decode.list Business.InviteCode.decodeInvite
                , timeout = Nothing
                }
                |> ConcurrentTask.mapError Page.httpErrorMapper
                |> ConcurrentTask.map Invites

        ( newTasks, cmd ) =
            context.user
                |> Maybe.map
                    (\user ->
                        ConcurrentTask.attempt
                            { pool = tasks
                            , send = Port.taskSend
                            , onComplete = OnTaskComplete
                            }
                            (fetchInvites user)
                    )
                |> Maybe.withDefault ( tasks, Cmd.none )
    in
    ( { invites = [], tasks = newTasks, generating = Idle }
    , effect
    , cmd
    )


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
            case model.generating of
                Idle ->
                    ( [], [] )

                Running ->
                    ( [ View.Style.btnDisabled ], [ HtmlAttributes.disabled True ] )
    in
    Internal.template i context.theme Logout <|
        Html.div
            [ HtmlAttributes.css
                [ Css.color (context.theme |> View.Theme.textColor |> Color.Extra.toCss)
                , Css.lineHeight <| Css.num 1.5
                ]
            ]
            [ Html.div
                [ HtmlAttributes.css [ Css.marginBottom <| Css.rem 1 ] ]
                [ Html.text <| i Translations.InviteHelp ]
            , Html.div
                [ HtmlAttributes.css [ Css.marginBottom <| Css.rem 2 ] ]
                [ Html.button
                    ([ HtmlAttributes.css <| View.Style.btn context.theme :: btnStyles
                     , HtmlEvents.onClick Generate
                     ]
                        ++ btnAttrs
                    )
                    [ Html.text <| i Translations.InviteGenerate ]
                ]
            , Html.ul
                [ HtmlAttributes.css
                    [ Css.margin <| Css.px 0
                    , Css.padding <| Css.px 0
                    , Css.listStyle Css.none
                    ]
                ]
                (model.invites |> List.map (viewInvite i context.theme))
            ]


viewInvite : Translations.Helper -> View.Theme.Theme -> Business.InviteCode.Invite -> Html.Html msg
viewInvite i theme invite =
    let
        ( color, statusLabel ) =
            case invite.status of
                Business.InviteCode.Pending ->
                    ( View.Theme.successColor theme, Translations.InvitePending )

                Business.InviteCode.Used ->
                    ( View.Theme.errorColor theme, Translations.InviteUsed )

        textColor =
            color |> Color.Extra.toContrast 0.5
    in
    Html.li
        [ HtmlAttributes.css
            [ Css.padding <| Css.rem 1
            , Css.backgroundColor <| Color.Extra.toCss color
            , Css.color <| Color.Extra.toCss textColor
            , Css.borderRadius <| Css.rem 0.5
            , Css.marginBottom <| Css.rem 1
            , Css.position Css.relative
            ]
        ]
        [ Html.div
            [ HtmlAttributes.css
                [ Css.fontSize <| Css.rem 1.5
                , Css.fontFamily Css.monospace
                , Css.display Css.flex_
                , Css.alignItems Css.center
                ]
            ]
            [ Html.node "clipboard-copy"
                [ HtmlAttributes.attribute "value" invite.code ]
                [ Html.button
                    [ HtmlAttributes.css
                        [ Css.border <| Css.px 0
                        , Css.backgroundColor Css.transparent
                        , Css.color <| Color.Extra.toCss textColor
                        , Css.cursor Css.pointer
                        , Css.display Css.block
                        , Css.margin <| Css.px 0
                        , Css.marginRight <| Css.rem 0.5
                        , Css.padding <| Css.px 0
                        , Css.lineHeight <| Css.num 0
                        ]
                    ]
                    [ Phosphor.clipboardText Phosphor.Regular
                        |> Phosphor.toHtml []
                        |> Html.fromUnstyled
                    ]
                ]
            , Html.div [] [ Html.text invite.code ]
            ]
        , Html.div
            [ HtmlAttributes.css
                [ Css.position Css.absolute
                , Css.top <| Css.rem 1
                , Css.right <| Css.rem 1
                , Css.backgroundColor (theme |> View.Theme.backgroundColor |> Color.Extra.toCss)
                , Css.color (theme |> View.Theme.textColor |> Color.Extra.toCss)
                , Css.borderRadius <| Css.rem 0.3
                , Css.padding2 (Css.rem 0.4) (Css.rem 1)
                ]
            ]
            [ Html.text <| i statusLabel ]
        ]


update : Translations.Helper -> Context.Context -> Msg -> Model -> ( Model, Effect.Effect, Cmd Msg )
update i context msg model =
    Internal.update i context msg model updateWithUser


updateWithUser : Translations.Helper -> Msg -> Model -> Business.User.User -> ( Model, Effect.Effect, Cmd Msg )
updateWithUser i msg model user =
    case msg of
        Logout ->
            Internal.logout i model

        Generate ->
            let
                generateInvite : ConcurrentTask.ConcurrentTask Page.TaskError TaskOutput
                generateInvite =
                    ConcurrentTask.Http.post
                        { url = "/api/invites"
                        , headers = [ ConcurrentTask.Http.header "authorization" ("Bearer " ++ user.token) ]
                        , body = ConcurrentTask.Http.emptyBody
                        , expect = ConcurrentTask.Http.expectJson Business.InviteCode.decodeInvite
                        , timeout = Nothing
                        }
                        |> ConcurrentTask.mapError Page.httpErrorMapper
                        |> ConcurrentTask.map Generated

                ( tasks, cmd ) =
                    ConcurrentTask.attempt
                        { pool = model.tasks
                        , send = Port.taskSend
                        , onComplete = OnTaskComplete
                        }
                        generateInvite
            in
            ( { model | tasks = tasks, generating = Running }, Effect.toggleLoader, cmd )

        OnTaskProgress ( tasks, cmd ) ->
            ( { model | tasks = tasks }, Effect.none, cmd )

        OnTaskComplete (ConcurrentTask.Success (Generated invite)) ->
            ( { model | invites = invite :: model.invites, generating = Idle }
            , Effect.toggleLoader
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Success (Invites invites)) ->
            ( { model | invites = invites ++ model.invites }
            , Effect.none
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Error (Page.Generic errorKey)) ->
            ( { model | generating = Idle }
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i errorKey)
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Error (Page.RequestError httpError)) ->
            ( { model | generating = Idle }
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i Translations.RequestError)
                , Effect.toggleLoader
                ]
            , Logger.captureMessage <| ConcurrentTask.Http.Extra.errorToString httpError
            )

        OnTaskComplete (ConcurrentTask.UnexpectedError _) ->
            ( { model | generating = Idle }
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i Translations.RequestError)
                , Effect.toggleLoader
                ]
            , Cmd.none
            )


subscriptions : TaskPool -> Sub Msg
subscriptions pool =
    ConcurrentTask.onProgress
        { send = Port.taskSend
        , receive = Port.taskReceive
        , onProgress = OnTaskProgress
        }
        pool
