module Tasks exposing (Error(..), Output(..), Pool)

import ConcurrentTask


type Error
    = Generic String


type Output
    = SomethingHere


type alias Pool msg =
    ConcurrentTask.Pool msg Error Output
