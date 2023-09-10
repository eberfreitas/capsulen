/** Types generated for queries found in "src/queries/user.sql" */
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

const existingUserIR: any = {"usedParamSet":{"username":true},"params":[{"name":"username","required":false,"transform":{"type":"scalar"},"locs":[{"a":51,"b":59}]}],"statement":"SELECT 1 AS exists FROM users WHERE username ILIKE :username LIMIT 1"};

/**
 * Query generated from SQL:
 * ```
 * SELECT 1 AS exists FROM users WHERE username ILIKE :username LIMIT 1
 * ```
 */
export const existingUser = new PreparedQuery<IExistingUserParams,IExistingUserResult>(existingUserIR);


/** 'CreateUserRequest' parameters type */
export interface ICreateUserRequestParams {
  user: {
    username: string | null | void,
    nonce: string | null | void,
    challenge: string | null | void
  };
}

/** 'CreateUserRequest' return type */
export type ICreateUserRequestResult = void;

/** 'CreateUserRequest' query type */
export interface ICreateUserRequestQuery {
  params: ICreateUserRequestParams;
  result: ICreateUserRequestResult;
}

const createUserRequestIR: any = {"usedParamSet":{"user":true},"params":[{"name":"user","required":false,"transform":{"type":"pick_tuple","keys":[{"name":"username","required":false},{"name":"nonce","required":false},{"name":"challenge","required":false}]},"locs":[{"a":54,"b":58}]}],"statement":"INSERT INTO users (username, nonce, challenge) VALUES :user"};

/**
 * Query generated from SQL:
 * ```
 * INSERT INTO users (username, nonce, challenge) VALUES :user
 * ```
 */
export const createUserRequest = new PreparedQuery<ICreateUserRequestParams,ICreateUserRequestResult>(createUserRequestIR);


