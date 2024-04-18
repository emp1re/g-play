-- name: CreateUser :one
INSERT INTO "user" ("email", "password", "first_name", "last_name") VALUES ($1, $2, $3, $4) RETURNING *;

-- name: CreateUsers :copyfrom
INSERT INTO "user" ("email", "password", "first_name", "last_name") VALUES ($1, $2, $3, $4);

-- name: CreateProject :one
INSERT INTO "project" ("name", "description") VALUES ($1, $2) RETURNING *;

-- name: CreateProjects :copyfrom
INSERT INTO "project" ("name", "description") VALUES ($1, $2);

-- name: CreateProjectUser :one
INSERT INTO "project_user" ("project_id", "user_id") VALUES ($1, $2) RETURNING *;

-- name: CreateProjectUsers :copyfrom
INSERT INTO "project_user" ("project_id", "user_id") VALUES ($1, $2);

-- name: CreateApiKey :one
INSERT INTO "api_keys" ("project_id", "user_id", "value") VALUES ($1, $2, $3)  RETURNING *;

-- name: CreateApiKeys :copyfrom
INSERT INTO "api_keys" ("project_id", "user_id", "value") VALUES ($1, $2, $3);

-- name: CreateKey :one
INSERT INTO "key" ("project_id" , "name", "key_type") VALUES ($1, $2, $3) RETURNING *;

-- name: CreateKeys :copyfrom
INSERT INTO "key" ("project_id", "name", "key_type") VALUES ($1, $2, $3);

-- name: CreateLocale :one
INSERT INTO "locale" ("project_id" , "name", "lang", "country", "code") VALUES ($1, $2, $3, $4, $5) RETURNING *;

-- name: CreateLocales :copyfrom
INSERT INTO "locale" ("project_id", "name", "lang", "country", "code") VALUES ($1, $2, $3, $4, $5);

-- name: CreateValue :one
INSERT INTO "value" ("project_id", "key_id", "locale_id", "locale_code", "value", "status", "has_comments") VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *;


-- name: CreateValues :copyfrom
INSERT INTO "value" ("project_id", "key_id", "locale_id", "locale_code", "value", "status", "has_comments") VALUES ($1, $2, $3, $4, $5, $6, $7);

-- name: CreateComment :one
INSERT INTO "comment" ("key_id", "value_id", "user_id", "message") VALUES ($1, $2, $3, $4) RETURNING *;

-- name: CreateComments :copyfrom
INSERT INTO "comment" ("key_id", "value_id", "user_id", "message") VALUES ($1, $2, $3, $4);



-- name: FindUserByEmail :one
SELECT * FROM "user" WHERE "email" = $1 LIMIT 1 ;




-- name: FindProjectsByUserID :many
SELECT 
    "project".*,  
    sqlc.embed(locale)
FROM "project" 
INNER JOIN "project_user"   ON "project_user"."project_id" = "project"."id" AND "project_user"."deleted_at" IS NULL
LEFT JOIN "locale"          ON "locale"."project_id" = "project"."id" AND "locale"."deleted_at" IS NULL
WHERE "project_user"."user_id" = $1 AND "project"."deleted_at" IS NULL;

-- name: UpdateProject :one
UPDATE "project" SET
     "name"        = coalesce(sqlc.narg('name'), name),
     "description" = coalesce(sqlc.narg('description'), description)
WHERE "id" = sqlc.arg('id') AND deleted_at is NULL RETURNING *;

-- name: DeleteProjectUser :exec
UPDATE "project_user" SET "deleted_at" = now() WHERE "project_id" = $1 AND "user_id" = $2 RETURNING *;

-- name: DeleteProject :many
UPDATE "project" SET "deleted_at" = now() WHERE "id" = $1 RETURNING *;


-- name: FindKeysByProjectID :many
SELECT
    sqlc.embed(key),
    sqlc.embed(value)
