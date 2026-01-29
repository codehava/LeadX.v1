-- ============================================
-- LeadX CRM - Remove COB/LOB from Pipeline Referrals
-- Referrals now transfer the entire customer, not specific products
-- ============================================

-- Drop columns that are no longer needed
ALTER TABLE pipeline_referrals
  DROP COLUMN IF EXISTS cob_id,
  DROP COLUMN IF EXISTS lob_id,
  DROP COLUMN IF EXISTS potential_premium,
  DROP COLUMN IF EXISTS pipeline_id;

-- Update the table comment
COMMENT ON TABLE pipeline_referrals IS
'Pipeline referrals for RM-to-RM customer handoffs.
When approved, the entire customer (and all their pipelines) transfers to the receiver RM.
The receiver decides what products to pursue - no auto-pipeline creation.

Status flow:
1. PENDING_RECEIVER - Waiting for receiver to accept/reject
2. RECEIVER_ACCEPTED - Waiting for manager (BM/ROH) approval
3. BM_APPROVED -> COMPLETED (trigger handles transfer)
4. RECEIVER_REJECTED / BM_REJECTED / CANCELLED - End states';
