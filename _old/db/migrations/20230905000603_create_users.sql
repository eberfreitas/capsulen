-- migrate:up
CREATE TYPE user_status AS ENUM ('requested', 'active');

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username varchar(255) NOT NULL UNIQUE,
    nonce varchar(255) NOT NULL,
    challenge varchar(255) NOT NULL,
    challenge_encrypted varchar(512) NULL,
    status user_status DEFAULT 'requested',
    created_at timestamp DEFAULT CURRENT_TIMESTAMP
);

-- migrate:down
DROP TABLE users;

DROP TYPE user_status;
