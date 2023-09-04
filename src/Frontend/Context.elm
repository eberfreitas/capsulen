module Frontend.Context exposing (Context, new)

import Frontend.Alert


type alias Context =
    { alerts : List Frontend.Alert.Message }


new : Context
new =
    { alerts = [] }
