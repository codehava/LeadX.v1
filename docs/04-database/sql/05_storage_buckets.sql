-- ============================================
-- LeadX CRM - Supabase Storage Bucket Setup
-- Run this in Supabase SQL Editor
-- ============================================

-- NOTE: Storage buckets must be created via Supabase Dashboard or API
-- This script creates the RLS policies for the bucket

-- ============================================
-- STEP 1: Create the bucket via Supabase Dashboard
-- ============================================
-- Go to: Supabase Dashboard > Storage > New Bucket
-- Name: activity-photos
-- Public: false (private bucket)
-- Allowed MIME types: image/jpeg, image/png, image/webp
-- File size limit: 10MB

-- ============================================
-- STEP 2: Apply RLS Policies (run in SQL Editor)
-- ============================================

-- Allow authenticated users to upload photos to their activities
CREATE POLICY "Users can upload activity photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'activity-photos'
  AND (storage.foldername(name))[1] = 'activities'
);

-- Allow authenticated users to read their activity photos
CREATE POLICY "Users can read activity photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'activity-photos'
);

-- Allow authenticated users to update their activity photos
CREATE POLICY "Users can update activity photos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'activity-photos'
)
WITH CHECK (
  bucket_id = 'activity-photos'
);

-- Allow authenticated users to delete their activity photos
CREATE POLICY "Users can delete activity photos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'activity-photos'
);

-- ============================================
-- ALTERNATIVE: Create bucket via SQL (requires admin access)
-- ============================================
-- INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
-- VALUES (
--   'activity-photos',
--   'activity-photos',
--   false,
--   10485760, -- 10MB
--   ARRAY['image/jpeg', 'image/png', 'image/webp']
-- );
