module View.Alerts exposing (Msg, update, view)

import Alert
import Effect
import Html.Styled as Html


type Msg
    = CloseAlert Int


view : List Alert.Message -> Html.Html Msg
view alerts =
    Html.div [] (alerts |> List.indexedMap (\index alert -> Alert.toHtml CloseAlert index alert))


update : Msg -> Effect.Effect
update msg =
    case msg of
        CloseAlert index ->
            Effect.removeAlert index
