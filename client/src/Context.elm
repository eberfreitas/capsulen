module Context exposing (Context, new)

import Alert
import Browser.Navigation
import Locale
import Business.User


type alias Context =
    { key : Browser.Navigation.Key
    , locale : Locale.Locale
    , alerts : List Alert.Message
    , user : Maybe Business.User.User
    }


new : Browser.Navigation.Key -> Locale.Locale -> Context
new key locale =
    { key = key
    , locale = locale
    , alerts = []
    , user = Nothing
    }
