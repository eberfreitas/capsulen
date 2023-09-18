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
