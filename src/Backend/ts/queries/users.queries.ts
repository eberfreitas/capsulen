/** Types generated for queries found in "src/Backend/ts/queries/users.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'ExistingUser' parameters type */
export interface IExistingUserParams {
  username?: string | null | void;
}

/** 'ExistingUser' return type */
export interface IExistingUserResult {
  exists: number | null;
}

/** 'ExistingUser' query type */
export interface IExistingUserQuery {
  params: IExistingUserParams;
  result: IExistingUserResult;
}

const existingUserIR: any = {"usedParamSet":{"username":true},"params":[{"name":"username","required":false,"transform":{"type":"scalar"},"locs":[{"a":51,"b":59}]}],"statement":"SELECT 1 AS exists FROM users WHERE username ILIKE :username"};

/**
 * Query generated from SQL:
 * ```
 * SELECT 1 AS exists FROM users WHERE username ILIKE :username
 * ```
 */
export const existingUser = new PreparedQuery<IExistingUserParams,IExistingUserResult>(existingUserIR);


