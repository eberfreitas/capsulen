module Context exposing (Context, new)

import Alert
import Browser.Navigation


type alias Context =
    { key : Browser.Navigation.Key
    , alerts : List Alert.Message
    , user : Maybe String
    }


new : Browser.Navigation.Key -> Context
new key =
    { key = key
    , alerts = []
    , user = Nothing
    }
