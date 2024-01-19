/*
  @name createPost
  @param post -> (user_id, content)
*/
INSERT INTO
    posts (user_id, content)
VALUES
    :post
RETURNING *;

/* @name getPost */
SELECT
    id,
    content,
    created_at
FROM
    posts
WHERE
    id = :id;

/* @name getInitialPosts */
SELECT
    id,
    content,
    created_at
FROM
    posts
WHERE
    user_id = :user_id
ORDER BY
    id DESC
LIMIT :limit;

/* @name getPosts */
SELECT
    id,
    content,
    created_at
FROM
    posts
WHERE
    user_id = :user_id
    AND id < :id
ORDER BY
    id DESC
LIMIT :limit;

/* @name deletePost */
DELETE FROM
    posts
WHERE
    user_id = :user_id
    AND id = :id;
