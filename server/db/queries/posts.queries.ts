/** Types generated for queries found in "db/queries/posts.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'CreatePost' parameters type */
export interface ICreatePostParams {
  post: {
    user_id: number | null | void,
    content: string | null | void
  };
}

/** 'CreatePost' return type */
export interface ICreatePostResult {
  content: string;
  created_at: Date | null;
  id: number;
  user_id: number;
}

/** 'CreatePost' query type */
export interface ICreatePostQuery {
  params: ICreatePostParams;
  result: ICreatePostResult;
}

const createPostIR: any = {"usedParamSet":{"post":true},"params":[{"name":"post","required":false,"transform":{"type":"pick_tuple","keys":[{"name":"user_id","required":false},{"name":"content","required":false}]},"locs":[{"a":52,"b":56}]}],"statement":"INSERT INTO\n    posts (user_id, content)\nVALUES\n    :post\nRETURNING *"};

/**
 * Query generated from SQL:
 * ```
 * INSERT INTO
 *     posts (user_id, content)
 * VALUES
 *     :post
 * RETURNING *
 * ```
 */
export const createPost = new PreparedQuery<ICreatePostParams,ICreatePostResult>(createPostIR);


/** 'GetPost' parameters type */
export interface IGetPostParams {
  id?: number | null | void;
}

/** 'GetPost' return type */
export interface IGetPostResult {
  content: string;
  created_at: Date | null;
  id: number;
}

/** 'GetPost' query type */
export interface IGetPostQuery {
  params: IGetPostParams;
  result: IGetPostResult;
}

const getPostIR: any = {"usedParamSet":{"id":true},"params":[{"name":"id","required":false,"transform":{"type":"scalar"},"locs":[{"a":73,"b":75}]}],"statement":"SELECT\n    id,\n    content,\n    created_at\nFROM\n    posts\nWHERE\n    id = :id"};

/**
 * Query generated from SQL:
 * ```
 * SELECT
 *     id,
 *     content,
 *     created_at
 * FROM
 *     posts
 * WHERE
 *     id = :id
 * ```
 */
export const getPost = new PreparedQuery<IGetPostParams,IGetPostResult>(getPostIR);


