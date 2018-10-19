-- +migrate up
CREATE TYPE job_approval_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TABLE jobs (
  id  SERIAL  PRIMARY KEY,

  status    job_approval_status NOT NULL  DEFAULT 'pending',
  activated BOOLEAN             NOT NULL  DEFAULT false,
  published BOOLEAN             NOT NULL  DEFAULT true,

  approval_email_sent BOOLEAN NOT NULL  DEFAULT false,

  one_off BOOLEAN NOT NULL,
  budget  INT,

  title       TEXT,
  location    TEXT,
  description TEXT    NOT NULL,
  salary      INT,

  apply_url   TEXT,
  apply_email TEXT,

  employer_name   TEXT  NOT NULL,
  employer_email  TEXT  NOT NULL,
  employer_image  TEXT,

  created_at  TIMESTAMPTZ NOT NULL  DEFAULT now(),
  updated_at  TIMESTAMPTZ,
  expired_at  TIMESTAMPTZ NOT NULL
);

CREATE INDEX jobs_status_index      ON jobs(status, published, activated);
CREATE INDEX jobs_type_index        ON jobs(one_off);
CREATE INDEX jobs_created_at_index  ON jobs(created_at);

-- +migrate down
DROP TABLE jobs;
DROP TYPE job_approval_status;
