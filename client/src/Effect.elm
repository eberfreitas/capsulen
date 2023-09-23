module Effect exposing
    ( Effect
    , addAlert
    , batch
    , login
    , none
    , redirect
    , removeAlert
    , run
    , task
    )

import Alert
import Browser.Navigation
import ConcurrentTask
import Context
import List.Extra
import Port
import Tasks


type Effect
    = None
    | Batch (List Effect)
    | AddAlert Alert.Message
    | RemoveAlert Int
    | Redirect String
    | Login String
    | Task (ConcurrentTask.ConcurrentTask Tasks.Error Tasks.Output)


none : Effect
none =
    None


batch : List Effect -> Effect
batch =
    Batch


addAlert : Alert.Message -> Effect
addAlert =
    AddAlert


removeAlert : Int -> Effect
removeAlert =
    RemoveAlert


redirect : String -> Effect
redirect =
    Redirect


login : String -> Effect
login =
    Login


task : ConcurrentTask.ConcurrentTask Tasks.Error Tasks.Output -> Effect
task =
    Task


run :
    (ConcurrentTask.Response Tasks.Error Tasks.Output -> msg)
    -> Context.Context msg
    -> Effect
    -> ( Context.Context msg, Cmd msg )
run taskOnCompleteMsg context effect =
    case effect of
        None ->
            ( context, Cmd.none )

        Batch effects ->
            List.foldl
                (\fx ( ctx, cmd ) ->
                    let
                        ( nextCtx, nextCmd ) =
                            run taskOnCompleteMsg ctx fx
                    in
                    ( nextCtx, Cmd.batch [ cmd, nextCmd ] )
                )
                ( context, Cmd.none )
                effects

        AddAlert msg ->
            ( { context | alerts = msg :: context.alerts }, Cmd.none )

        RemoveAlert index ->
            let
                alerts : List Alert.Message
                alerts =
                    context.alerts |> List.Extra.indexedFilter (\idx _ -> idx /= index)
            in
            ( { context | alerts = alerts }, Cmd.none )

        Redirect path ->
            ( context, Browser.Navigation.pushUrl context.key path )

        Login username ->
            ( { context | user = Just username }, Cmd.none )

        Task task_ ->
            let
                ( pool, cmds ) =
                    ConcurrentTask.attempt
                        { pool = context.tasks
                        , send = Port.taskSend
                        , onComplete = taskOnCompleteMsg
                        }
                        task_
            in
            ( { context | tasks = pool }, cmds )
