module Page exposing (TaskError(..), done, httpErrorMapper, nonEmptyInputParser)

import ConcurrentTask.Http
import Effect
import Json.Decode


type TaskError
    = RequestError ConcurrentTask.Http.Error
    | Generic String


httpErrorMapper : ConcurrentTask.Http.Error -> TaskError
httpErrorMapper error =
    case error of
        ConcurrentTask.Http.BadStatus meta value ->
            if List.member meta.statusCode [ 400, 500 ] then
                value
                    |> Json.Decode.decodeValue Json.Decode.string
                    |> Result.toMaybe
                    |> Maybe.withDefault "UNKNOWN_ERROR"
                    |> Generic

            else
                RequestError error

        _ ->
            RequestError error


done : model -> ( model, Effect.Effect, Cmd msg )
done model =
    ( model, Effect.none, Cmd.none )


nonEmptyInputParser : String -> Result String String
nonEmptyInputParser value =
    let
        parsedValue : String
        parsedValue =
            String.trim value
    in
    if parsedValue == "" then
        Err "INPUT_EMPTY"

    else
        Ok parsedValue
