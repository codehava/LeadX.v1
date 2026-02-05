-- ============================================
-- Migration: Fix sync_queue_items RLS
-- Priority: CRITICAL
-- Issue: Policy USING(true) allows all authenticated users to see ALL sync queue items
-- Fix: Remove permissive policy - no authenticated access (service_role only)
-- ============================================

-- Drop the overly permissive policy
DROP POLICY IF EXISTS "sync_queue_own" ON sync_queue_items;

-- RLS remains enabled but with no policies = no authenticated user access
-- Only service_role (admin) can access this table
-- This is safe because the Flutter app uses local SQLite for sync queue, not this table

-- Add a comment explaining the security decision
COMMENT ON TABLE sync_queue_items IS 'Sync queue for debugging/admin only. RLS enabled with no policies = service_role access only. App uses local SQLite sync queue.';
