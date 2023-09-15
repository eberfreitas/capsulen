module Context exposing (Context, new)

import Alert


type alias Context =
    { alerts : List Alert.Message
    , user : Maybe String
    }


new : Context
new =
    { alerts = [], user = Nothing }
