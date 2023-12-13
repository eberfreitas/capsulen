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
    , user : Maybe Business.User.User
    }


new : Browser.Navigation.Key -> Translations.Language -> Theme.Theme -> Context
new key lang theme =
    { key = key
    , language = lang
    , theme = theme
    , alerts = []
    , user = Nothing
    }
