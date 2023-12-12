module Translations exposing (main)

import Dict
import Elm
import Elm.Annotation
import Elm.Case
import Elm.Let
import Elm.Op
import Gen.CodeGen.Generate as Generate
import Gen.Dict
import Gen.Maybe
import Json.Decode
import Set


type alias Translations =
    Dict.Dict String (Dict.Dict String String)


decodeTranslations : Json.Decode.Decoder Translations
decodeTranslations =
    Json.Decode.dict (Json.Decode.dict Json.Decode.string)


main : Program Json.Decode.Value () ()
main =
    Generate.fromJson decodeTranslations generate


generate : Translations -> List Elm.File
generate translations =
    let
        languages =
            getAllLanguages translations

        languageTypeString =
            "Language"

        keyTypeString =
            "Key"

        languageTypeAnnotation : Elm.Annotation.Annotation
        languageTypeAnnotation =
            Elm.Annotation.named [] languageTypeString

        keyTypeAnnotation : Elm.Annotation.Annotation
        keyTypeAnnotation =
            Elm.Annotation.named [] keyTypeString
    in
    [ Elm.file [ "Translations" ]
        [ Elm.customType languageTypeString
            (languages
                |> Set.toList
                |> List.map (\lang -> lang |> camelCase |> Elm.variant)
            )
        , Elm.customType keyTypeString
            (translations
                |> Dict.keys
                |> List.map
                    (\key -> key |> camelCase |> Elm.variant)
            )
        , Elm.declaration "languageFromString"
            (Elm.fn
                ( "language", Nothing )
                (\language ->
                    Elm.Case.string language
                        { cases =
                            languages
                                |> Set.toList
                                |> List.map (\lang -> ( lang, Elm.val (camelCase lang) ))
                        , otherwise =
                            languages
                                |> Set.toList
                                |> List.head
                                |> Maybe.map camelCase
                                |> Maybe.withDefault "En"
                                |> Elm.val
                        }
                )
                |> Elm.withType (Elm.Annotation.function [ Elm.Annotation.string ] languageTypeAnnotation)
            )
        , Elm.declaration "languageToString"
            (Elm.fn
                ( "language", Just languageTypeAnnotation )
                (\language ->
                    Elm.Case.custom language
                        (Elm.Annotation.var "Language")
                        (languages
                            |> Set.toList
                            |> List.map (\lang -> Elm.Case.branch0 lang (Elm.string lang))
                        )
                )
            )
        , Elm.declaration "keyToString"
            (Elm.fn
                ( "key", Just keyTypeAnnotation )
                (\key ->
                    Elm.Case.custom key
                        (Elm.Annotation.var "Key")
                        (translations
                            |> Dict.keys
                            |> List.map (\key_ -> Elm.Case.branch0 (camelCase key_) (Elm.string key_))
                        )
                )
            )
        , Elm.declaration "translate"
            (Elm.fn2
                ( "lang", Just languageTypeAnnotation )
                ( "key", Just keyTypeAnnotation )
                (\lang key ->
                    Elm.Let.letIn
                        (\langString keyString ->
                            Gen.Dict.get langString (Elm.val "phrases")
                                |> Elm.Op.pipe
                                    (Elm.fn ( "maybePhrases", Nothing )
                                        (\maybePhrases ->
                                            Gen.Maybe.andThen
                                                (\phrases_ -> Gen.Dict.get keyString phrases_)
                                                maybePhrases
                                        )
                                    )
                                |> Elm.Op.pipe
                                    (Elm.fn ( "maybePhrase", Nothing )
                                        (\maybePhrase ->
                                            Gen.Maybe.withDefault keyString maybePhrase
                                        )
                                    )
                        )
                        |> Elm.Let.value "langString" (lang |> Elm.Op.pipe (Elm.val "languageToString"))
                        |> Elm.Let.value "keyString" (key |> Elm.Op.pipe (Elm.val "keyToString"))
                        |> Elm.Let.toExpression
                )
                |> Elm.withType
                    (Elm.Annotation.function
                        [ languageTypeAnnotation, keyTypeAnnotation ]
                        Elm.Annotation.string
                    )
            )
        , Elm.declaration "translateUnsafe"
            (Elm.fn2
                ( "lang", Just languageTypeAnnotation )
                ( "key", Just Elm.Annotation.string )
                (\lang key ->
                    Elm.Let.letIn
                        (\langString ->
                            Gen.Dict.get langString (Elm.val "phrases")
                                |> Elm.Op.pipe
                                    (Elm.fn ( "maybePhrases", Nothing )
                                        (\maybePhrases ->
                                            Gen.Maybe.andThen
                                                (\phrases_ -> Gen.Dict.get key phrases_)
                                                maybePhrases
                                        )
                                    )
                                |> Elm.Op.pipe
                                    (Elm.fn ( "maybePhrase", Nothing )
                                        (\maybePhrase ->
                                            Gen.Maybe.withDefault key maybePhrase
                                        )
                                    )
                        )
                        |> Elm.Let.value "langString" (lang |> Elm.Op.pipe (Elm.val "languageToString"))
                        |> Elm.Let.toExpression
                )
                |> Elm.withType
                    (Elm.Annotation.function
                        [ languageTypeAnnotation, Elm.Annotation.string ]
                        Elm.Annotation.string
                    )
            )
        , Elm.declaration "phrases"
            (Gen.Dict.fromList
                (translations
                    |> Dict.toList
                    |> List.map
                        (\( key, phrases ) ->
                            Elm.tuple (Elm.string key)
                                (Gen.Dict.fromList
                                    (phrases
                                        |> Dict.toList
                                        |> List.map
                                            (\( lang, phrase ) ->
                                                Elm.tuple (Elm.string lang) (Elm.string phrase)
                                            )
                                    )
                                )
                        )
                )
            )
        ]
    ]


getAllLanguages : Translations -> Set.Set String
getAllLanguages translations =
    translations
        |> Dict.values
        |> List.map Dict.keys
        |> List.concatMap identity
        |> Set.fromList


capitalize : String -> String
capitalize str =
    case String.uncons str of
        Just ( first, rest ) ->
            (first |> Char.toUpper |> String.fromChar) ++ rest

        Nothing ->
            str


camelCase : String -> String
camelCase str =
    str
        |> String.split "_"
        |> List.map (\fragment -> fragment |> String.toLower |> capitalize)
        |> String.join ""