FROM "key"
         LEFT JOIN "value" ON value.key_id = key.id
WHERE key.project_id = $1 AND key.deleted_at IS NULL AND value.deleted_at IS NULL
ORDER BY key.id DESC, value.locale_id ASC;

-- name: UpdateKey :one
UPDATE "key" SET
    "name"      = coalesce(sqlc.narg('name'), name),
    "key_type"  = sqlc.arg('key_type')
WHERE "id" = sqlc.arg('id') AND deleted_at is NULL RETURNING *;

-- name: DeleteKeyByID :many
UPDATE "key" SET "deleted_at" = now() WHERE "id" = $1 RETURNING *;

-- name: DeleteKeysByProjectID :many
UPDATE "key" SET "deleted_at" = now() WHERE "project_id" = $1 RETURNING *;




-- name: FindValuesByKeyID :many
SELECT * FROM "value" WHERE "key_id" = $1 AND "deleted_at" IS NULL;

-- name: UpdateValue :one
UPDATE "value" SET 
    "value"         = coalesce(sqlc.narg('value'), value),
    "status"        = coalesce(sqlc.narg('status'), status),
    "has_comments"  = coalesce(sqlc.narg('has_comments'), has_comments)
WHERE "id" = sqlc.arg('id') AND deleted_at is NULL RETURNING *;

-- name: UpdateCommentInValue :one
UPDATE "value" SET
    "has_comments"  = coalesce(sqlc.narg('has_comments'), has_comments)
WHERE "id" = sqlc.arg('id') AND deleted_at is NULL RETURNING *;

-- name: DeleteValuesByKeyID :many
UPDATE "value" SET "deleted_at" = now()
WHERE "key_id" = ANY($1::bigint[]) RETURNING *;

-- name: DeleteValuesByProjectID :many
UPDATE "value" SET "deleted_at" = now() WHERE "project_id" = $1 RETURNING *;

-- name: DeleteValuesByLocaleID :many
UPDATE "value" SET "deleted_at" = now() WHERE "locale_id" = $1 RETURNING *;




-- name: FindLocalesByProjectID :many
SELECT * FROM "locale" WHERE "project_id" = $1 AND "deleted_at" IS NULL ORDER BY "id" ASC ;

-- name: UpdateLocale :one
UPDATE "locale" SET
    "name"      = coalesce(sqlc.narg('name'), name),
    "lang"      = coalesce(sqlc.narg('lang'), lang),
    "country"   = coalesce(sqlc.narg('country'), country),
    "code"      = coalesce(sqlc.narg('code'), code)
WHERE "locale"."id" = sqlc.arg('id') AND deleted_at is NULL RETURNING *;

-- name: DeleteLocaleByID :one
UPDATE "locale" SET "deleted_at" = now() WHERE "locale"."id" = $1 RETURNING *;

-- name: DeleteLocalesByProjectID :exec
UPDATE "locale" SET "deleted_at" = now() WHERE "project_id" = $1 RETURNING *;




-- name: FindComments :many
SELECT 
    "comment".*,
    sqlc.embed(u)
FROM "comment"
LEFT JOIN "user" u ON u."id" = "comment"."user_id"
WHERE "comment"."key_id" = $1 AND "comment"."deleted_at" IS NULL
ORDER BY "comment"."id" DESC;

-- name: FindCommentsByKeysIDs :many
SELECT * FROM "comment" WHERE "key_id" = ANY($1::bigint[]) AND "deleted_at" IS NULL;

-- name: FindCommentByID :one
SELECT 
    "comment".*,
    sqlc.embed(u)
FROM "comment"
LEFT JOIN "user" u ON u."id" = "comment"."user_id"
WHERE "comment"."id" = $1  AND "comment"."deleted_at" IS NULL
ORDER BY "comment"."id" DESC;

-- name: UpdateComment :one
UPDATE "comment" SET "message" = $1 WHERE "id" = $2 AND "deleted_at" is NULL RETURNING *;

