module Context exposing (Context, new)

import Alert
import Browser.Navigation
import Business.User
import Translations
import View.Theme as Theme


type alias Context =
    { key : Browser.Navigation.Key
    , language : Translations.Language
    , theme : Theme.Theme
    , alerts : List Alert.Message
    , username : Maybe String
    , user : Maybe Business.User.User
    }


new : Browser.Navigation.Key -> Translations.Language -> Theme.Theme -> Maybe String -> Context
new key lang theme username =
    { key = key
    , language = lang
    , theme = theme
    , alerts = []
    , username = username
    , user = Nothing
    }
