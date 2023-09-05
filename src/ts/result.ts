export type Result<T, E = Error> =
  | { type: "ok"; data: T }
  | { type: "err"; error: E };
