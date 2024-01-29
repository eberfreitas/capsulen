-- migrate:up
ALTER TABLE posts ADD COLUMN content_size int DEFAULT 0;

UPDATE posts SET content_size = length(content);

-- migrate:down
ALTER TABLE posts DROP COLUMN content_size;
