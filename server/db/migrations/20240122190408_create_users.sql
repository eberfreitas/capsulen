-- migrate:up
CREATE TYPE user_status AS ENUM ('requested', 'active');

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    invite_id int NOT NULL,
    username varchar(255) NOT NULL UNIQUE,
    nonce varchar(255) NOT NULL,
    challenge varchar(255) NOT NULL,
    challenge_encrypted varchar(512) NULL,
    status user_status DEFAULT 'requested',
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (invite_id) REFERENCES invites(id)
);

-- migrate:down
DROP TABLE users;

DROP TYPE user_status;
