module Context exposing (Context, new)

import Alert
import Browser.Navigation
import Locale


type alias Context =
    { key : Browser.Navigation.Key
    , locale : Locale.Locale
    , alerts : List Alert.Message
    , user : Maybe String
    }


new : Browser.Navigation.Key -> Locale.Locale -> Context
new key locale =
    { key = key
    , locale = locale
    , alerts = []
    , user = Nothing
    }
