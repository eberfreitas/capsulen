module View.Alerts exposing (Msg, update, view)

import Alert
import Effect
import Html.Styled as Html
import View.Theme


type Msg
    = CloseAlert Int


view : View.Theme.Theme -> List Alert.Message -> Html.Html Msg
view theme alerts =
    Html.div [] (alerts |> List.indexedMap (\index alert -> Alert.toHtml theme CloseAlert index alert))


update : Msg -> Effect.Effect
update msg =
    case msg of
        CloseAlert index ->
            Effect.removeAlert index
