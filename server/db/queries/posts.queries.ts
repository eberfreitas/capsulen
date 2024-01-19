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


/** 'GetInitialPosts' parameters type */
export interface IGetInitialPostsParams {
  limit?: number | string | null | void;
  user_id?: number | null | void;
}

/** 'GetInitialPosts' return type */
export interface IGetInitialPostsResult {
  content: string;
  created_at: Date | null;
  id: number;
}

/** 'GetInitialPosts' query type */
export interface IGetInitialPostsQuery {
  params: IGetInitialPostsParams;
  result: IGetInitialPostsResult;
}

const getInitialPostsIR: any = {"usedParamSet":{"user_id":true,"limit":true},"params":[{"name":"user_id","required":false,"transform":{"type":"scalar"},"locs":[{"a":78,"b":85}]},{"name":"limit","required":false,"transform":{"type":"scalar"},"locs":[{"a":114,"b":119}]}],"statement":"SELECT\n    id,\n    content,\n    created_at\nFROM\n    posts\nWHERE\n    user_id = :user_id\nORDER BY\n    id DESC\nLIMIT :limit"};

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
 *     user_id = :user_id
 * ORDER BY
 *     id DESC
 * LIMIT :limit
 * ```
 */
export const getInitialPosts = new PreparedQuery<IGetInitialPostsParams,IGetInitialPostsResult>(getInitialPostsIR);


/** 'GetPosts' parameters type */
export interface IGetPostsParams {
  id?: number | null | void;
  limit?: number | string | null | void;
  user_id?: number | null | void;
}

/** 'GetPosts' return type */
export interface IGetPostsResult {
  content: string;
  created_at: Date | null;
  id: number;
}

/** 'GetPosts' query type */
export interface IGetPostsQuery {
  params: IGetPostsParams;
  result: IGetPostsResult;
}

const getPostsIR: any = {"usedParamSet":{"user_id":true,"id":true,"limit":true},"params":[{"name":"user_id","required":false,"transform":{"type":"scalar"},"locs":[{"a":78,"b":85}]},{"name":"id","required":false,"transform":{"type":"scalar"},"locs":[{"a":100,"b":102}]},{"name":"limit","required":false,"transform":{"type":"scalar"},"locs":[{"a":131,"b":136}]}],"statement":"SELECT\n    id,\n    content,\n    created_at\nFROM\n    posts\nWHERE\n    user_id = :user_id\n    AND id < :id\nORDER BY\n    id DESC\nLIMIT :limit"};

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
 *     user_id = :user_id
 *     AND id < :id
 * ORDER BY
 *     id DESC
 * LIMIT :limit
 * ```
 */
export const getPosts = new PreparedQuery<IGetPostsParams,IGetPostsResult>(getPostsIR);


/** 'DeletePost' parameters type */
export interface IDeletePostParams {
  id?: number | null | void;
  user_id?: number | null | void;
}

/** 'DeletePost' return type */
export type IDeletePostResult = void;

/** 'DeletePost' query type */
export interface IDeletePostQuery {
  params: IDeletePostParams;
  result: IDeletePostResult;
}

const deletePostIR: any = {"usedParamSet":{"user_id":true,"id":true},"params":[{"name":"user_id","required":false,"transform":{"type":"scalar"},"locs":[{"a":42,"b":49}]},{"name":"id","required":false,"transform":{"type":"scalar"},"locs":[{"a":64,"b":66}]}],"statement":"DELETE FROM\n    posts\nWHERE\n    user_id = :user_id\n    AND id = :id"};

/**
 * Query generated from SQL:
 * ```
 * DELETE FROM
 *     posts
 * WHERE
 *     user_id = :user_id
 *     AND id = :id
 * ```
 */
export const deletePost = new PreparedQuery<IDeletePostParams,IDeletePostResult>(deletePostIR);


