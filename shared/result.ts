export type Result<T, E = Error> =
  | { _kind: "ok"; data: T }
  | { _kind: "err"; error: E };

export function Ok<E, T>(data: T): Result<T, E> {
  return { _kind: "ok", data };
}

export function Err<E, T>(error: E): Result<T, E> {
  return { _kind: "err", error };
}
