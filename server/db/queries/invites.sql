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
