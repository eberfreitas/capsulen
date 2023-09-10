/* @name existingUser */
SELECT 1 AS exists FROM users WHERE username ILIKE :username LIMIT 1;

/*
  @name createUserRequest
  @param user -> (username, nonce, challenge)
*/
INSERT INTO users (username, nonce, challenge) VALUES :user;
