module Tasks exposing (Error(..), Output(..), Pool, toResult)

import ConcurrentTask


type Error
    = Generic String
    | RegisterError String


type Output
    = Register ()


type alias Pool msg =
    ConcurrentTask.Pool msg Error Output


toResult : ConcurrentTask.Response Error Output -> Result Error Output
toResult response =
    case response of
        ConcurrentTask.Success output ->
            Ok output

        ConcurrentTask.Error error ->
            Err error

        ConcurrentTask.UnexpectedError _ ->
            Err <| Generic "Unexpected Error"
