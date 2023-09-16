-- migrate:up
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id int NOT NULL,
    content text NOT NULL,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- migrate:down
DROP TABLE posts;
