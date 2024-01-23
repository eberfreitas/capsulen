/** Types generated for queries found in "db/queries/invites.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type invite_status = 'pending' | 'used';

/** 'MasterInvite' parameters type */
export interface IMasterInviteParams {
  code?: string | null | void;
}

/** 'MasterInvite' return type */
export interface IMasterInviteResult {
  code: string;
  created_at: Date | null;
  id: number;
  status: invite_status | null;
  updated_at: Date | null;
  user_id: number | null;
}

/** 'MasterInvite' query type */
export interface IMasterInviteQuery {
  params: IMasterInviteParams;
  result: IMasterInviteResult;
}

const masterInviteIR: any = {"usedParamSet":{"code":true},"params":[{"name":"code","required":false,"transform":{"type":"scalar"},"locs":[{"a":43,"b":47}]}],"statement":"INSERT INTO\n    invites (code)\nVALUES\n    (:code)\nRETURNING *"};

/**
 * Query generated from SQL:
 * ```
 * INSERT INTO
 *     invites (code)
 * VALUES
 *     (:code)
 * RETURNING *
 * ```
 */
export const masterInvite = new PreparedQuery<IMasterInviteParams,IMasterInviteResult>(masterInviteIR);


/** 'ValidInvite' parameters type */
export interface IValidInviteParams {
  code?: string | null | void;
}

/** 'ValidInvite' return type */
export interface IValidInviteResult {
  id: number;
}

/** 'ValidInvite' query type */
export interface IValidInviteQuery {
  params: IValidInviteParams;
  result: IValidInviteResult;
}

const validInviteIR: any = {"usedParamSet":{"code":true},"params":[{"name":"code","required":false,"transform":{"type":"scalar"},"locs":[{"a":48,"b":52}]}],"statement":"SELECT\n    id\nFROM\n    invites\nWHERE\n    code = :code\nAND\n    status = 'pending'\nLIMIT 1"};

/**
 * Query generated from SQL:
 * ```
 * SELECT
 *     id
 * FROM
 *     invites
 * WHERE
 *     code = :code
 * AND
 *     status = 'pending'
 * LIMIT 1
 * ```
 */
export const validInvite = new PreparedQuery<IValidInviteParams,IValidInviteResult>(validInviteIR);


/** 'UseInvite' parameters type */
export interface IUseInviteParams {
  id?: number | null | void;
}

/** 'UseInvite' return type */
export type IUseInviteResult = void;

/** 'UseInvite' query type */
export interface IUseInviteQuery {
  params: IUseInviteParams;
  result: IUseInviteResult;
}

const useInviteIR: any = {"usedParamSet":{"id":true},"params":[{"name":"id","required":false,"transform":{"type":"scalar"},"locs":[{"a":82,"b":84}]}],"statement":"UPDATE\n    invites\nSET\n    status = 'used',\n    updated_at = NOW()\nWHERE\n    id = :id"};

/**
 * Query generated from SQL:
 * ```
 * UPDATE
 *     invites
 * SET
 *     status = 'used',
 *     updated_at = NOW()
 * WHERE
 *     id = :id
 * ```
 */
export const useInvite = new PreparedQuery<IUseInviteParams,IUseInviteResult>(useInviteIR);


/** 'UserInvite' parameters type */
export interface IUserInviteParams {
  code?: string | null | void;
  user_id?: number | null | void;
}

/** 'UserInvite' return type */
export interface IUserInviteResult {
  code: string;
  created_at: Date | null;
  id: number;
  status: invite_status | null;
  updated_at: Date | null;
  user_id: number | null;
}

/** 'UserInvite' query type */
export interface IUserInviteQuery {
  params: IUserInviteParams;
  result: IUserInviteResult;
}

const userInviteIR: any = {"usedParamSet":{"user_id":true,"code":true},"params":[{"name":"user_id","required":false,"transform":{"type":"scalar"},"locs":[{"a":52,"b":59}]},{"name":"code","required":false,"transform":{"type":"scalar"},"locs":[{"a":62,"b":66}]}],"statement":"INSERT INTO\n    invites (user_id, code)\nVALUES\n    (:user_id, :code)\nRETURNING *"};

/**
 * Query generated from SQL:
 * ```
 * INSERT INTO
 *     invites (user_id, code)
 * VALUES
 *     (:user_id, :code)
 * RETURNING *
 * ```
 */
export const userInvite = new PreparedQuery<IUserInviteParams,IUserInviteResult>(userInviteIR);


/** 'FetchInvites' parameters type */
export interface IFetchInvitesParams {
  user_id?: number | null | void;
}

/** 'FetchInvites' return type */
export interface IFetchInvitesResult {
  code: string;
  status: invite_status | null;
}

/** 'FetchInvites' query type */
export interface IFetchInvitesQuery {
  params: IFetchInvitesParams;
  result: IFetchInvitesResult;
}

const fetchInvitesIR: any = {"usedParamSet":{"user_id":true},"params":[{"name":"user_id","required":false,"transform":{"type":"scalar"},"locs":[{"a":61,"b":68}]}],"statement":"SELECT\n    code, status\nFROM\n    invites\nWHERE\n    user_id = :user_id\nORDER BY id DESC\nLIMIT 50"};

/**
 * Query generated from SQL:
 * ```
 * SELECT
 *     code, status
 * FROM
 *     invites
 * WHERE
 *     user_id = :user_id
 * ORDER BY id DESC
 * LIMIT 50
 * ```
 */
export const fetchInvites = new PreparedQuery<IFetchInvitesParams,IFetchInvitesResult>(fetchInvitesIR);


/** 'CountInvites' parameters type */
export interface ICountInvitesParams {
  user_id?: number | null | void;
}

/** 'CountInvites' return type */
export interface ICountInvitesResult {
  count: string | null;
}

/** 'CountInvites' query type */
export interface ICountInvitesQuery {
  params: ICountInvitesParams;
  result: ICountInvitesResult;
}

const countInvitesIR: any = {"usedParamSet":{"user_id":true},"params":[{"name":"user_id","required":false,"transform":{"type":"scalar"},"locs":[{"a":66,"b":73}]}],"statement":"SELECT\n    COUNT(*) AS count\nFROM\n    invites\nWHERE\n    user_id = :user_id\nAND\n    status = 'pending'"};

/**
 * Query generated from SQL:
 * ```
 * SELECT
 *     COUNT(*) AS count
 * FROM
 *     invites
 * WHERE
 *     user_id = :user_id
 * AND
 *     status = 'pending'
 * ```
 */
export const countInvites = new PreparedQuery<ICountInvitesParams,ICountInvitesResult>(countInvitesIR);


