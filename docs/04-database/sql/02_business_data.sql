-- ============================================
-- LeadX CRM - Schema Part 2: Business Data
-- Run this SECOND after 01_foundation.sql
-- ============================================

-- ============================================
-- CUSTOMER & KEY PERSONS
-- ============================================

CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(200) NOT NULL,
  address TEXT,
  province_id UUID REFERENCES provinces(id),
  city_id UUID REFERENCES cities(id),
  postal_code VARCHAR(10),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  phone VARCHAR(20),
  email VARCHAR(255),
  website VARCHAR(255),
  company_type_id UUID REFERENCES company_types(id),
  ownership_type_id UUID REFERENCES ownership_types(id),
  industry_id UUID REFERENCES industries(id),
  npwp VARCHAR(50),
  assigned_rm_id UUID REFERENCES users(id),
  image_url TEXT,
  notes TEXT,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES users(id),
  is_pending_sync BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  last_sync_at TIMESTAMPTZ
);

CREATE INDEX idx_customers_assigned_rm ON customers(assigned_rm_id);
CREATE INDEX idx_customers_created_by ON customers(created_by);

-- Key Persons (unified for CUSTOMER/BROKER/HVC)
CREATE TABLE key_persons (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_type VARCHAR(20) NOT NULL CHECK (owner_type IN ('CUSTOMER', 'BROKER', 'HVC')),
  customer_id UUID REFERENCES customers(id),
  broker_id UUID,
  hvc_id UUID,
  name VARCHAR(100) NOT NULL,
  position VARCHAR(100),
  department VARCHAR(100),
  phone VARCHAR(20),
  email VARCHAR(255),
  is_primary BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  notes TEXT,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_key_persons_customer ON key_persons(customer_id);

-- ============================================
-- HVC & BROKERS
-- ============================================

CREATE TABLE hvcs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(200) NOT NULL,
  type_id UUID REFERENCES hvc_types(id),
  description TEXT,
  address TEXT,
  province_id UUID REFERENCES provinces(id),
  city_id UUID REFERENCES cities(id),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  phone VARCHAR(20),
  email VARCHAR(255),
  website VARCHAR(255),
  industry_id UUID REFERENCES industries(id),
  image_url TEXT,
  notes TEXT,
  visit_frequency_days INTEGER DEFAULT 30,
  potential_value DECIMAL(18, 2), -- Added to match Dart entity/Supabase schema seen usage
  radius_meters INTEGER DEFAULT 500, -- Added to match Dart entity/Supabase schema seen usage
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES users(id),
  is_pending_sync BOOLEAN DEFAULT false, -- Standard offline-sync field
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE TABLE brokers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(200) NOT NULL,
  license_number VARCHAR(50),
  address TEXT,
  province_id UUID REFERENCES provinces(id),
  city_id UUID REFERENCES cities(id),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  phone VARCHAR(20),
  email VARCHAR(255),
  website VARCHAR(255),
  commission_rate DECIMAL(5, 2),
  image_url TEXT,
  notes TEXT,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Link customers to HVC
CREATE TABLE customer_hvc_links (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
  hvc_id UUID REFERENCES hvcs(id) ON DELETE CASCADE,
  relationship_type VARCHAR(50),
  notes TEXT,
  linked_at TIMESTAMPTZ DEFAULT NOW(),
  linked_by UUID REFERENCES users(id),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  UNIQUE(customer_id, hvc_id)
);

-- Index for delta sync queries
CREATE INDEX idx_customer_hvc_links_updated_at ON customer_hvc_links(updated_at);
CREATE INDEX idx_customer_hvc_links_deleted_at ON customer_hvc_links(deleted_at) WHERE deleted_at IS NOT NULL;

-- Update key_persons FKs
ALTER TABLE key_persons ADD CONSTRAINT fk_key_persons_broker FOREIGN KEY (broker_id) REFERENCES brokers(id);
ALTER TABLE key_persons ADD CONSTRAINT fk_key_persons_hvc FOREIGN KEY (hvc_id) REFERENCES hvcs(id);

-- ============================================
-- PIPELINES & REFERRALS
-- ============================================

CREATE TABLE pipeline_referrals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(20) UNIQUE NOT NULL,
  customer_id UUID REFERENCES customers(id) NOT NULL,
  referrer_rm_id UUID REFERENCES users(id) NOT NULL,
  receiver_rm_id UUID REFERENCES users(id) NOT NULL,
  -- Branch IDs nullable for kanwil-level RMs
  referrer_branch_id UUID REFERENCES branches(id),
  receiver_branch_id UUID REFERENCES branches(id),
  -- Regional office for ROH fallback approval
  referrer_regional_office_id UUID REFERENCES regional_offices(id),
  receiver_regional_office_id UUID REFERENCES regional_offices(id),
  -- Approver type: any role besides RM can approve (BH, BM, ROH, ADMIN, SUPERADMIN)
  approver_type VARCHAR(10) NOT NULL DEFAULT 'BM' CHECK (approver_type IN ('BH', 'BM', 'ROH', 'ADMIN', 'SUPERADMIN')),
  reason TEXT NOT NULL,
  notes TEXT,
  status VARCHAR(30) NOT NULL DEFAULT 'PENDING_RECEIVER' CHECK (status IN (
    'PENDING_RECEIVER', 'RECEIVER_ACCEPTED', 'RECEIVER_REJECTED',
    'PENDING_BM', 'BM_APPROVED', 'BM_REJECTED', 'COMPLETED', 'CANCELLED'
  )),
  -- Receiver Response
  receiver_accepted_at TIMESTAMPTZ,
  receiver_rejected_at TIMESTAMPTZ,
  receiver_reject_reason TEXT,
  receiver_notes TEXT,
  -- Manager approval (BM or ROH based on approver_type)
  bm_approved_at TIMESTAMPTZ,
  bm_approved_by UUID REFERENCES users(id),
  bm_rejected_at TIMESTAMPTZ,
  bm_reject_reason TEXT,
  bm_notes TEXT,
  -- Result
  bonus_calculated BOOLEAN NOT NULL DEFAULT false,
  bonus_amount DECIMAL(18, 2),
  -- Expiration & Cancellation
  expires_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  cancel_reason TEXT,
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE pipelines (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(20) UNIQUE NOT NULL,
  customer_id UUID REFERENCES customers(id),
  stage_id UUID REFERENCES pipeline_stages(id),
  status_id UUID REFERENCES pipeline_statuses(id),
  cob_id UUID REFERENCES cobs(id),
  lob_id UUID REFERENCES lobs(id),
  lead_source_id UUID REFERENCES lead_sources(id),
  broker_id UUID REFERENCES brokers(id),
  broker_pic_id UUID REFERENCES key_persons(id),
  customer_contact_id UUID REFERENCES key_persons(id),
  tsi DECIMAL(18, 2),
  potential_premium DECIMAL(18, 2) NOT NULL,
  final_premium DECIMAL(18, 2),
  weighted_value DECIMAL(18, 2),
  expected_close_date DATE,
  policy_number VARCHAR(50),
  decline_reason TEXT,
  notes TEXT,
  is_tender BOOLEAN DEFAULT false,
  referred_by_user_id UUID REFERENCES users(id),
  referral_id UUID REFERENCES pipeline_referrals(id),
  assigned_rm_id UUID REFERENCES users(id),
  scored_to_user_id UUID REFERENCES users(id),  -- User who receives 4DX scoring credit (set at win)
  created_by UUID REFERENCES users(id),
  is_pending_sync BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  closed_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  last_sync_at TIMESTAMPTZ
);

CREATE INDEX idx_pipelines_customer ON pipelines(customer_id);
CREATE INDEX idx_pipelines_assigned_rm ON pipelines(assigned_rm_id);
CREATE INDEX idx_pipelines_scored_to_user ON pipelines(scored_to_user_id);
CREATE INDEX idx_pipelines_stage ON pipelines(stage_id);

-- ============================================
-- ACTIVITIES
-- ============================================

CREATE TABLE activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  created_by UUID REFERENCES users(id),
  object_type VARCHAR(20) NOT NULL CHECK (object_type IN ('CUSTOMER', 'HVC', 'BROKER', 'PIPELINE')),
  customer_id UUID REFERENCES customers(id),
  hvc_id UUID REFERENCES hvcs(id),
  broker_id UUID REFERENCES brokers(id),
  pipeline_id UUID REFERENCES pipelines(id),
  key_person_id UUID REFERENCES key_persons(id) ON DELETE SET NULL,
  activity_type_id UUID REFERENCES activity_types(id),
  summary TEXT,
  notes TEXT,
  scheduled_datetime TIMESTAMPTZ NOT NULL,
  is_immediate BOOLEAN DEFAULT false,
  status VARCHAR(20) DEFAULT 'PLANNED' CHECK (status IN ('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'RESCHEDULED', 'OVERDUE')),
  executed_at TIMESTAMPTZ,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  location_accuracy DECIMAL(10, 2),
  distance_from_target DECIMAL(10, 2),
  is_location_override BOOLEAN DEFAULT false,
  override_reason TEXT,
  rescheduled_from_id UUID REFERENCES activities(id),
  rescheduled_to_id UUID REFERENCES activities(id),
  cancelled_at TIMESTAMPTZ,
  cancel_reason TEXT,
  is_pending_sync BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  last_sync_at TIMESTAMPTZ
);

CREATE INDEX idx_activities_user ON activities(user_id);
CREATE INDEX idx_activities_scheduled ON activities(scheduled_datetime);
CREATE INDEX idx_activities_status ON activities(status);

CREATE TABLE activity_photos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  activity_id UUID REFERENCES activities(id) ON DELETE CASCADE NOT NULL,
  photo_url TEXT NOT NULL,
  caption TEXT,
  taken_at TIMESTAMPTZ,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE activity_audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  activity_id UUID REFERENCES activities(id) ON DELETE CASCADE,
  action VARCHAR(50) NOT NULL,
  old_status VARCHAR(20),
  new_status VARCHAR(20),
  old_values JSONB,
  new_values JSONB,
  changed_fields JSONB,
  latitude DECIMAL(10, 7),
  longitude DECIMAL(10, 7),
  device_info JSONB,
  performed_by UUID REFERENCES users(id),
  performed_at TIMESTAMPTZ DEFAULT NOW(),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_activity_audit_logs_activity ON activity_audit_logs(activity_id);
CREATE INDEX idx_activity_audit_logs_performed_by ON activity_audit_logs(performed_by);
CREATE INDEX idx_activity_audit_logs_performed_at ON activity_audit_logs(performed_at DESC);
CREATE INDEX idx_activity_audit_logs_action ON activity_audit_logs(action);

-- ============================================
-- TRIGGERS
-- ============================================

CREATE TRIGGER customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER key_persons_updated_at BEFORE UPDATE ON key_persons FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER hvc_updated_at BEFORE UPDATE ON hvcs FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER brokers_updated_at BEFORE UPDATE ON brokers FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER pipelines_updated_at BEFORE UPDATE ON pipelines FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER activities_updated_at BEFORE UPDATE ON activities FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER customer_hvc_links_updated_at BEFORE UPDATE ON customer_hvc_links FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================
-- PIPELINE REFERRAL APPROVAL TRIGGER
-- ============================================

-- Handles full customer handoff when referral is approved
CREATE OR REPLACE FUNCTION handle_referral_approval()
RETURNS TRIGGER AS $$
BEGIN
  -- Only act when status changes to BM_APPROVED
  IF NEW.status = 'BM_APPROVED' AND OLD.status != 'BM_APPROVED' THEN

    -- 1. Reassign customer to receiver RM
    UPDATE customers
    SET
      assigned_rm_id = NEW.receiver_rm_id,
      updated_at = NOW()
    WHERE id = NEW.customer_id;

    -- 2. Reassign OPEN pipelines for this customer to receiver
    --    AND set referred_by_user_id for 4DX tracking (referral bonus if pipeline wins)
    UPDATE pipelines
    SET
      assigned_rm_id = NEW.receiver_rm_id,
      referred_by_user_id = NEW.referrer_rm_id,
      referral_id = NEW.id,
      updated_at = NOW()
    WHERE customer_id = NEW.customer_id
      AND deleted_at IS NULL
      AND closed_at IS NULL;  -- Only open pipelines

    -- 3. Reassign CLOSED pipelines for visibility (new RM can see customer history)
    --    Note: scored_to_user_id is already set and won't change - original owner keeps scoring credit
    UPDATE pipelines
    SET
      assigned_rm_id = NEW.receiver_rm_id,
      updated_at = NOW()
    WHERE customer_id = NEW.customer_id
      AND deleted_at IS NULL
      AND closed_at IS NOT NULL;  -- Only closed pipelines

    -- 4. Mark referral as COMPLETED
    NEW.status := 'COMPLETED';
    NEW.updated_at := NOW();

    RAISE NOTICE 'Referral % approved: Customer % reassigned to RM %, pipelines transferred with referrer credit',
      NEW.code, NEW.customer_id, NEW.receiver_rm_id;

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_referral_approved ON pipeline_referrals;
CREATE TRIGGER on_referral_approved
  BEFORE UPDATE ON pipeline_referrals
  FOR EACH ROW
  EXECUTE FUNCTION handle_referral_approval();

COMMENT ON FUNCTION handle_referral_approval() IS
'Handles pipeline referral approval by:
1. Reassigning customer to receiver RM
2. Reassigning OPEN pipelines to receiver with referred_by_user_id set for 4DX tracking
3. Reassigning CLOSED pipelines to receiver for visibility (customer history)
4. Marking the referral as COMPLETED

IMPORTANT: scored_to_user_id on closed pipelines is NOT changed - original owner keeps scoring credit.
Only assigned_rm_id changes so the new RM can view the customer pipeline history.';

-- ============================================
-- PIPELINE WON TRIGGER (Sets scored_to_user_id)
-- ============================================

-- Sets scored_to_user_id when pipeline transitions to WON stage
CREATE OR REPLACE FUNCTION handle_pipeline_won()
RETURNS TRIGGER AS $$
BEGIN
  -- Only act when transitioning TO a won stage and scored_to_user_id not already set
  IF NEW.stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true)
     AND (OLD.stage_id IS NULL OR OLD.stage_id NOT IN (SELECT id FROM pipeline_stages WHERE is_won = true))
     AND NEW.scored_to_user_id IS NULL
  THEN
    NEW.scored_to_user_id := NEW.assigned_rm_id;
    NEW.updated_at := NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_pipeline_won ON pipelines;
CREATE TRIGGER on_pipeline_won
  BEFORE UPDATE ON pipelines
  FOR EACH ROW
  EXECUTE FUNCTION handle_pipeline_won();

-- Also handle INSERT for pipelines created directly in won stage
CREATE OR REPLACE FUNCTION handle_pipeline_won_insert()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true)
     AND NEW.scored_to_user_id IS NULL
  THEN
    NEW.scored_to_user_id := NEW.assigned_rm_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_pipeline_won_insert ON pipelines;
CREATE TRIGGER on_pipeline_won_insert
  BEFORE INSERT ON pipelines
  FOR EACH ROW
  EXECUTE FUNCTION handle_pipeline_won_insert();

COMMENT ON COLUMN pipelines.scored_to_user_id IS
'The user who receives 4DX lag measure credit for this pipeline.
Set automatically when pipeline reaches WON stage (via trigger).
Never changes after being set, even if assigned_rm_id changes.
This separates operational ownership (assigned_rm_id) from scoring attribution (scored_to_user_id).';

-- ============================================
-- END PART 2
-- ============================================
