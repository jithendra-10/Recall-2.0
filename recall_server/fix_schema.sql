-- Create recall tables with properly quoted CamelCase columns
DROP TABLE IF EXISTS recall_interaction CASCADE;
DROP TABLE IF EXISTS recall_contact CASCADE;
DROP TABLE IF EXISTS recall_user_config CASCADE;

CREATE TABLE "recall_contact" (
    "id" bigserial PRIMARY KEY,
    "ownerId" bigint NOT NULL,
    "email" text NOT NULL,
    "name" text,
    "avatarUrl" text,
    "bio" text,
    "lastContacted" timestamp without time zone,
    "healthScore" double precision NOT NULL,
    "tier" bigint NOT NULL
);
CREATE UNIQUE INDEX "contact_unique" ON "recall_contact" USING btree ("ownerId", "email");

CREATE TABLE "recall_interaction" (
    "id" bigserial PRIMARY KEY,
    "ownerId" bigint NOT NULL,
    "contactId" bigint NOT NULL,
    "date" timestamp without time zone NOT NULL,
    "snippet" text NOT NULL,
    "embedding" vector(768) NOT NULL,
    "type" text NOT NULL,
    "sentiment" text
);
CREATE INDEX "interaction_vector_idx" ON "recall_interaction" USING hnsw ("embedding" vector_l2_ops);

CREATE TABLE "recall_user_config" (
    "id" bigserial PRIMARY KEY,
    "userInfoId" bigint NOT NULL,
    "googleRefreshToken" text,
    "lastSyncTime" timestamp without time zone,
    "gmailHistoryId" text
);
CREATE UNIQUE INDEX "user_config_idx" ON "recall_user_config" USING btree ("userInfoId");

ALTER TABLE "recall_interaction" ADD CONSTRAINT "recall_interaction_fk_0"
    FOREIGN KEY("contactId") REFERENCES "recall_contact"("id");
