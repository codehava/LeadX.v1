-- Seed initial scoring period
-- Creates Week 6, 2026 as the first active scoring period

INSERT INTO scoring_periods (name, period_type, start_date, end_date, is_current, is_locked)
VALUES ('Week 6, Feb 2026', 'WEEKLY', '2026-02-09', '2026-02-15', TRUE, FALSE);

-- Note: This period includes the current date (2026-02-05 falls within Week 6)
-- Subsequent periods will be created by admins via the admin UI (Phase 1)
