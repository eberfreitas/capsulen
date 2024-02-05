module Parser.Extra exposing (chompWhileNot)

import Parser


chompWhileNot : List Char -> Parser.Parser ()
chompWhileNot notList =
    Parser.chompWhile (\char -> not <| List.member char notList)
