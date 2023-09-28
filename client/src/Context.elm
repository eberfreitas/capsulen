module Context exposing (Context, new)

import Alert
import Browser.Navigation
import Locale
import Business.User
import View.Theme as Theme


type alias Context =
    { key : Browser.Navigation.Key
    , locale : Locale.Locale
    , theme : Theme.Theme
    , alerts : List Alert.Message
    , user : Maybe Business.User.User
    }


new : Browser.Navigation.Key -> Locale.Locale -> Theme.Theme -> Context
new key locale theme =
    { key = key
    , locale = locale
    , theme = theme
    , alerts = []
    , user = Nothing
    }
