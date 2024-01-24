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
    case alerts of
        [] ->
            Html.text ""

        _ ->
            Html.div
                [ HtmlAttributes.css
                    [ Css.bottom <| Css.px 0
                    , Css.left <| Css.px 0
                    , Css.right <| Css.px 0
                    , Css.position Css.fixed
                    , Css.padding <| Css.rem 2
                    , Css.paddingBottom <| Css.px 1
                    , Css.display Css.flex_
                    , Css.flexDirection Css.column
                    , Css.alignItems Css.center
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
