module Effect exposing
    ( Effect
    , addAlert
    , batch
    , login
    , none
    , redirect
    , removeAlert
    , run
    )

import Alert
import Browser.Navigation
import Context
import List.Extra


type Effect
    = None
    | Batch (List Effect)
    | AddAlert Alert.Message
    | RemoveAlert Int
    | Redirect String
    | Login String


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

        Redirect path ->
            ( context, Browser.Navigation.pushUrl context.key path )

        Login username ->
            ( { context | user = Just username }, Cmd.none )
