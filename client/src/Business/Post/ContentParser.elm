module Business.Post.ContentParser exposing (render)

import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import Parser exposing ((|.), (|=))
import Url


type Node
    = Anchor (List Node) Url.Url
    | Bold (List Node)
    | Italic (List Node)
    | ListItem (List Node)
    | List (List (List Node))
    | NewLine
    | Hashtag String
    | Text String


anchor : Parser.Parser (List Node)
anchor =
    (Parser.succeed
        (\anchorText url_ tailNodes -> ( anchorText, url_, tailNodes ))
        |. Parser.symbol "["
        |= Parser.getChompedString (Parser.chompUntil "]")
        |. Parser.symbol "]"
        |. Parser.symbol "("
        |= Parser.getChompedString (Parser.chompUntil ")")
        |. Parser.symbol ")"
        |= Parser.lazy (\_ -> node)
    )
        |> Parser.andThen
            (\( anchorText, url_, tailNodes ) ->
                case ( Parser.run node anchorText, Url.fromString url_ ) of
                    ( Ok anchorNodes, Just parsedUrl ) ->
                        Parser.succeed <| Anchor anchorNodes parsedUrl :: tailNodes

                    _ ->
                        Parser.problem "Could not produce anchor"
            )


anchorFallback : Parser.Parser (List Node)
anchorFallback =
    Parser.succeed (\text_ tailNodes -> Text text_ :: tailNodes)
        |= Parser.getChompedString (Parser.symbol "[")
        |= Parser.lazy (\_ -> node)


nodeHelper : (List Node -> Node) -> String -> List Node -> List Node
nodeHelper nodeTag text_ tailNodes =
    case Parser.run node text_ of
        Ok parsed ->
            nodeTag parsed :: tailNodes

        Err _ ->
            Text text_ :: tailNodes


bold : Parser.Parser (List Node)
bold =
    Parser.succeed (nodeHelper Bold)
        |. Parser.symbol "*"
        |= Parser.getChompedString (Parser.chompUntil "*")
        |. Parser.symbol "*"
        |= Parser.lazy (\_ -> node)


boldFallback : Parser.Parser (List Node)
boldFallback =
    Parser.succeed (\text_ tailNodes -> Text text_ :: tailNodes)
        |= Parser.getChompedString (Parser.symbol "*")
        |= Parser.lazy (\_ -> node)


italic : Parser.Parser (List Node)
italic =
    Parser.succeed (nodeHelper Italic)
        |. Parser.symbol "_"
        |= Parser.getChompedString (Parser.chompUntil "_")
        |. Parser.symbol "_"
        |= Parser.lazy (\_ -> node)


italicFallback : Parser.Parser (List Node)
italicFallback =
    Parser.succeed (\text_ tailNodes -> Text text_ :: tailNodes)
        |= Parser.getChompedString (Parser.symbol "_")
        |= Parser.lazy (\_ -> node)


listItem : Parser.Parser (List Node)
listItem =
    Parser.succeed (nodeHelper ListItem)
        |. Parser.symbol "-"
        |. Parser.spaces
        |= Parser.getChompedString (Parser.chompUntilEndOr "\n")
        |. Parser.spaces
        |= Parser.lazy (\_ -> node)


newLine : Parser.Parser (List Node)
newLine =
    Parser.succeed (\tailNodes -> NewLine :: tailNodes)
        |. Parser.chompIf (\c -> c == '\n')
        |= Parser.lazy (\_ -> node)


end : Parser.Parser (List Node)
end =
    Parser.succeed []
        |. Parser.end


hashtag : Parser.Parser (List Node)
hashtag =
    Parser.succeed (\hashtag_ tailNodes -> Hashtag hashtag_ :: tailNodes)
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


hashtagFallback : Parser.Parser (List Node)
hashtagFallback =
    Parser.succeed (\text_ tailNodes -> Text text_ :: tailNodes)
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


text : Parser.Parser (List Node)
text =
    Parser.succeed (\text_ tailNodes -> Text text_ :: tailNodes)
        |= textString
        |= Parser.lazy (\_ -> node)


node : Parser.Parser (List Node)
node =
    Parser.oneOf
        [ end
        , newLine
        , Parser.backtrackable anchor
        , anchorFallback
        , Parser.backtrackable bold
        , boldFallback
        , Parser.backtrackable italic
        , italicFallback
        , listItem
        , Parser.backtrackable hashtag
        , hashtagFallback
        , text
        ]


render : String -> Html.Html msg
render content =
    case Parser.run node content |> Debug.log "parsed" of
        Ok node_ ->
            Html.div [] (toHtml node_ [])

        Err _ ->
            Html.div [] [ Html.text content ]


toHtml : List Node -> List (Html.Html msg) -> List (Html.Html msg)
toHtml nodes html =
    case nodes of
        [] ->
            List.reverse html

        (Text text_) :: tailNodes ->
            (Html.text text_ :: html) |> toHtml tailNodes

        (Anchor anchorNodes url_) :: tailNodes ->
            (Html.a [ HtmlAttributes.href <| Url.toString url_ ] (toHtml anchorNodes []) :: html) |> toHtml tailNodes

        (Bold boldNodes) :: tailNodes ->
            (Html.strong [] (toHtml boldNodes []) :: html) |> toHtml tailNodes

        (Italic italicNodes) :: tailNodes ->
            (Html.i [] (toHtml italicNodes []) :: html) |> toHtml tailNodes

        (ListItem listItemNodes) :: tailNodes ->
            toHtml (List [ listItemNodes ] :: tailNodes) html

        (List listNodes) :: ((ListItem listItemNodes) :: tailNodes) ->
            toHtml (List (listItemNodes :: listNodes) :: tailNodes) html

        (List listNodes) :: tailNodes ->
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
                |> toHtml tailNodes

        NewLine :: tailNodes ->
            (Html.br [] [] :: html) |> toHtml tailNodes

        (Hashtag hashtag_) :: tailNodes ->
            ((Html.text <| "#" ++ hashtag_) :: html) |> toHtml tailNodes
