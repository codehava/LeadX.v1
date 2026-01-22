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
  company_name VARCHAR(200),
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
  UNIQUE(customer_id, hvc_id)
);

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
  cob_id UUID REFERENCES cobs(id) NOT NULL,
  lob_id UUID REFERENCES lobs(id) NOT NULL,
  potential_premium DECIMAL(18, 2) NOT NULL,
  referrer_rm_id UUID REFERENCES users(id) NOT NULL,
  receiver_rm_id UUID REFERENCES users(id) NOT NULL,
  referrer_branch_id UUID REFERENCES branches(id) NOT NULL,
  receiver_branch_id UUID REFERENCES branches(id) NOT NULL,
  reason TEXT NOT NULL,
  notes TEXT,
  status VARCHAR(30) NOT NULL DEFAULT 'PENDING_RECEIVER' CHECK (status IN (
    'PENDING_RECEIVER', 'RECEIVER_ACCEPTED', 'RECEIVER_REJECTED',
    'PENDING_BM', 'BM_APPROVED', 'BM_REJECTED', 'COMPLETED', 'CANCELLED'
  )),
  referrer_approved_at TIMESTAMPTZ,
  receiver_accepted_at TIMESTAMPTZ,
  receiver_rejected_at TIMESTAMPTZ,
  receiver_reject_reason TEXT,
  bm_approved_at TIMESTAMPTZ,
  bm_approved_by UUID REFERENCES users(id),
  bm_rejected_at TIMESTAMPTZ,
  bm_reject_reason TEXT,
  pipeline_id UUID,
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

-- ============================================
-- END PART 2
-- ============================================
