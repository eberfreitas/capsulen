module Page exposing (TaskError(..), httpErrorMapper, nonEmptyInputParser)

import ConcurrentTask.Http
import Json.Decode
import Translations


type TaskError
    = RequestError ConcurrentTask.Http.Error
    | Generic Translations.Key


httpErrorMapper : ConcurrentTask.Http.Error -> TaskError
httpErrorMapper error =
    case error of
        ConcurrentTask.Http.BadStatus meta value ->
            if List.member meta.statusCode [ 400, 500 ] then
                value
                    |> Json.Decode.decodeValue Json.Decode.string
                    |> Result.toMaybe
                    |> Maybe.map Translations.keyFromString
                    |> Maybe.withDefault Translations.UnknownError
                    |> Generic

            else
                RequestError error

        _ ->
            RequestError error


nonEmptyInputParser : String -> Result Translations.Key String
nonEmptyInputParser value =
    let
        parsedValue : String
        parsedValue =
            String.trim value
    in
    if parsedValue == "" then
        Err Translations.InputEmpty

    else
        Ok parsedValue
