export type Result<T, E = Error> =
  | { type: "ok"; data: T }
  | { type: "err"; error: E };

export function Ok<E, T>(data: T): Result<T, E> {
  return { type: "ok", data };
}

export function Err<E, T>(error: E): Result<T, E> {
  return { type: "err", error };
}
