port module LocalStorage exposing (set, str)

import Json.Encode


port localStorageSet : Json.Encode.Value -> Cmd msg


type Value
    = Str String


set : String -> Value -> Cmd.Cmd msg
set key value =
    let
        value_ =
            case value of
                Str str_ ->
                    Json.Encode.string str_

        data =
            Json.Encode.object
                [ ( "key", Json.Encode.string key )
                , ( "value", value_ )
                ]
    in
    localStorageSet data


str : String -> Value
str =
    Str
