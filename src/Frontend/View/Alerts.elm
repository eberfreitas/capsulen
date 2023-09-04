module Frontend.View.Alerts exposing (Msg, update, view)

import Frontend.Alert
import Frontend.Effect
import Html


type Msg
    = CloseAlert Int


view : List Frontend.Alert.Message -> Html.Html Msg
view alerts =
    Html.div [] (alerts |> List.indexedMap (\index alert -> Frontend.Alert.toHtml CloseAlert index alert))


update : Msg -> Frontend.Effect.Effect
update msg =
    case msg of
        CloseAlert index ->
            Frontend.Effect.removeAlert index
