module Page exposing (TaskError(..), done, httpErrorMapper)

import ConcurrentTask.Http
import Effect
import Json.Decode


type TaskError
    = RequestError ConcurrentTask.Http.Error
    | Generic String


done : model -> ( model, Effect.Effect, Cmd msg )
done model =
    ( model, Effect.none, Cmd.none )


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
