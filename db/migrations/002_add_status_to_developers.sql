-- +migrate up
CREATE TYPE developers_status AS ENUM ('pending', 'approved', 'declined');
ALTER TABLE developers ADD status developers_status NOT NULL DEFAULT 'pending';
CREATE INDEX developers_status_index  ON developers(status);

-- +migrate down
ALTER TABLE developers DROP COLUMN status;
DROP TYPE developers_status;
