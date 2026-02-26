-- Add key_person_id to activities table
ALTER TABLE "public"."activities"
    ADD COLUMN IF NOT EXISTS "key_person_id" "uuid";

ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_key_person_id_fkey"
    FOREIGN KEY ("key_person_id")
    REFERENCES "public"."key_persons"("id")
    ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS "idx_activities_key_person"
    ON "public"."activities" USING "btree" ("key_person_id");
