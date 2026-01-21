-- ============================================
-- LeadX CRM - Migration: Fix activity_photos schema
-- Run this in Supabase SQL Editor if table already exists
-- ============================================

-- Check current table structure first
-- SELECT column_name, data_type FROM information_schema.columns 
-- WHERE table_name = 'activity_photos';

-- ============================================
-- MIGRATION: Update activity_photos to correct schema
-- ============================================

-- Step 1: Add new columns
ALTER TABLE activity_photos 
  ADD COLUMN IF NOT EXISTS photo_url TEXT,
  ADD COLUMN IF NOT EXISTS taken_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS latitude DECIMAL(10, 8),
  ADD COLUMN IF NOT EXISTS longitude DECIMAL(11, 8),
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- Step 2: Migrate data from old columns to new (if old columns exist)
UPDATE activity_photos 
SET photo_url = file_path,
    created_at = COALESCE(uploaded_at, NOW())
WHERE photo_url IS NULL AND file_path IS NOT NULL;

-- Step 3: Make photo_url NOT NULL (after data migration)
ALTER TABLE activity_photos 
  ALTER COLUMN photo_url SET NOT NULL;

-- Step 4: Make activity_id NOT NULL (if not already)
ALTER TABLE activity_photos 
  ALTER COLUMN activity_id SET NOT NULL;

-- Step 5: Drop old columns (only after verifying data migrated)
-- WARNING: Uncomment only after confirming data is correct!
-- ALTER TABLE activity_photos 
--   DROP COLUMN IF EXISTS file_path,
--   DROP COLUMN IF EXISTS file_size,
--   DROP COLUMN IF EXISTS mime_type,
--   DROP COLUMN IF EXISTS uploaded_at,
--   DROP COLUMN IF EXISTS is_synced;

-- ============================================
-- VERIFICATION QUERY
-- ============================================
-- Run this to verify the new schema:
-- SELECT column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name = 'activity_photos'
-- ORDER BY ordinal_position;
