export type Result<T, E = Error> =
  | { _kind: "ok"; data: T }
  | { _kind: "err"; error: E };

export function Ok<T, E>(data: T): Result<T, E> {
  return { _kind: "ok", data };
}

export function Err<T, E>(error: E): Result<T, E> {
  return { _kind: "err", error };
}

export function withOk<T, E, R = null>(
  result: Result<T, E>,
  callback: (data: T) => R,
): R | null {
  if (result._kind === "ok") {
    return callback(result.data);
  }

  return null;
}

export function withErr<T, E, R = null>(
  result: Result<T, E>,
  callback: (error: E) => R,
): R | null {
  if (result._kind === "err") {
    return callback(result.error);
  }

  return null;
}

export function mapOk<T, E, R>(
  result: Result<T, E>,
  mapFn: (data: T) => R,
): Result<R, E> {
  if (result._kind === "ok") {
    return Ok(mapFn(result.data));
  }

  return result;
}

export function withDefault<T, E>(result: Result<T, E>, defaultValue: T): T {
  if (result._kind === "ok") {
    return result.data;
  }

  return defaultValue;
}
