module Business.Post.ContentParser exposing (render)

import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Parser exposing ((|.), (|=))
import Url


type Node
    = Anchor Node Url.Url Node
    | Bold Node Node
    | Italic Node Node
    | ListItem Node Node
    | List (List Node) Node
    | NewLine Node
    | Hashtag String Node
    | Text String Node
    | End


anchor : Parser.Parser Node
anchor =
    (Parser.succeed
        (\label url_ node_ -> { label = label, url = url_, node = node_ })
        |. Parser.symbol "["
        |= Parser.getChompedString (Parser.chompUntil "]")
        |. Parser.symbol "]"
        |. Parser.symbol "("
        |= Parser.getChompedString (Parser.chompUntil ")")
        |. Parser.symbol ")"
        |= Parser.lazy (\_ -> node)
    )
        |> Parser.andThen
            (\params ->
                case ( Parser.run node params.label, Url.fromString params.url ) of
                    ( Ok labelNode, Just parsedUrl ) ->
                        Parser.succeed <| Anchor labelNode parsedUrl params.node

                    _ ->
                        Parser.problem "Could not produce anchor"
            )


anchorFallback : Parser.Parser Node
anchorFallback =
    Parser.succeed Text
        |= Parser.getChompedString (Parser.symbol "[")
        |= Parser.lazy (\_ -> node)


nodeHelper : (a -> Node -> Node) -> Parser.Parser a -> String -> Node -> Node
nodeHelper nodeTag parser value tailNode =
    case Parser.run parser value of
        Ok parsed ->
            nodeTag parsed tailNode

        Err _ ->
            Text value tailNode


bold : Parser.Parser Node
bold =
    Parser.succeed (nodeHelper Bold (Parser.lazy (\_ -> node)))
        |. Parser.symbol "*"
        |= Parser.getChompedString (Parser.chompUntil "*")
        |. Parser.symbol "*"
        |= Parser.lazy (\_ -> node)


boldFallback : Parser.Parser Node
boldFallback =
    Parser.succeed Text
        |= Parser.getChompedString (Parser.symbol "*")
        |= Parser.lazy (\_ -> node)


italic : Parser.Parser Node
italic =
    Parser.succeed (nodeHelper Italic (Parser.lazy (\_ -> node)))
        |. Parser.symbol "_"
        |= Parser.getChompedString (Parser.chompUntil "_")
        |. Parser.symbol "_"
        |= Parser.lazy (\_ -> node)


italicFallback : Parser.Parser Node
italicFallback =
    Parser.succeed Text
        |= Parser.getChompedString (Parser.symbol "_")
        |= Parser.lazy (\_ -> node)


listItem : Parser.Parser Node
listItem =
    Parser.succeed (nodeHelper ListItem (Parser.lazy (\_ -> node)))
        |. Parser.symbol "-"
        |. Parser.spaces
        |= Parser.getChompedString (Parser.chompWhile ((/=) '\n'))
        |. Parser.chompIf ((==) '\n')
        |= Parser.lazy (\_ -> node)


newLine : Parser.Parser Node
newLine =
    Parser.succeed NewLine
        |. Parser.chompIf (\c -> c == '\n')
        |= Parser.lazy (\_ -> node)


end : Parser.Parser Node
end =
    Parser.succeed End
        |. Parser.end


hashtag : Parser.Parser Node
hashtag =
    Parser.succeed Hashtag
        |. Parser.symbol "#"
        |= (Parser.getChompedString (Parser.chompWhile (\c -> c /= ' ' && c /= '\n' && c /= '#'))
                |> Parser.andThen
                    (\hashtag_ ->
                        if hashtag_ == "" then
                            Parser.problem "Empty hashtag"

                        else
                            Parser.succeed hashtag_
                    )
           )
        |= Parser.lazy (\_ -> node)


hashtagFallback : Parser.Parser Node
hashtagFallback =
    Parser.succeed Text
        |= Parser.getChompedString (Parser.symbol "#")
        |= Parser.lazy (\_ -> node)


textString : Parser.Parser String
textString =
    let
        nodeTokens =
            [ '[', '*', '_', '\n', '#' ]

        whileFn =
            \char -> not <| List.member char nodeTokens
    in
    Parser.succeed identity
        |= Parser.getChompedString (Parser.chompWhile whileFn)


text : Parser.Parser Node
text =
    Parser.succeed Text
        |= textString
        |= Parser.lazy (\_ -> node)


node : Parser.Parser Node
node =
    Parser.oneOf
        [ Parser.backtrackable anchor
        , anchorFallback
        , Parser.backtrackable bold
        , boldFallback
        , Parser.backtrackable italic
        , italicFallback
        , listItem
        , Parser.backtrackable hashtag
        , hashtagFallback
        , newLine
        , end
        , text
        ]


render : String -> Html.Html msg
render content =
    case Parser.run node content of
        Ok node_ ->
            Html.div [] (toHtml node_ [])

        Err _ ->
            Html.div [] [ Html.text content ]


toHtml : Node -> List (Html.Html msg) -> List (Html.Html msg)
toHtml node_ html =
    case node_ of
        End ->
            List.reverse html

        Text text_ tailNode ->
            (Html.text text_ :: html) |> toHtml tailNode

        Anchor anchorNode url_ tailNode ->
            (Html.a [ HtmlAttributes.href <| Url.toString url_ ] (toHtml anchorNode []) :: html) |> toHtml tailNode

        Bold boldNode tailNode ->
            (Html.strong [] (toHtml boldNode []) :: html) |> toHtml tailNode

        Italic italicNode tailNode ->
            (Html.i [] (toHtml italicNode []) :: html) |> toHtml tailNode

        ListItem listItemNode tailNode ->
            toHtml (List [ listItemNode ] tailNode) html

        List listNodes (ListItem listItemNode tailNode) ->
            toHtml (List (listItemNode :: listNodes) tailNode) html

        List listNodes tailNode ->
            (Html.ul []
                (listNodes
                    |> List.reverse
                    |> List.map
                        (\itemNode ->
                            Html.li [] (toHtml itemNode [])
                        )
                )
                :: html
            )
                |> toHtml tailNode

        NewLine tailNode ->
            (Html.br [] [] :: html) |> toHtml tailNode

        Hashtag hashtag_ tailNode ->
            ((Html.text <| "#" ++ hashtag_) :: html) |> toHtml tailNode