-- name: DeleteCommentsByKeysValuesIDs :many
UPDATE "comment" SET "deleted_at" = now() WHERE "key_id" = ANY($1::bigint[]) AND "value_id" = ANY($2::bigint[]) AND "user_id" = $3 RETURNING *;

-- name: DeleteCommentByID :one
UPDATE "comment" SET "deleted_at" = now() WHERE "id" = $1 AND "deleted_at" is NULL RETURNING *;




-- name: CreateValueVersion :one
INSERT INTO "value_version" ("value_id", "creator_id", "value") VALUES ($1, $2, $3) RETURNING *;

-- name: CreateValueVersions :copyfrom
INSERT INTO "value_version" ("value_id", "creator_id", "value")
VALUES ($1, $2, $3);

-- name: FindValueVersions :many
SELECT "value_version".*,
    sqlc.embed(u)
FROM "value_version"
LEFT JOIN "user" u ON u."id" = "value_version"."creator_id"
WHERE "value_id" = $1 AND "value_version"."deleted_at" IS NULL ORDER BY "value_version"."id" DESC;

-- name: DeleteValueVersionsByValueID :exec
UPDATE "value_version" SET "deleted_at" = now() WHERE "value_id" = ANY($1::bigint[]);











-- name: CreateUpload :one
INSERT INTO "upload" (  "content_type", "filename","project_id", "user_id", "URL", "slug", "provider") VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *;

-- name: CreateUploads :copyfrom
INSERT INTO "upload" (  "content_type", "filename","project_id", "user_id", "URL", "slug", "provider") VALUES ($1, $2, $3, $4, $5, $6, $7);

-- name: FindUpload :one
SELECT * FROM "upload" WHERE "id" = $1;

-- name: GetUploadByIDs :many
SELECT * FROM "upload"
    WHERE id = ANY($1::bigint[]);

-- name: FindValues :many
SELECT * FROM "value" WHERE "project_id" = $1;

-- name: FindKeys :many
SELECT * FROM "key" WHERE "project_id" = $1;

-- name: FindLocales :many
SELECT * FROM "locale" WHERE "project_id" = $1;

-- name: FindUserProjects :many
SELECT * FROM "project_user" WHERE "project_id" = $1 AND "user_id" = $2;

-- name: FindAllValueVersions :many
SELECT * FROM "value_version" WHERE "value_id" = ANY($1::bigint[]);





-- name: DeleteValues :exec
DELETE FROM "value" WHERE "project_id" = $1;

-- name: DeleteKeys :exec
DELETE FROM "key" WHERE "project_id" = $1;

-- name: DeleteLocales :exec
DELETE FROM "locale" WHERE "project_id" = $1;

-- name: DeleteUserProjects :exec
DELETE FROM "project_user" WHERE "project_id" = $1 and "user_id" = $2;

-- name: DeleteComments :exec
DELETE FROM "comment" WHERE "key_id" = ANY($1::bigint[]);

-- name: DeleteValueVersions :exec
DELETE FROM "value_version" WHERE "value_id" = ANY($1::bigint[]);

-- name: RestoreProjectUsers :copyfrom
INSERT INTO "project_user" ("id", "created_at", "updated_at", "deleted_at", "project_id", "user_id") VALUES ($1, $2, $3, $4, $5, $6);

-- name: RestoreValues :copyfrom
INSERT INTO "value" ("id", "created_at", "updated_at", "deleted_at", "project_id", "key_id", "locale_id", "locale_code", "value", "status", "has_comments") VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11);

-- name: RestoreKeys :copyfrom
INSERT INTO "key" ("id", "created_at", "updated_at", "deleted_at", "project_id", "name", "key_type") VALUES ($1, $2, $3, $4, $5, $6, $7);

-- name: RestoreLocales :copyfrom
INSERT INTO "locale" ("id", "created_at", "updated_at", "deleted_at", "project_id", "name", "lang", "country", "code") VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9);

