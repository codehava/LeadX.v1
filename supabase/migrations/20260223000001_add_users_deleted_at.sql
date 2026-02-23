-- Phase 09: Add deleted_at column to users table for soft-delete support
-- Required by admin-delete-user Edge Function and fetchAllUsers filter
ALTER TABLE users ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;
