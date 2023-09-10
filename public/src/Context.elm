module Context exposing (Context, new)

import Alert


type alias Context =
    { alerts : List Alert.Message }


new : Context
new =
    { alerts = [] }
