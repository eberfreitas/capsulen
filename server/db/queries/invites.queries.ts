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


