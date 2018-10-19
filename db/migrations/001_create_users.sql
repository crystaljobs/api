-- +migrate up
CREATE TABLE users (
  id  SERIAL  PRIMARY KEY,

  email               TEXT    NOT NULL,
  encrypted_password  TEXT    NOT NULL,
  moderator           BOOLEAN NOT NULL  DEFAULT false,

  created_at  TIMESTAMPTZ NOT NULL  DEFAULT now(),
  updated_at  TIMESTAMPTZ
);

CREATE UNIQUE INDEX users_email_index ON users(email);

-- +migrate down
DROP TABLE users;
