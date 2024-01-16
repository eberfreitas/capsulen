module View.Alerts exposing (Msg, decay, update, view)

import Alert
import Css
import Effect
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import View.Theme


type Msg
    = CloseAlert Int
    | Decay Float


decay : Float -> Msg
decay =
    Decay


view : View.Theme.Theme -> List Alert.Message -> Html.Html Msg
view theme alerts =
    Html.div
        [ HtmlAttributes.css
            [ Css.bottom <| Css.px 0
            , Css.left <| Css.pct 50
            , Css.maxWidth <| Css.px 700
            , Css.position Css.fixed
            , Css.transform <| Css.translate (Css.pct -50)
            , Css.width <| Css.pct 100
            , Css.margin2 (Css.px 0) Css.auto
            ]
        ]
        (alerts |> List.indexedMap (\index alert -> Alert.toHtml theme CloseAlert index alert))


update : Msg -> Effect.Effect
update msg =
    case msg of
        CloseAlert index ->
            Effect.removeAlert index

        Decay delta ->
            Effect.decayAlerts delta
