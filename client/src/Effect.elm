module Effect exposing
    ( Effect
    , addAlert
    , batch
    , decayAlerts
    , language
    , login
    , logout
    , none
    , redirect
    , redirectWithAlert
    , removeAlert
    , run
    , theme
    , toggleLoader
    , username
    )

import Alert
import Browser.Navigation
import Business.User
import Context
import List.Extra
import Port
import Translations
import View.Theme


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
    | Username (Maybe String)
    | Language Translations.Language
    | Theme View.Theme.Theme
    | RedirectWithAlert String Alert.Message


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


username : Maybe String -> Effect
username =
    Username


language : Translations.Language -> Effect
language =
    Language


theme : View.Theme.Theme -> Effect
theme =
    Theme


redirectWithAlert : String -> Alert.Message -> Effect
redirectWithAlert =
    RedirectWithAlert


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
                    context.alerts |> List.Extra.removeAt index
            in
            ( { context | alerts = alerts }, Cmd.none )

        DecayAlerts delta ->
            let
                alerts : List Alert.Message
                alerts =
                    context.alerts |> List.filterMap (Alert.applyDecay delta)
            in
            ( { context | alerts = alerts }, Cmd.none )

        Redirect path ->
            ( { context | alerts = [] }, Browser.Navigation.pushUrl context.key path )

        RedirectWithAlert path msg ->
            ( { context | alerts = [ msg ] }, Browser.Navigation.pushUrl context.key path )

        Login user ->
            ( { context | user = Just user }, Cmd.none )

        Logout ->
            ( { context | user = Nothing }, Cmd.none )

        ToggleLoader ->
            ( context, Port.toggleLoader () )

        Username username_ ->
            ( { context | username = username_ }, Cmd.none )

        Language language_ ->
            ( { context | language = language_ }, Cmd.none )

        Theme theme_ ->
            ( { context | theme = theme_ }, Cmd.none )
