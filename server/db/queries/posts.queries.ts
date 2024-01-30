/** Types generated for queries found in "db/queries/posts.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'CreatePost' parameters type */
export interface ICreatePostParams {
  post: {
    user_id: number | null | void,
    content: string | null | void,
    content_size: number | null | void
  };
}

/** 'CreatePost' return type */
export interface ICreatePostResult {
  content: string;
  content_size: number | null;
  created_at: Date | null;
  id: number;
  user_id: number;
}

/** 'CreatePost' query type */
export interface ICreatePostQuery {
  params: ICreatePostParams;
  result: ICreatePostResult;
}

const createPostIR: any = {"usedParamSet":{"post":true},"params":[{"name":"post","required":false,"transform":{"type":"pick_tuple","keys":[{"name":"user_id","required":false},{"name":"content","required":false},{"name":"content_size","required":false}]},"locs":[{"a":66,"b":70}]}],"statement":"INSERT INTO\n    posts (user_id, content, content_size)\nVALUES\n    :post\nRETURNING *"};

/**
 * Query generated from SQL:
 * ```
 * INSERT INTO
 *     posts (user_id, content, content_size)
 * VALUES
 *     :post
 * RETURNING *
 * ```
 */
export const createPost = new PreparedQuery<ICreatePostParams,ICreatePostResult>(createPostIR);


/** 'AllPosts' parameters type */
export interface IAllPostsParams {
  limit?: number | string | null | void;
  size_threshold?: number | null | void;
  user_id?: number | null | void;
}

/** 'AllPosts' return type */
export interface IAllPostsResult {
  content: string | null;
  created_at: Date | null;
  id: number;
}

/** 'AllPosts' query type */
export interface IAllPostsQuery {
  params: IAllPostsParams;
  result: IAllPostsResult;
}

const allPostsIR: any = {"usedParamSet":{"size_threshold":true,"user_id":true,"limit":true},"params":[{"name":"size_threshold","required":false,"transform":{"type":"scalar"},"locs":[{"a":44,"b":58}]},{"name":"user_id","required":false,"transform":{"type":"scalar"},"locs":[{"a":158,"b":165}]},{"name":"limit","required":false,"transform":{"type":"scalar"},"locs":[{"a":194,"b":199}]}],"statement":"SELECT\n    id,\n    CASE WHEN content_size > :size_threshold\n    THEN NULL\n    ELSE content\n    END content,\n    created_at\nFROM\n    posts\nWHERE\n    user_id = :user_id\nORDER BY\n    id DESC\nLIMIT :limit"};

/**
 * Query generated from SQL:
 * ```
 * SELECT
 *     id,
 *     CASE WHEN content_size > :size_threshold
 *     THEN NULL
 *     ELSE content
 *     END content,
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
export const allPosts = new PreparedQuery<IAllPostsParams,IAllPostsResult>(allPostsIR);


/** 'AllPostsFrom' parameters type */
export interface IAllPostsFromParams {
  id?: number | null | void;
  limit?: number | string | null | void;
  size_threshold?: number | null | void;
  user_id?: number | null | void;
}

/** 'AllPostsFrom' return type */
export interface IAllPostsFromResult {
  content: string | null;
  created_at: Date | null;
  id: number;
}

/** 'AllPostsFrom' query type */
export interface IAllPostsFromQuery {
  params: IAllPostsFromParams;
  result: IAllPostsFromResult;
}

const allPostsFromIR: any = {"usedParamSet":{"size_threshold":true,"user_id":true,"id":true,"limit":true},"params":[{"name":"size_threshold","required":false,"transform":{"type":"scalar"},"locs":[{"a":44,"b":58}]},{"name":"user_id","required":false,"transform":{"type":"scalar"},"locs":[{"a":158,"b":165}]},{"name":"id","required":false,"transform":{"type":"scalar"},"locs":[{"a":180,"b":182}]},{"name":"limit","required":false,"transform":{"type":"scalar"},"locs":[{"a":211,"b":216}]}],"statement":"SELECT\n    id,\n    CASE WHEN content_size > :size_threshold\n    THEN NULL\n    ELSE content\n    END content,\n    created_at\nFROM\n    posts\nWHERE\n    user_id = :user_id\n    AND id < :id\nORDER BY\n    id DESC\nLIMIT :limit"};

/**
 * Query generated from SQL:
 * ```
 * SELECT
 *     id,
 *     CASE WHEN content_size > :size_threshold
 *     THEN NULL
 *     ELSE content
 *     END content,
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
export const allPostsFrom = new PreparedQuery<IAllPostsFromParams,IAllPostsFromResult>(allPostsFromIR);


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


/** 'GetPost' parameters type */
export interface IGetPostParams {
  id?: number | null | void;
  user_id?: number | null | void;
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

const getPostIR: any = {"usedParamSet":{"user_id":true,"id":true},"params":[{"name":"user_id","required":false,"transform":{"type":"scalar"},"locs":[{"a":78,"b":85}]},{"name":"id","required":false,"transform":{"type":"scalar"},"locs":[{"a":100,"b":102}]}],"statement":"SELECT\n    id,\n    content,\n    created_at\nFROM\n    posts\nWHERE\n    user_id = :user_id\n    AND id = :id\nLIMIT 1"};

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
 *     AND id = :id
 * LIMIT 1
 * ```
 */
export const getPost = new PreparedQuery<IGetPostParams,IGetPostResult>(getPostIR);


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


