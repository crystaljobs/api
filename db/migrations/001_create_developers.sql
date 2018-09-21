-- +migrate up
CREATE TABLE developers (
  id  SERIAL  PRIMARY KEY,

  -- Fields
  about     TEXT,
  website   TEXT,
  country   CHAR(2),
  display   BOOL    NOT NULL  DEFAULT false,

  github_id           INT   NOT NULL,
  github_username     TEXT  NOT NULL,
  github_access_token TEXT  NOT NULL,

  -- Timestamps
  created_at  TIMESTAMPTZ NOT NULL  DEFAULT NOW()
);

-- Indexes
CREATE UNIQUE INDEX developers_github_username_index  ON developers(github_username);

-- +migrate down
DROP TABLE developers;
