module Business.Post.ContentParser exposing (..)

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
    | Url Url.Url
    | Text String
    | End


anchor : Parser.Parser Node
anchor =
    (Parser.succeed
        (\anchorText url_ -> ( anchorText, url_ ))
        |. Parser.symbol "["
        |= Parser.getChompedString (Parser.chompUntil "]")
        |. Parser.symbol "]"
        |. Parser.symbol "("
        |= Parser.getChompedString (Parser.chompUntil ")")
        |. Parser.symbol ")"
    )
        |> Parser.andThen
            (\( anchorText, url_ ) ->
                case ( Parser.run nodes anchorText, Url.fromString url_ ) of
                    ( Ok anchorNodes, Just parsedUrl ) ->
                        Parser.succeed <| Anchor anchorNodes parsedUrl

                    _ ->
                        Parser.problem "Could not produce anchor"
            )


anchorFallback : Parser.Parser Node
anchorFallback =
    Parser.succeed Text
        |= Parser.getChompedString (Parser.symbol "[")


nodeHelper : (List Node -> Node) -> String -> Node
nodeHelper nodeTag text_ =
    case Parser.run nodes text_ of
        Ok parsed ->
            nodeTag parsed

        Err _ ->
            Text text_


bold : Parser.Parser Node
bold =
    Parser.succeed (nodeHelper Bold)
        |. Parser.symbol "*"
        |= Parser.getChompedString (Parser.chompUntil "*")
        |. Parser.symbol "*"


boldFallback : Parser.Parser Node
boldFallback =
    Parser.succeed Text
        |= Parser.getChompedString (Parser.symbol "*")


italic : Parser.Parser Node
italic =
    Parser.succeed (nodeHelper Italic)
        |. Parser.symbol "_"
        |= Parser.getChompedString (Parser.chompUntil "_")
        |. Parser.symbol "_"


italicFallback : Parser.Parser Node
italicFallback =
    Parser.succeed Text
        |= Parser.getChompedString (Parser.symbol "_")


listItem : Parser.Parser Node
listItem =
    Parser.succeed (nodeHelper ListItem)
        |. Parser.symbol "-"
        |. Parser.spaces
        |= Parser.getChompedString (Parser.chompUntilEndOr "\n")
        |. Parser.spaces


newLine : Parser.Parser Node
newLine =
    Parser.succeed NewLine
        |. Parser.chompIf (\c -> c == '\n')


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


hashtagFallback : Parser.Parser Node
hashtagFallback =
    Parser.succeed Text
        |= Parser.getChompedString (Parser.symbol "#")


url : Parser.Parser Node
url =
    Parser.succeed
        (\h protocol rest ->
            let
                url_ =
                    h ++ protocol ++ rest
            in
            case Url.fromString url_ of
                Just parsed ->
                    Url parsed

                Nothing ->
                    Text url_
        )
        |= Parser.getChompedString (Parser.symbol "h")
        |= Parser.getChompedString (Parser.oneOf [ Parser.token "ttp://", Parser.token "ttps://" ])
        |= Parser.getChompedString (Parser.chompWhile (\c -> c /= ' ' && c /= '\n'))


urlFallback : Parser.Parser Node
urlFallback =
    Parser.succeed Text
        |= Parser.getChompedString (Parser.symbol "h")


textString : Parser.Parser String
textString =
    let
        nodeTokens =
            [ 'h', '[', '*', '_', '\n', '#' ]

        whileFn =
            \char -> not <| List.member char nodeTokens
    in
    Parser.succeed identity
        |= Parser.getChompedString (Parser.chompWhile whileFn)


text : Parser.Parser Node
text =
    Parser.succeed Text
        |= textString


nodes : Parser.Parser (List Node)
nodes =
    Parser.loop [] nodesHelper


nodesHelper : List Node -> Parser.Parser (Parser.Step (List Node) (List Node))
nodesHelper nodes_ =
    Parser.oneOf
        [ end |> Parser.map (\_ -> Parser.Done (List.reverse nodes_))
        , newLine |> Parser.map (\node -> Parser.Loop (node :: nodes_))
        , Parser.backtrackable anchor |> Parser.map (\node -> Parser.Loop (node :: nodes_))
        , anchorFallback |> Parser.map (\node -> Parser.Loop (node :: nodes_))
        , Parser.backtrackable bold |> Parser.map (\node -> Parser.Loop (node :: nodes_))
        , boldFallback |> Parser.map (\node -> Parser.Loop (node :: nodes_))
        , Parser.backtrackable italic |> Parser.map (\node -> Parser.Loop (node :: nodes_))
        , italicFallback |> Parser.map (\node -> Parser.Loop (node :: nodes_))
        , Parser.backtrackable hashtag |> Parser.map (\node -> Parser.Loop (node :: nodes_))
        , hashtagFallback |> Parser.map (\node -> Parser.Loop (node :: nodes_))
        , Parser.backtrackable url |> Parser.map (\node -> Parser.Loop (node :: nodes_))
        , urlFallback |> Parser.map (\node -> Parser.Loop (node :: nodes_))
        , listItem |> Parser.map (\node -> Parser.Loop (node :: nodes_))
        , text |> Parser.map (\node -> Parser.Loop (node :: nodes_))
        ]


render : String -> Html.Html msg
render content =
    case Parser.run nodes content |> Debug.log "parsed" of
        Ok node_ ->
            Html.div [] (toHtml node_ [])

        Err _ ->
            Html.div [] [ Html.text content ]


toHtml : List Node -> List (Html.Html msg) -> List (Html.Html msg)
toHtml nodes_ html =
    case nodes_ of
        [] ->
            List.reverse html

        End :: _ ->
            toHtml [] html

        (Url url_) :: tailNodes ->
            let
                urlAsString =
                    Url.toString url_
            in
            (Html.a [ HtmlAttributes.href urlAsString ] [ Html.text urlAsString ] :: html) |> toHtml tailNodes

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
