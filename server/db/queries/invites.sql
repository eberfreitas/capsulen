/* @name masterInvite */
INSERT INTO
    invites (code)
VALUES
    (:code)
RETURNING *;

/* @name validInvite */
SELECT
    id
FROM
    invites
WHERE
    code = :code
AND
    status = 'pending'
LIMIT 1;

/* @name useInvite */
UPDATE
    invites
SET
    status = 'used',
    updated_at = NOW()
WHERE
    id = :id;

/* @name userInvite */
INSERT INTO
    invites (user_id, code)
VALUES
    (:user_id, :code)
RETURNING *;

/* @name fetchInvites */
SELECT
    code, status
FROM
    invites
WHERE
    user_id = :user_id
ORDER BY id DESC
LIMIT 50;

/* @name countInvites */
SELECT
    COUNT(*) AS count
FROM
    invites
WHERE
    user_id = :user_id
AND
    status = 'pending';
