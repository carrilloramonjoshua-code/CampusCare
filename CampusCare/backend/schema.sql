-- Campus Care database schema (SQLite)
-- AUTO-GENERATED on 2026-10-26 00:25 by `python manage.py migrate`.
-- Do not edit by hand: it is rewritten every time the database changes.
-- You do NOT need to run this file; Django builds the tables for you.
-- It is for documentation, or to open in DB Browser for SQLite.


CREATE TABLE "reports_user" (
    "id" integer NOT NULL PRIMARY KEY AUTOINCREMENT,
    "password" varchar(128) NOT NULL,
    "last_login" datetime NULL,
    "is_superuser" bool NOT NULL,
    "username" varchar(150) NOT NULL UNIQUE,
    "first_name" varchar(150) NOT NULL,
    "last_name" varchar(150) NOT NULL,
    "email" varchar(254) NOT NULL,
    "is_staff" bool NOT NULL,
    "is_active" bool NOT NULL,
    "date_joined" datetime NOT NULL,
    "role" varchar(10) NOT NULL,
    "student_id" varchar(20) NOT NULL
);

CREATE TABLE "reports_report" (
    "id" integer NOT NULL PRIMARY KEY AUTOINCREMENT,
    "title" varchar(120) NOT NULL,
    "description" text NOT NULL,
    "category" varchar(20) NOT NULL,
    "location" varchar(120) NOT NULL,
    "status" varchar(15) NOT NULL,
    "admin_note" text NOT NULL,
    "created_at" datetime NOT NULL,
    "updated_at" datetime NOT NULL,
    "reporter_id" bigint NOT NULL REFERENCES "reports_user" ("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX "reports_report_reporter_id_d54be306" ON "reports_report" ("reporter_id");

CREATE TABLE "authtoken_token" (
    "key" varchar(40) NOT NULL PRIMARY KEY,
    "created" datetime NOT NULL,
    "user_id" bigint NOT NULL UNIQUE REFERENCES "reports_user" ("id") DEFERRABLE INITIALLY DEFERRED
);
