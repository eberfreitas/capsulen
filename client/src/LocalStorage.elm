port module LocalStorage exposing (bool, set, str)

import Json.Encode


port localStorageSet : Json.Encode.Value -> Cmd msg


type Value
    = Str String
    | Boolean Bool


set : String -> Value -> Cmd.Cmd msg
set key value =
    let
        value_ =
            case value of
                Str str_ ->
                    Json.Encode.string str_

                Boolean bool_ ->
                    Json.Encode.bool bool_

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


bool : Bool -> Value
bool =
    Boolean
