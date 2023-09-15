module Context exposing (Context)

import Alert
import Browser.Navigation


type alias Context =
    { key : Browser.Navigation.Key
    , alerts : List Alert.Message
    , user : Maybe String
    }
