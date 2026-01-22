-- ============================================
-- Migration: Update HVC Columns
-- Description: Rename type_id column and add missing fields
-- Run this AFTER rename_hvc_to_hvcs.sql
-- ============================================

BEGIN;

-- 1. Rename hvc_type_id to type_id
-- We use DO block to check if column exists before renaming to avoid errors if already renamed
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'hvcs' AND column_name = 'hvc_type_id') THEN
    ALTER TABLE hvcs RENAME COLUMN hvc_type_id TO type_id;
  END IF;
END $$;

-- 2. Add missing columns
ALTER TABLE hvcs ADD COLUMN IF NOT EXISTS radius_meters INTEGER DEFAULT 500;
ALTER TABLE hvcs ADD COLUMN IF NOT EXISTS potential_value DECIMAL(18, 2);

COMMIT;
