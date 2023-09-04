-- migrate:up
CREATE TABLE registration_requests (
    id SERIAL PRIMARY KEY,
    username varchar(255) NOT NULL,
    nonce varchar(255) NOT NULL,
    challenge varchar(255) NOT NULL,
    active boolean DEFAULT TRUE,
    created_at timestamp NOT NULL
);

CREATE INDEX registration_requests_username ON registration_requests (username);

-- migrate:down
DROP TABLE registration_requests;