-- name: RestoreComments :copyfrom
INSERT INTO "comment" ("created_at", "updated_at", "deleted_at", "key_id", "value_id", "user_id", "message") VALUES ($1, $2, $3, $4, $5, $6, $7);

-- name: RestoreValueVersions :copyfrom
INSERT INTO "value_version" ("id", "created_at", "updated_at", "deleted_at", "value_id", "creator_id", "value") VALUES ($1, $2, $3, $4, $5, $6, $7);




-- name: CreateBackup :one
INSERT INTO "backup" ("content_type", "filename","project_id", "user_id", "URL", "slug", "provider") VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *;

-- name: CreateBackups :copyfrom
INSERT INTO "backup" ("content_type", "filename","project_id", "user_id", "URL", "slug", "provider") VALUES ($1, $2, $3, $4, $5, $6, $7);

-- name: FindBackups :many
SELECT * FROM "backup" WHERE "project_id" = $1;

-- name: GetBackupByID :one
SELECT * FROM "backup" WHERE "id" = $1;



-- name: CreateMedia :one
INSERT INTO "media" ( "project_id", "content_type", "filename","user_id", "URL", "original_name", "slug", "provider", "title", "description", "key_IDs")
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING *;

-- name: CreateMedias :copyfrom
INSERT INTO "media" ( "project_id", "content_type", "filename","user_id", "URL", "original_name", "slug", "provider", "title", "description", "key_IDs")
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11);




-- name: GetMediaByProjectID :many
SELECT * FROM "media" WHERE "project_id" = $1;

-- name: TestModeCreateSetTimeTriggerFunction :exec
CREATE OR REPLACE FUNCTION test_mode_set_time() 
RETURNS trigger 
LANGUAGE plpgsql AS $$
BEGIN
  new.created_at = '2023-04-01 12:30:00'::TIMESTAMP;
  new.updated_at = new.created_at;
  RETURN new;
END;
$$;

-- name: TestModeCreateTriggerOnAllTablesFunction :exec
CREATE OR REPLACE PROCEDURE test_mode_create_triggers()
LANGUAGE plpgsql AS $$
DECLARE
  _sql VARCHAR;
BEGIN
  FOR _sql IN SELECT CONCAT (
      'create trigger tg_',
      table_name,
      '_before_insert_or_update before insert or update on ',
      QUOTE_IDENT(table_name),
      ' for each row execute procedure test_mode_set_time ();'
    )
    FROM
      information_schema.tables
    WHERE  
      table_schema NOT IN ('pg_catalog', 'information_schema') AND    
      table_schema NOT LIKE 'pg_toast%' AND
      table_name NOT IN ('schema_migrations')
  LOOP
    EXECUTE _sql;
  END LOOP;
END;
$$;

-- name: TestModeCallCreateAllTriggers :exec
CALL test_mode_create_triggers();

-- name: TestModeCreateResetAutomincrementFunction :exec
CREATE OR REPLACE PROCEDURE test_mode_create_reset_autoincrement_function()
language plpgsql
AS $$
DECLARE
    tables CURSOR FOR
        SELECT c.relname as tablename
		FROM pg_class c 
		LEFT JOIN pg_namespace n ON n.oid = c.relnamespace 
		WHERE c.relkind = 'r' and n.nspname = 'public'  and c.relname != 'schema_migrations'
		GROUP BY c.relname;
    maxID bigint;
BEGIN
    FOR table_record IN tables LOOP
        EXECUTE 'SELECT max(id) FROM "' || table_record.tablename || '"' INTO maxID;
        PERFORM SETVAL(pg_get_serial_sequence(table_record.tablename, 'id'), maxID);
    END LOOP;
END
$$;

-- name: TestModeCallResetAutoincrement :exec
CALL test_mode_create_reset_autoincrement_function();

