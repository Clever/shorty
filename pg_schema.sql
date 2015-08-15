CREATE USER shortener WITH PASSWORD 'not-very-secret';

CREATE SCHEMA IF NOT EXISTS shortener AUTHORIZATION shortener;

CREATE TABLE IF NOT EXISTS "shortener"."shortener" (
  slug VARCHAR(255) PRIMARY KEY,
  long_url VARCHAR(4000) NOT NULL,
  owner VARCHAR(255) NOT NULL,
  expires  timestamp without time zone,
  modified  timestamp without time zone
);

GRANT USAGE ON SCHEMA shortener TO shortener;
GRANT UPDATE, INSERT, SELECT, REFERENCES ON shortener.shortener TO shortener;
