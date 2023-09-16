/** Types generated for queries found in "db/queries/users.sql" */
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

const existingUserIR: any = {"usedParamSet":{"username":true},"params":[{"name":"username","required":false,"transform":{"type":"scalar"},"locs":[{"a":63,"b":71}]}],"statement":"SELECT\n    1 AS exists\nFROM\n    users\nWHERE\n    username ILIKE :username\nLIMIT 1"};

/**
 * Query generated from SQL:
 * ```
 * SELECT
 *     1 AS exists
 * FROM
 *     users
 * WHERE
 *     username ILIKE :username
 * LIMIT 1
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

const createUserRequestIR: any = {"usedParamSet":{"user":true},"params":[{"name":"user","required":false,"transform":{"type":"pick_tuple","keys":[{"name":"username","required":false},{"name":"nonce","required":false},{"name":"challenge","required":false}]},"locs":[{"a":62,"b":66}]}],"statement":"INSERT INTO\n    users (username, nonce, challenge)\nVALUES\n    :user"};

/**
 * Query generated from SQL:
 * ```
 * INSERT INTO
 *     users (username, nonce, challenge)
 * VALUES
 *     :user
 * ```
 */
export const createUserRequest = new PreparedQuery<ICreateUserRequestParams,ICreateUserRequestResult>(createUserRequestIR);


/** 'GetPendingUser' parameters type */
export interface IGetPendingUserParams {
  nonce?: string | null | void;
  username?: string | null | void;
}

/** 'GetPendingUser' return type */
export interface IGetPendingUserResult {
  id: number;
}

/** 'GetPendingUser' query type */
export interface IGetPendingUserQuery {
  params: IGetPendingUserParams;
  result: IGetPendingUserResult;
}

const getPendingUserIR: any = {"usedParamSet":{"username":true,"nonce":true},"params":[{"name":"username","required":false,"transform":{"type":"scalar"},"locs":[{"a":53,"b":61}]},{"name":"nonce","required":false,"transform":{"type":"scalar"},"locs":[{"a":82,"b":87}]}],"statement":"SELECT\n    id\nFROM\n    users\nWHERE\n    username LIKE :username\n    AND nonce LIKE :nonce\n    AND status = 'requested'\nLIMIT 1"};

/**
 * Query generated from SQL:
 * ```
 * SELECT
 *     id
 * FROM
 *     users
 * WHERE
 *     username LIKE :username
 *     AND nonce LIKE :nonce
 *     AND status = 'requested'
 * LIMIT 1
 * ```
 */
export const getPendingUser = new PreparedQuery<IGetPendingUserParams,IGetPendingUserResult>(getPendingUserIR);


/** 'PersistChallenge' parameters type */
export interface IPersistChallengeParams {
  challengeEncrypted?: string | null | void;
  id?: number | null | void;
}

/** 'PersistChallenge' return type */
export type IPersistChallengeResult = void;

/** 'PersistChallenge' query type */
export interface IPersistChallengeQuery {
  params: IPersistChallengeParams;
  result: IPersistChallengeResult;
}

const persistChallengeIR: any = {"usedParamSet":{"challengeEncrypted":true,"id":true},"params":[{"name":"challengeEncrypted","required":false,"transform":{"type":"scalar"},"locs":[{"a":47,"b":65}]},{"name":"id","required":false,"transform":{"type":"scalar"},"locs":[{"a":105,"b":107}]}],"statement":"UPDATE\n    users\nSET\n    challenge_encrypted = :challengeEncrypted,\n    status = 'active'\nWHERE\n    id = :id"};

/**
 * Query generated from SQL:
 * ```
 * UPDATE
 *     users
 * SET
 *     challenge_encrypted = :challengeEncrypted,
 *     status = 'active'
 * WHERE
 *     id = :id
 * ```
 */
export const persistChallenge = new PreparedQuery<IPersistChallengeParams,IPersistChallengeResult>(persistChallengeIR);


/** 'GetUser' parameters type */
export interface IGetUserParams {
  username?: string | null | void;
}

/** 'GetUser' return type */
export interface IGetUserResult {
  challenge: string;
  challenge_encrypted: string | null;
  id: number;
  username: string;
}

/** 'GetUser' query type */
export interface IGetUserQuery {
  params: IGetUserParams;
  result: IGetUserResult;
}

const getUserIR: any = {"usedParamSet":{"username":true},"params":[{"name":"username","required":false,"transform":{"type":"scalar"},"locs":[{"a":107,"b":115}]}],"statement":"SELECT\n    id,\n    username,\n    challenge,\n    challenge_encrypted\nFROM\n    users\nWHERE\n    username LIKE :username\n    AND status = 'active'\nLIMIT 1"};

/**
 * Query generated from SQL:
 * ```
 * SELECT
 *     id,
 *     username,
 *     challenge,
 *     challenge_encrypted
 * FROM
 *     users
 * WHERE
 *     username LIKE :username
 *     AND status = 'active'
 * LIMIT 1
 * ```
 */
export const getUser = new PreparedQuery<IGetUserParams,IGetUserResult>(getUserIR);


