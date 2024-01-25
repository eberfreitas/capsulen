module Context exposing (Context, fromFlags)

import Alert
import Browser.Navigation
import Business.User
import Json.Decode
import Translations
import View.Theme


type alias Context =
    { key : Browser.Navigation.Key
    , language : Translations.Language
    , theme : View.Theme.Theme
    , alerts : List Alert.Message
    , username : Maybe String
    , user : Maybe Business.User.User
    , autoLogout : Bool
    }


new :
    Browser.Navigation.Key
    -> Translations.Language
    -> View.Theme.Theme
    -> Maybe String
    -> Bool
    -> Context
new key lang theme username autoLogout =
    { key = key
    , language = lang
    , theme = theme
    , alerts = []
    , username = username
    , user = Nothing
    , autoLogout = autoLogout
    }


fromFlags : Browser.Navigation.Key -> Json.Decode.Value -> Context
fromFlags key flags =
    flags
        |> Json.Decode.decodeValue
            (Json.Decode.map4
                (\theme language username autoLogout ->
                    { theme = theme
                    , language = language
                    , username = username
                    , autoLogout = autoLogout
                    }
                )
                (Json.Decode.field "colorScheme" Json.Decode.string
                    |> Json.Decode.andThen (View.Theme.fromString >> Json.Decode.succeed)
                )
                (Json.Decode.field "language" Json.Decode.string
                    |> Json.Decode.andThen (Translations.languageFromString >> Json.Decode.succeed)
                )
                (Json.Decode.field "username" <| Json.Decode.nullable Json.Decode.string)
                (Json.Decode.field "autoLogout" <| Json.Decode.bool)
            )
        |> Result.toMaybe
        |> Maybe.map (\{ theme, language, username, autoLogout } -> new key language theme username autoLogout)
        |> Maybe.withDefault (new key Translations.En View.Theme.Light Nothing False)
