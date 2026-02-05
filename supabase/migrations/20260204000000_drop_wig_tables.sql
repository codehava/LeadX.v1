-- ============================================
-- Migration: Drop WIG Tables
-- Date: 2026-02-04
-- Reason: WIG functionality consolidated into measures
-- WIGs are conceptually just labels on measures at hierarchy levels
-- ============================================

-- 1. DROP RLS POLICIES (wig_progress first due to FK dependency)
DROP POLICY IF EXISTS "wig_progress_admin" ON wig_progress;
DROP POLICY IF EXISTS "wig_progress_insert" ON wig_progress;
DROP POLICY IF EXISTS "wig_progress_select" ON wig_progress;

DROP POLICY IF EXISTS "wigs_admin" ON wigs;
DROP POLICY IF EXISTS "wigs_approve" ON wigs;
DROP POLICY IF EXISTS "wigs_insert" ON wigs;
DROP POLICY IF EXISTS "wigs_select_hierarchy" ON wigs;
DROP POLICY IF EXISTS "wigs_select_own" ON wigs;
DROP POLICY IF EXISTS "wigs_update_own" ON wigs;

-- 2. DROP TRIGGER
DROP TRIGGER IF EXISTS wigs_updated_at ON wigs;

-- 3. DROP INDEXES
DROP INDEX IF EXISTS idx_wig_progress_date;
DROP INDEX IF EXISTS idx_wig_progress_wig;
DROP INDEX IF EXISTS idx_wigs_level;
DROP INDEX IF EXISTS idx_wigs_owner;
DROP INDEX IF EXISTS idx_wigs_parent;
DROP INDEX IF EXISTS idx_wigs_status;

-- 4. DROP TABLES (wig_progress first due to FK to wigs)
DROP TABLE IF EXISTS wig_progress;
DROP TABLE IF EXISTS wigs;
