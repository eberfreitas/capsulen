module Business.Post.Content exposing (Node(..), parse, toHtml)

import AppUrl
import Color.Extra
import Css
import Dict
import Html.Styled as Html
import Html.Styled.Attributes as HtmlAttributes
import List.Extra
import Parser exposing ((|.), (|=))
import Parser.Extra
import Phosphor
import Url
import View.Theme


type Node
    = Anchor (List Node) Url.Url
    | Bold (List Node)
    | Italic (List Node)
    | Strikethrough (List Node)
    | ListItem (List Node)
    | List (List (List Node))
    | NewLine
    | Hashtag String
    | Url Url.Url
    | Text String
    | Code String
    | CodeBlock String
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
                case ( Parser.run parser anchorText, Url.fromString url_ ) of
                    ( Ok anchorNodes, Just parsedUrl ) ->
                        Parser.succeed <| Anchor anchorNodes parsedUrl

                    _ ->
                        Parser.problem "Could not produce anchor"
            )


anchorFallback : Parser.Parser Node
anchorFallback =
    Parser.succeed Text
        |= Parser.getChompedString (Parser.symbol "[")


nodeHelper : (List Node -> Node) -> String -> Parser.Parser Node
nodeHelper nodeTag text_ =
    if text_ == "" then
        Parser.problem "Value can't be empty"

    else
        case Parser.run parser text_ of
            Ok parsed ->
                Parser.succeed <| nodeTag parsed

            Err _ ->
                Parser.succeed <| Text text_


bold : Parser.Parser Node
bold =
    (Parser.succeed identity
        |. Parser.symbol "*"
        |= Parser.getChompedString (Parser.chompUntil "*")
        |. Parser.symbol "*"
    )
        |> Parser.andThen (nodeHelper Bold)


boldFallback : Parser.Parser Node
boldFallback =
    Parser.succeed Text
        |= Parser.getChompedString (Parser.symbol "*")


italic : Parser.Parser Node
italic =
    (Parser.succeed identity
        |. Parser.symbol "_"
        |= Parser.getChompedString (Parser.chompUntil "_")
        |. Parser.symbol "_"
    )
        |> Parser.andThen (nodeHelper Italic)


italicFallback : Parser.Parser Node
italicFallback =
    Parser.succeed Text
        |= Parser.getChompedString (Parser.symbol "_")


strikethrough : Parser.Parser Node
strikethrough =
    (Parser.succeed identity
        |. Parser.symbol "~"
        |= Parser.getChompedString (Parser.chompUntil "~")
        |. Parser.symbol "~"
    )
        |> Parser.andThen (nodeHelper Strikethrough)


strikethroughFallback : Parser.Parser Node
strikethroughFallback =
    Parser.succeed Text
        |= Parser.getChompedString (Parser.symbol "~")


