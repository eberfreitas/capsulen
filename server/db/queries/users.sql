/* @name existingUser */
SELECT
    1 AS exists
FROM
    users
WHERE
    username ILIKE :username
LIMIT 1;

/*
  @name createUserRequest
  @param user -> (username, nonce, challenge)
*/
INSERT INTO
    users (username, nonce, challenge)
VALUES
    :user;

/* @name getPendingUser */
SELECT
    id
FROM
    users
WHERE
    username LIKE :username
    AND nonce LIKE :nonce
    AND status = 'requested'
LIMIT 1;

/* @name persistChallenge */
UPDATE
    users
SET
    challenge_encrypted = :challengeEncrypted,
    status = 'active'
WHERE
    id = :id;

/* @name getUser */
SELECT
    id,
    username,
    challenge,
    challenge_encrypted
FROM
    users
WHERE
    username LIKE :username
    AND status = 'active'
LIMIT 1;
