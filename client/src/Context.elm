module Context exposing (Context, new)

import Alert
import Browser.Navigation
import ConcurrentTask
import Tasks


type alias Context msg =
    { key : Browser.Navigation.Key
    , tasks : Tasks.Pool msg
    , alerts : List Alert.Message
    , user : Maybe String
    }


new : Browser.Navigation.Key -> Context msg
new key =
    { key = key
    , tasks = ConcurrentTask.pool
    , alerts = []
    , user = Nothing
    }
