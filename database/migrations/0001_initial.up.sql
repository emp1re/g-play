CREATE TABLE "user" (
    "id"            BIGSERIAL   PRIMARY KEY,
    "created_at"    timestamptz NOT NULL DEFAULT NOW(),
    "updated_at"    timestamptz NOT NULL DEFAULT NOW(),
    "deleted_at"    timestamptz NULL,
    "email"         text        NOT NULL,
    "password"      text        NOT NULL,
    "first_name"    text        NOT NULL,
    "last_name"     text        NOT NULL
);
CREATE UNIQUE INDEX "udx_user_email" ON "user" ("email") WHERE "deleted_at" IS NULL;

CREATE TABLE "project" (
    "id"            BIGSERIAL   PRIMARY KEY,
    "created_at"    timestamptz NOT NULL DEFAULT NOW(),
    "updated_at"    timestamptz NOT NULL DEFAULT NOW(),
    "deleted_at"    timestamptz NULL,
    "name"          text        NOT NULL,
    "description"   text        NOT NULL
);

CREATE TABLE "project_user" (
    "id"            BIGSERIAL   PRIMARY KEY,
    "created_at"    timestamptz NOT NULL DEFAULT NOW(),
    "updated_at"    timestamptz NOT NULL DEFAULT NOW(),
    "deleted_at"    timestamptz NULL,
    "project_id"    int8        NOT NULL REFERENCES "project"("id"),
    "user_id"       int8        NOT NULL REFERENCES "user"("id")
);

CREATE TABLE "api_keys" (
    "id"            BIGSERIAL   PRIMARY KEY,
    "created_at"    timestamptz NOT NULL DEFAULT NOW(),
    "updated_at"    timestamptz NOT NULL DEFAULT NOW(),
    "deleted_at"    timestamptz NULL,
    "expires_at"    timestamptz NULL,
    "project_id"    int8        NOT NULL REFERENCES "project"("id"),
    "user_id"       int8        NOT NULL REFERENCES "user"("id"),
    "value"         text        NOT NULL
);
CREATE INDEX "idx_api_keys_value" ON "api_keys" ("value") WHERE "deleted_at" IS NULL;

CREATE TYPE key_type AS ENUM ('string', 'plural');

CREATE TABLE "key" (
    "id"            BIGSERIAL   PRIMARY KEY,
    "created_at"    timestamptz NOT NULL DEFAULT NOW(),
    "updated_at"    timestamptz NOT NULL DEFAULT NOW(),
    "deleted_at"    timestamptz NULL,
    "project_id"    int8        NOT NULL REFERENCES "project"("id"),
    "name"          text        NOT NULL,
    "key_type"      key_type     NOT NULL
);
CREATE UNIQUE INDEX "udx_key_project_id_name" ON "key" ("project_id", "name") WHERE "deleted_at" IS NULL;

CREATE TABLE "locale" (
    "id"            BIGSERIAL   PRIMARY KEY,
    "created_at"    timestamptz NOT NULL DEFAULT NOW(),
    "updated_at"    timestamptz NOT NULL DEFAULT NOW(),
    "deleted_at"    timestamptz NULL,
    "project_id"    int8        NOT NULL REFERENCES "project"("id"),
    "name"          text        NOT NULL,
    "lang"          char(2)     NOT NULL,
    "country"       char(2)     NOT NULL,
    "code"          char(5)     NOT NULL
);
CREATE UNIQUE INDEX "udx_locale_project_id_name_lang_country_code" ON "locale" ("project_id", "name", "lang", "country") WHERE "deleted_at" IS NULL;

CREATE TYPE value_status AS ENUM ('draft', 'error', 'complete');

