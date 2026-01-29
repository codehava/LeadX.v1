-- Migration: Add delta sync support to customer_hvc_links table
-- This adds updated_at and deleted_at columns for incremental sync capability

-- Add updated_at column with default value
ALTER TABLE "public"."customer_hvc_links"
ADD COLUMN IF NOT EXISTS "updated_at" timestamp with time zone DEFAULT "now"();

-- Add deleted_at column for soft deletes
ALTER TABLE "public"."customer_hvc_links"
ADD COLUMN IF NOT EXISTS "deleted_at" timestamp with time zone;

-- Backfill updated_at from linked_at for existing records
UPDATE "public"."customer_hvc_links"
SET "updated_at" = COALESCE("linked_at", "now"())
WHERE "updated_at" IS NULL;

-- Create trigger to auto-update updated_at on changes
CREATE OR REPLACE TRIGGER "customer_hvc_links_updated_at"
BEFORE UPDATE ON "public"."customer_hvc_links"
FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();

-- Add index on updated_at for efficient delta queries
CREATE INDEX IF NOT EXISTS "idx_customer_hvc_links_updated_at"
ON "public"."customer_hvc_links" ("updated_at");

-- Add index on deleted_at for soft delete queries
CREATE INDEX IF NOT EXISTS "idx_customer_hvc_links_deleted_at"
ON "public"."customer_hvc_links" ("deleted_at")
WHERE "deleted_at" IS NOT NULL;
