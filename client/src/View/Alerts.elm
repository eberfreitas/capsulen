module View.Alerts exposing (Msg, update, view)

import Alert
import Effect
import Html


type Msg
    = CloseAlert Int


view : (String -> String) -> List Alert.Message -> Html.Html Msg
view i alerts =
    Html.div [] (alerts |> List.indexedMap (\index alert -> Alert.toHtml i CloseAlert index alert))


update : Msg -> Effect.Effect
update msg =
    case msg of
        CloseAlert index ->
            Effect.removeAlert index
