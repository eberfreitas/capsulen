/* @name existingUser */
SELECT 1 AS exists FROM users WHERE username ILIKE :username;