listItem : Parser.Parser Node
listItem =
    (Parser.succeed identity
        |. Parser.symbol "-"
        |. Parser.spaces
        |= Parser.getChompedString (Parser.chompUntilEndOr "\n")
        |. Parser.spaces
    )
        |> Parser.andThen (nodeHelper ListItem)


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
        |= (Parser.getChompedString (Parser.chompWhile Char.isAlphaNum)
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
        (\protocol rest ->
            let
                url_ : String
                url_ =
                    protocol ++ rest
            in
            case Url.fromString url_ of
                Just parsed ->
                    Url parsed

                Nothing ->
                    Text url_
        )
        |= Parser.getChompedString (Parser.oneOf [ Parser.token "http://", Parser.token "https://" ])
        |= Parser.getChompedString (Parser.Extra.chompWhileNot [ ' ', '\n' ])


blockCode : Parser.Parser Node
blockCode =
    (Parser.succeed identity
        |. Parser.symbol "```"
        |= Parser.getChompedString (Parser.chompUntil "```")
        |. Parser.symbol "```"
    )
        |> Parser.andThen
            (\text_ ->
                if text_ == "" then
                    Parser.problem "Value can't be empty"

                else
                    Parser.succeed <| CodeBlock text_
            )


code : Parser.Parser Node
code =
    (Parser.succeed identity
        |. Parser.symbol "`"
        |= Parser.getChompedString (Parser.chompUntil "`")
        |. Parser.symbol "`"
    )
        |> Parser.andThen
            (\text_ ->
                if text_ == "" then
                    Parser.problem "Value can't be empty"

                else
                    Parser.succeed <| Code text_
            )


codeFallback : Parser.Parser Node
codeFallback =
    Parser.succeed Text
        |= Parser.getChompedString (Parser.symbol "`")


loop : List Node -> Parser.Parser Node -> Parser.Parser (Parser.Step (List Node) (List Node))
loop nodes =
    Parser.map (\node -> Parser.Loop (node :: nodes))


text : Parser.Parser (List Node)
text =
    Parser.succeed
        (\text_ ->
            let
                parserHelper : List Node -> Parser.Parser (Parser.Step (List Node) (List Node))
                parserHelper nodes =
                    let
                        loop_ : Parser.Parser Node -> Parser.Parser (Parser.Step (List Node) (List Node))
                        loop_ =
                            loop nodes
                    in
                    Parser.oneOf
                        [ Parser.end |> Parser.map (\_ -> Parser.Done nodes)
                        , url |> loop_
                        , Parser.succeed Text |= Parser.getChompedString (Parser.chompUntil "http://") |> loop_
                        , Parser.succeed Text |= Parser.getChompedString (Parser.chompUntil "https://") |> loop_
                        , Parser.succeed Text |= Parser.getChompedString (Parser.chompWhile (always True)) |> loop_
                        ]

                parser_ : Parser.Parser (List Node)
                parser_ =
                    Parser.loop [] parserHelper
            in
            case Parser.run parser_ text_ of
                Ok nodes ->
                    nodes

                Err _ ->
                    [ Text text_ ]
        )
        |= Parser.getChompedString (Parser.Extra.chompWhileNot [ '[', '*', '_', '~', '`', '\n', '#' ])


nodesHelper : List Node -> Parser.Parser (Parser.Step (List Node) (List Node))
nodesHelper nodes =
    let
        loop_ : Parser.Parser Node -> Parser.Parser (Parser.Step (List Node) (List Node))
        loop_ =
            loop nodes
    in
    Parser.oneOf
        [ end |> Parser.map (\_ -> Parser.Done (List.reverse nodes))
        , newLine |> loop_
        , Parser.backtrackable anchor |> loop_
        , anchorFallback |> loop_
        , Parser.backtrackable bold |> loop_
        , boldFallback |> loop_
        , Parser.backtrackable italic |> loop_
        , italicFallback |> loop_
        , Parser.backtrackable strikethrough |> loop_
        , strikethroughFallback |> loop_
        , Parser.backtrackable blockCode |> loop_
        , Parser.backtrackable code |> loop_
        , codeFallback |> loop_
        , Parser.backtrackable hashtag |> loop_
        , hashtagFallback |> loop_
        , listItem |> loop_
        , text |> Parser.map (\node -> Parser.Loop (node ++ nodes))
        ]


parser : Parser.Parser (List Node)
parser =
    Parser.loop [] nodesHelper


preprocess : List Node -> List Node -> List Node
preprocess nodes acc =
    case nodes of
        [] ->
            List.reverse acc

        (Url url_) :: ((Italic [ Text text_ ]) :: tailNodes) ->
            if String.slice 0 1 text_ /= " " then
                preprocess (Url url_ :: (Text ("_" ++ text_ ++ "_") :: tailNodes)) acc

            else
                preprocess tailNodes (Italic [ Text text_ ] :: Url url_ :: acc)

        (Url url_) :: ((Text text_) :: tailNodes) ->
            let
                default =
                    preprocess tailNodes (Text text_ :: Url url_ :: acc)
            in
            if String.slice 0 1 text_ /= " " then
                case String.split " " text_ of
                    [] ->
                        []

                    [ t ] ->
                        Url.toString url_
                            ++ t
                            |> Url.fromString
                            |> Maybe.map (\u -> preprocess (Url u :: tailNodes) acc)
                            |> Maybe.withDefault default

                    t :: _ ->
                        let
                            newText =
                                String.slice (String.length t) (String.length text_) text_
                        in
                        Url.toString url_
                            ++ t
                            |> Url.fromString
                            |> Maybe.map (\u -> preprocess tailNodes (Text newText :: Url u :: acc))
                            |> Maybe.withDefault default

            else
                default

        (ListItem listItemNodes) :: tailNodes ->
            preprocess (List [ listItemNodes ] :: tailNodes) acc

        (List listNodes) :: ((ListItem listItemNodes) :: tailNodes) ->
            preprocess (List (listItemNodes :: listNodes) :: tailNodes) acc

        node :: tailNodes ->
            preprocess tailNodes (node :: acc)


parse : String -> List Node
parse content =
    case Parser.run parser content of
        Ok nodes ->
            preprocess nodes []

        Err _ ->
            []


isYouTube : Url.Url -> Bool
isYouTube url_ =
    let
        youtubeDomains : List String
        youtubeDomains =
            [ "youtube.com", "www.youtube.com", "youtu.be" ]
    in
    youtubeDomains
        |> List.map (\domain -> String.startsWith domain url_.host)
        |> List.member True


isImage : Url.Url -> Bool
isImage url_ =
    let
        imageExtensions : List String
        imageExtensions =
            [ "png", "jpg", "jpeg", "gif", "webp" ]
    in
    imageExtensions
        |> List.map (\ext -> String.endsWith ext url_.path)
        |> List.member True


embedLink : View.Theme.Theme -> List (Html.Html msg) -> Url.Url -> Html.Html msg
embedLink theme contents url_ =
    let
        urlAsString : String
        urlAsString =
            Url.toString url_
    in
    Html.a
        [ HtmlAttributes.href urlAsString
        , HtmlAttributes.target "_blank"
        , HtmlAttributes.rel "noreferrer"
        , HtmlAttributes.css [ Css.color (theme |> View.Theme.textColor |> Color.Extra.toCss) ]
        ]
        (case contents of
            [] ->
                [ Html.text urlAsString ]

            _ ->
                contents
        )


embedYouTube : View.Theme.Theme -> Url.Url -> Html.Html msg
embedYouTube theme url_ =
    let
        videoId : Maybe String
        videoId =
            url_
                |> AppUrl.fromUrl
                |> (\u -> u |> .queryParameters |> Dict.get "v")
                |> Maybe.andThen (List.Extra.getAt 0)
    in
    case videoId of
        Just videoId_ ->
            Html.div []
                [ Html.a
                    [ HtmlAttributes.href <| Url.toString url_
                    , HtmlAttributes.target "_blank"
                    , HtmlAttributes.rel "noreferrer"
                    , HtmlAttributes.css [ Css.display Css.block, Css.position Css.relative ]
                    ]
                    [ Html.img
                        [ HtmlAttributes.src <| "https://img.youtube.com/vi/" ++ videoId_ ++ "/hqdefault.jpg"
                        , HtmlAttributes.css
                            [ Css.display Css.block
                            , Css.width <| Css.pct 100
                            , Css.property "aspect-ratio" "16/9"
                            , Css.property "object-fit" "cover"
                            , Css.borderRadius <| Css.rem 0.5
                            ]
                        ]
                        []
                    , Html.div
                        [ HtmlAttributes.css
                            [ Css.backgroundColor <| Css.hex "#F00"
                            , Css.color <| Css.hex "#FFF"
                            , Css.position Css.absolute
                            , Css.top <| Css.px 0
                            , Css.right <| Css.px 0
                            , Css.fontSize <| Css.rem 4
                            , Css.lineHeight <| Css.num 0
                            , Css.padding2 (Css.rem 0.5) (Css.rem 1)
                            , Css.borderRadius2 (Css.px 0) (Css.rem 0.5)
                            ]
                        ]
                        [ Phosphor.youtubeLogo Phosphor.Regular |> Phosphor.toHtml [] |> Html.fromUnstyled ]
                    ]
                ]

        Nothing ->
            embedLink theme [] url_


embedImage : Url.Url -> Html.Html msg
embedImage url_ =
    let
        urlAsString : String
        urlAsString =
            Url.toString url_
    in
    Html.div
        [ HtmlAttributes.css
            [ Css.displayFlex
            , Css.justifyContent Css.center
            ]
        ]
        [ Html.a
            [ HtmlAttributes.css [ Css.display Css.block ]
            , HtmlAttributes.href urlAsString
            , HtmlAttributes.target "_blank"
            , HtmlAttributes.rel "noreferrer"
            ]
            [ Html.img
                [ HtmlAttributes.src urlAsString
                , HtmlAttributes.css
                    [ Css.display Css.block
                    , Css.maxWidth <| Css.pct 100
                    , Css.borderRadius <| Css.rem 0.5
                    ]
                ]
                []
            ]
        ]


processSingleLink : View.Theme.Theme -> Url.Url -> Html.Html msg
processSingleLink theme url_ =
    if isImage url_ then
        embedImage url_

    else if isYouTube url_ then
        embedYouTube theme url_

    else
        embedLink theme [] url_


toHtml : View.Theme.Theme -> List Node -> List (Html.Html msg) -> List (Html.Html msg)
toHtml theme nodes html =
    let
        recurse : List Node -> List (Html.Html msg) -> List (Html.Html msg)
        recurse =
            toHtml theme
    in
    case nodes of
        [] ->
            List.reverse html

        End :: _ ->
            recurse [] html

        [ Url url_ ] ->
            processSingleLink theme url_ :: html |> recurse []

        NewLine :: ((Url url_) :: []) ->
            processSingleLink theme url_ :: html |> recurse []

        NewLine :: ((Url url_) :: (NewLine :: tailNodes)) ->
            processSingleLink theme url_ :: html |> recurse tailNodes

        NewLine :: tailNodes ->
            (Html.br [] [] :: html) |> recurse tailNodes

        (Url url_) :: tailNodes ->
            (embedLink theme [] url_ :: html) |> recurse tailNodes

        (Text text1) :: ((Text text2) :: tailNodes) ->
            recurse (Text (text1 ++ text2) :: tailNodes) html

        (Text text_) :: tailNodes ->
            (Html.text text_ :: html) |> recurse tailNodes

        (Anchor anchorNodes url_) :: tailNodes ->
            (embedLink theme (recurse anchorNodes []) url_ :: html) |> recurse tailNodes

        (Bold boldNodes) :: tailNodes ->
            (Html.strong [] (recurse boldNodes []) :: html) |> recurse tailNodes

        (Italic italicNodes) :: tailNodes ->
            (Html.i [] (recurse italicNodes []) :: html) |> recurse tailNodes

        (Strikethrough stNodes) :: tailNodes ->
            (Html.span [ HtmlAttributes.css [ Css.textDecorationLine Css.lineThrough ] ]
                (recurse stNodes [])
                :: html
            )
                |> recurse tailNodes

        (ListItem _) :: tailNodes ->
            -- After `preprocess` we should not have any `ListItem` in place, skip
            recurse tailNodes html

        (List listNodes) :: tailNodes ->
            (Html.ul
                [ HtmlAttributes.css
                    [ Css.margin2 (Css.rem 1) (Css.px 0)
                    , Css.padding <| Css.px 0
                    , Css.listStylePosition Css.inside
                    ]
                ]
                (listNodes
                    |> List.reverse
                    |> List.map
                        (\itemNode ->
                            Html.li [] (recurse itemNode [])
                        )
                )
                :: html
            )
                |> recurse tailNodes

        (Hashtag hashtag_) :: tailNodes ->
            ((Html.text <| "#" ++ hashtag_) :: html) |> recurse tailNodes

        (Code code_) :: tailNodes ->
            (Html.code
                [ HtmlAttributes.css
                    [ Css.display Css.inlineBlock
                    , Css.backgroundColor (theme |> View.Theme.textColor |> Color.Extra.withAlpha 0.1 |> Color.Extra.toCss)
                    , Css.borderRadius <| Css.rem 0.5
                    , Css.padding2 (Css.px 0) (Css.rem 0.6)
                    ]
                ]
                [ Html.text code_ ]
                :: html
            )
                |> recurse tailNodes

        (CodeBlock code_) :: tailNodes ->
            (Html.pre
                [ HtmlAttributes.css
                    [ Css.borderRadius <| Css.rem 0.5
                    , Css.backgroundColor (theme |> View.Theme.textColor |> Color.Extra.withAlpha 0.1 |> Color.Extra.toCss)
                    , Css.margin <| Css.px 0
                    , Css.padding <| Css.rem 1
                    ]
                ]
                [ Html.text <| String.trim code_ ]
                :: html
            )
                |> recurse tailNodes
