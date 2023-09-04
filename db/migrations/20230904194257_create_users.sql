-- migrate:up
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username varchar(255) NOT NULL UNIQUE,
    challenge varchar(255) NOT NULL,
    challenge_encrypted varchar(255) NOT NULL,
    created_at timestamp NOT NULL
);

-- migrate:down
DROP TABLE users;
