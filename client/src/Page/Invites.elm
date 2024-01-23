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
import Logger
import Page
import Port
import RemoteData
import Translations
import View.Style
import View.Theme


type alias Model =
    { invites : RemoteData.RemoteData Page.TaskError (List Business.InviteCode.Invite)
    , tasks : TaskPool
    }


initModel : Model
initModel =
    { invites = RemoteData.NotAsked, tasks = ConcurrentTask.pool }


type Msg
    = Logout
    | Generate
    | OnTaskProgress ( TaskPool, Cmd Msg )
    | OnTaskComplete (ConcurrentTask.Response Page.TaskError TaskOutput)


type TaskOutput
    = Generated Business.InviteCode.Invite


type alias TaskPool =
    ConcurrentTask.Pool Msg Page.TaskError TaskOutput


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
            ( { model | tasks = tasks }, Effect.none, cmd )

        OnTaskProgress ( tasks, cmd ) ->
            ( { model | tasks = tasks }, Effect.none, cmd )

        OnTaskComplete (ConcurrentTask.Success (Generated invite)) ->
            let
                _ =
                    Debug.log "invite" invite
            in
            ( model, Effect.none, Cmd.none )

        OnTaskComplete (ConcurrentTask.Error (Page.Generic errorKey)) ->
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i errorKey)
                , Effect.toggleLoader
                ]
            , Cmd.none
            )

        OnTaskComplete (ConcurrentTask.Error (Page.RequestError httpError)) ->
            ( model
            , Effect.batch
                [ Effect.addAlert (Alert.new Alert.Error <| i Translations.RequestError)
                , Effect.toggleLoader
                ]
            , Logger.captureMessage <| ConcurrentTask.Http.Extra.errorToString httpError
            )

        OnTaskComplete (ConcurrentTask.UnexpectedError _) ->
            ( model
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
