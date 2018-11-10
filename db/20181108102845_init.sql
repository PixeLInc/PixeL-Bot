-- +micrate Up
CREATE EXTENSION pgcrypto;

CREATE TABLE users(
  id SERIAL PRIMARY KEY,
  discord_id NUMERIC(20, 0) UNIQUE,
  access_token TEXT,
  mcuser TEXT,
  verification_code TEXT
);

-- +micrate Down
DROP TABLE users;
DROP EXTENSION pgcrypto;
