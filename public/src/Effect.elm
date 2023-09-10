module Effect exposing (Effect, addAlert, batch, none, removeAlert, run)

import Alert
import Context
import List.Extra


type Effect
    = None
    | Batch (List Effect)
    | AddAlert Alert.Message
    | RemoveAlert Int


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


run : Effect -> Context.Context -> ( Context.Context, Cmd msg )
run effect context =
    case effect of
        None ->
            ( context, Cmd.none )

        Batch effects ->
            List.foldl
                (\fx ( ctx, cmd ) ->
                    let
                        ( nextCtx, nextCmd ) =
                            run fx ctx
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