CREATE TABLE "value" (
    "id"            BIGSERIAL   PRIMARY KEY,
    "created_at"    timestamptz NOT NULL DEFAULT NOW(),
    "updated_at"    timestamptz NOT NULL DEFAULT NOW(),
    "deleted_at"    timestamptz NULL,
    "project_id"    int8        NOT NULL REFERENCES "project"("id"),
    "key_id"        int8        NOT NULL REFERENCES "key"("id"),
    "locale_id"     int8        NOT NULL REFERENCES "locale"("id"),
    "locale_code"   char(5)     NOT NULL,
    "value"         jsonb        NOT NULL,
    "has_comments"  bool        NOT NULL DEFAULT FALSE,
    "status"        value_status NOT NULL DEFAULT 'draft'
);
CREATE  INDEX "idx_value_key_id" ON "value" ("key_id") WHERE "deleted_at" IS NULL;

CREATE TABLE "comment" (
    "id"            BIGSERIAL   PRIMARY KEY,
    "created_at"    timestamptz NOT NULL DEFAULT NOW(),
    "updated_at"    timestamptz NOT NULL DEFAULT NOW(),
    "deleted_at"    timestamptz NULL,
    "key_id"        int8        NOT NULL REFERENCES "key"("id"),
    "value_id"      int8        NULL REFERENCES "value"("id"),
    "user_id"       int8        NOT NULL REFERENCES "user"("id"),
    "message"       text        NOT NULL
);

CREATE TABLE "value_version" (
    "id"            BIGSERIAL   PRIMARY KEY,
    "created_at"    timestamptz DEFAULT NOW(),
    "updated_at"    timestamptz DEFAULT NOW(),
    "deleted_at"    timestamptz NULL,
    "value_id"      int8        NOT NULL REFERENCES "value"("id"),
    "creator_id"    int8        NOT NULL REFERENCES "user"("id"),
    "value"         jsonb        NOT NULL
);

CREATE TABLE "upload" (
    "id"            BIGSERIAL   PRIMARY KEY,
    "created_at"    timestamptz NOT NULL DEFAULT NOW(),
    "updated_at"    timestamptz NOT NULL DEFAULT NOW(),
    "deleted_at"    timestamptz NULL,
    "content_type"  text        NOT NULL,
    "filename"      text        NOT NULL,
    "project_id"    int8        NOT NULL REFERENCES "project"("id"),
    "user_id"       int8        NOT NULL REFERENCES "user"("id"),
    "URL"           text        NOT NULL,
    "slug"          text        NOT NULL,
    "provider"      text        NOT NULL
);

CREATE TABLE "backup"(
    "id"            BIGSERIAL   PRIMARY KEY,
    "created_at"    timestamptz NOT NULL DEFAULT NOW(),
    "updated_at"    timestamptz NOT NULL DEFAULT NOW(),
    "deleted_at"    timestamptz NULL,
    "content_type"  text        NOT NULL,
    "filename"      text        NOT NULL,
    "project_id"    int8        NOT NULL REFERENCES "project"("id"),
    "user_id"       int8        NOT NULL REFERENCES "user"("id"),
    "URL"           text        NOT NULL,
    "slug"          text        NOT NULL,
    "provider"      text        NOT NULL
);

CREATE TABLE "media"(
     "id"            BIGSERIAL   PRIMARY KEY,
     "created_at"    timestamptz NOT NULL DEFAULT NOW(),
     "updated_at"    timestamptz NOT NULL DEFAULT NOW(),
     "deleted_at"    timestamptz NULL,
     "content_type"  text        NOT NULL,
     "filename"      text        NOT NULL,
     "project_id"    int8        NOT NULL REFERENCES "project"("id"),
     "user_id"       int8        NOT NULL REFERENCES "user"("id"),
     "URL"           text        NOT NULL,
     "original_name" text        NOT NULL,
     "slug"          text        NOT NULL,
     "title"         text        NOT NULL DEFAULT '',
     "description"   text        NOT NULL DEFAULT '',
     "key_IDs"       int8[]      NULL DEFAULT '{}',
     "provider"      text        NOT NULL
);
CREATE INDEX "idx_media_project_id" ON "media" ("project_id");





