module Effect exposing
    ( Effect
    , addAlert
    , batch
    , decayAlerts
    , login
    , logout
    , none
    , redirect
    , removeAlert
    , run
    , toggleLoader
    )

import Alert
import Browser.Navigation
import Business.User
import Context
import List.Extra
import Port


type Effect
    = None
    | Batch (List Effect)
    | AddAlert Alert.Message
    | DecayAlerts Float
    | RemoveAlert Int
    | Redirect String
    | Login Business.User.User
    | Logout
    | ToggleLoader


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


decayAlerts : Float -> Effect
decayAlerts =
    DecayAlerts


redirect : String -> Effect
redirect =
    Redirect


login : Business.User.User -> Effect
login =
    Login


toggleLoader : Effect
toggleLoader =
    ToggleLoader


logout : Effect
logout =
    Logout


run : Context.Context -> Effect -> ( Context.Context, Cmd msg )
run context effect =
    case effect of
        None ->
            ( context, Cmd.none )

        Batch effects ->
            List.foldl
                (\fx ( ctx, cmd ) ->
                    let
                        ( nextCtx, nextCmd ) =
                            run ctx fx
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

        DecayAlerts delta ->
            let
                alerts =
                    context.alerts |> List.filterMap (Alert.applyDecay delta)
            in
            ( { context | alerts = alerts }, Cmd.none )

        Redirect path ->
            ( context, Browser.Navigation.pushUrl context.key path )

        Login user ->
            ( { context | user = Just user }, Cmd.none )

        Logout ->
            ( { context | user = Nothing }, Cmd.none )

        ToggleLoader ->
            ( context, Port.toggleLoader () )
