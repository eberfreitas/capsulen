/*
  @name createPost
  @param post -> (user_id, content, content_size)
*/
INSERT INTO
    posts (user_id, content, content_size)
VALUES
    :post
RETURNING *;

/* @name allPosts */
SELECT
    id,
    CASE WHEN content_size > :size_threshold
    THEN NULL
    ELSE content
    END content,
    created_at
FROM
    posts
WHERE
    user_id = :user_id
ORDER BY
    id DESC
LIMIT :limit;

/* @name allPostsFrom */
SELECT
    id,
    CASE WHEN content_size > :size_threshold
    THEN NULL
    ELSE content
    END content,
    created_at
FROM
    posts
WHERE
    user_id = :user_id
    AND id < :id
ORDER BY
    id DESC
LIMIT :limit;

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

/* @name getPost */
SELECT
    id,
    content,
    created_at
FROM
    posts
WHERE
    user_id = :user_id
    AND id = :id
LIMIT 1;


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
