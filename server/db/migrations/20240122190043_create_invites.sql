-- migrate:up
CREATE TYPE invite_status AS ENUM ('pending', 'used');

CREATE TABLE invites (
    id SERIAL PRIMARY KEY,
    code varchar(8) NOT NULL UNIQUE,
    user_id int NULL,
    status invite_status DEFAULT 'pending',
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamptz DEFAULT CURRENT_TIMESTAMP
);

-- migrate:down
DROP TABLE invites;

DROP TYPE invite_status;
