-- ============================================
-- LeadX CRM - Schema Part 3: 4DX, Cadence, System + Seed Data
-- Run this THIRD after 02_business_data.sql
-- ============================================

-- ============================================
-- 4DX SCORING TABLES
-- ============================================

CREATE TABLE scoring_periods (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  period_type VARCHAR(20) NOT NULL CHECK (period_type IN ('MONTHLY', 'QUARTERLY', 'YEARLY')),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_current BOOLEAN DEFAULT false,
  is_locked BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE measure_definitions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  measure_type VARCHAR(20) NOT NULL CHECK (measure_type IN ('LEAD', 'LAG')),
  unit VARCHAR(50) NOT NULL,
  calculation_method VARCHAR(50),
  weight DECIMAL(5, 2) DEFAULT 1.0,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_targets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  period_id UUID REFERENCES scoring_periods(id),
  measure_id UUID REFERENCES measure_definitions(id),
  target_value DECIMAL(18, 2) NOT NULL,
  assigned_by UUID REFERENCES users(id),
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, period_id, measure_id)
);

CREATE TABLE user_scores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  period_id UUID REFERENCES scoring_periods(id),
  measure_id UUID REFERENCES measure_definitions(id),
  actual_value DECIMAL(18, 2) DEFAULT 0,
  percentage DECIMAL(5, 2) DEFAULT 0,
  score DECIMAL(10, 2) DEFAULT 0,
  rank INTEGER,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, period_id, measure_id)
);

CREATE TABLE user_score_snapshots (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  period_id UUID REFERENCES scoring_periods(id),
  total_score DECIMAL(10, 2),
  lead_score DECIMAL(10, 2),
  lag_score DECIMAL(10, 2),
  rank INTEGER,
  snapshot_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- CADENCE TABLES
-- ============================================

CREATE TABLE cadence_schedule_config (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
  time_of_day TIME NOT NULL,
  duration_minutes INTEGER DEFAULT 60,
  pre_meeting_hours INTEGER DEFAULT 24,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE cadence_meetings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  scheduled_at TIMESTAMPTZ NOT NULL,
  host_id UUID REFERENCES users(id),
  meeting_type VARCHAR(50) DEFAULT 'WEEKLY',
  status VARCHAR(20) DEFAULT 'SCHEDULED' CHECK (status IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
  notes TEXT,
  started_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE cadence_participants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  meeting_id UUID REFERENCES cadence_meetings(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  pre_meeting_submitted BOOLEAN DEFAULT false,
  pre_meeting_data JSONB,
  pre_meeting_submitted_at TIMESTAMPTZ,
  attendance_status VARCHAR(20) DEFAULT 'PENDING' CHECK (attendance_status IN ('PENDING', 'PRESENT', 'ABSENT', 'EXCUSED')),
  marked_at TIMESTAMPTZ,
  UNIQUE(meeting_id, user_id)
);

-- ============================================
-- NOTIFICATIONS & ANNOUNCEMENTS
-- ============================================

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  title VARCHAR(200) NOT NULL,
  body TEXT,
  notification_type VARCHAR(50) NOT NULL,
  reference_type VARCHAR(50),
  reference_id UUID,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;

CREATE TABLE announcements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(200) NOT NULL,
  body TEXT NOT NULL,
  priority VARCHAR(20) DEFAULT 'NORMAL' CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
  target_roles TEXT[],
  target_branches UUID[],
  start_at TIMESTAMPTZ DEFAULT NOW(),
  end_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE announcement_reads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  announcement_id UUID REFERENCES announcements(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  read_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(announcement_id, user_id)
);

-- ============================================
-- SYSTEM TABLES
-- ============================================

CREATE TABLE sync_queue_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  table_name VARCHAR(50) NOT NULL,
  record_id UUID NOT NULL,
  operation VARCHAR(20) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
  payload JSONB,
  status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'SYNCING', 'SYNCED', 'FAILED')),
  retry_count INTEGER DEFAULT 0,
  last_error TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX idx_sync_queue_pending ON sync_queue_items(status) WHERE status = 'PENDING';

CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  user_email VARCHAR(255),
  action VARCHAR(50) NOT NULL,
  target_table VARCHAR(50),
  target_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address VARCHAR(50),
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE app_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key VARCHAR(100) UNIQUE NOT NULL,
  value TEXT,
  value_type VARCHAR(20) DEFAULT 'STRING' CHECK (value_type IN ('STRING', 'NUMBER', 'BOOLEAN', 'JSON')),
  description TEXT,
  is_editable BOOLEAN DEFAULT true,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- SEED DATA
-- ============================================

-- Company Types
INSERT INTO company_types (id, code, name, sort_order) VALUES
  (uuid_generate_v4(), 'PT', 'Perseroan Terbatas', 1),
  (uuid_generate_v4(), 'CV', 'Commanditaire Vennootschap', 2),
  (uuid_generate_v4(), 'UD', 'Usaha Dagang', 3),
  (uuid_generate_v4(), 'PERORANGAN', 'Perorangan', 4),
  (uuid_generate_v4(), 'KOPERASI', 'Koperasi', 5),
  (uuid_generate_v4(), 'YAYASAN', 'Yayasan', 6),
  (uuid_generate_v4(), 'BUMN', 'BUMN', 7),
  (uuid_generate_v4(), 'BUMD', 'BUMD', 8);

-- Ownership Types
INSERT INTO ownership_types (id, code, name, sort_order) VALUES
  (uuid_generate_v4(), 'BUMN', 'BUMN', 1),
  (uuid_generate_v4(), 'BUMD', 'BUMD', 2),
  (uuid_generate_v4(), 'SWASTA', 'Swasta Nasional', 3),
  (uuid_generate_v4(), 'ASING', 'Swasta Asing', 4),
  (uuid_generate_v4(), 'CAMPURAN', 'Campuran', 5);

-- Lead Sources
INSERT INTO lead_sources (id, code, name, requires_referrer, requires_broker) VALUES
  (uuid_generate_v4(), 'COLD_CALL', 'Cold Call', false, false),
  (uuid_generate_v4(), 'REFERRAL', 'Referral', true, false),
  (uuid_generate_v4(), 'BROKER', 'Broker', false, true),
  (uuid_generate_v4(), 'EXISTING', 'Existing Customer', false, false),
  (uuid_generate_v4(), 'TENDER', 'Tender', false, false),
  (uuid_generate_v4(), 'WALK_IN', 'Walk In', false, false);

-- Pipeline Stages
INSERT INTO pipeline_stages (id, code, name, probability, sequence, color, is_final, is_won) VALUES
  (uuid_generate_v4(), 'NEW', 'New Lead', 10, 0, '#6366F1', false, false),
  (uuid_generate_v4(), 'P3', 'P3 - Prospecting', 25, 1, '#9CA3AF', false, false),
  (uuid_generate_v4(), 'P2', 'P2 - Negotiation', 50, 2, '#F59E0B', false, false),
  (uuid_generate_v4(), 'P1', 'P1 - Proposal', 75, 3, '#3B82F6', false, false),
  (uuid_generate_v4(), 'ACCEPTED', 'Accepted', 100, 4, '#10B981', true, true),
  (uuid_generate_v4(), 'DECLINED', 'Declined', 0, 5, '#EF4444', true, false);

-- Activity Types
INSERT INTO activity_types (id, code, name, icon, require_location, require_photo, require_notes) VALUES
  (uuid_generate_v4(), 'VISIT', 'Kunjungan', 'location_on', true, true, false),
  (uuid_generate_v4(), 'CALL', 'Telepon', 'phone', false, false, false),
  (uuid_generate_v4(), 'MEETING', 'Meeting', 'groups', true, false, true),
  (uuid_generate_v4(), 'EMAIL', 'Email', 'email', false, false, false),
  (uuid_generate_v4(), 'PRESENTATION', 'Presentasi', 'slideshow', true, false, true),
  (uuid_generate_v4(), 'FOLLOW_UP', 'Follow Up', 'replay', false, false, true);

-- HVC Types
INSERT INTO hvc_types (id, code, name, sort_order) VALUES
  (uuid_generate_v4(), 'KONGLOMERAT', 'Konglomerat', 1),
  (uuid_generate_v4(), 'HOLDING', 'Holding Company', 2),
  (uuid_generate_v4(), 'GROUP', 'Business Group', 3),
  (uuid_generate_v4(), 'ASOSIASI', 'Asosiasi', 4);

-- COBs
INSERT INTO cobs (id, code, name, sort_order) VALUES
  (uuid_generate_v4(), 'SB', 'Surety Bond', 1),
  (uuid_generate_v4(), 'KI', 'Kredit Investasi', 2),
  (uuid_generate_v4(), 'GI', 'General Insurance', 3);

-- Measure Definitions (4DX)
INSERT INTO measure_definitions (id, code, name, measure_type, unit, weight, sort_order) VALUES
  (uuid_generate_v4(), 'VISIT', 'Kunjungan per Minggu', 'LEAD', 'COUNT', 1.0, 1),
  (uuid_generate_v4(), 'P3_NEW', 'P3 Baru per Bulan', 'LEAD', 'COUNT', 1.0, 2),
  (uuid_generate_v4(), 'PREMIUM', 'Premium Closed', 'LAG', 'IDR', 2.0, 3),
  (uuid_generate_v4(), 'CONVERSION', 'Conversion Rate', 'LAG', 'PERCENT', 1.5, 4);

-- App Settings
INSERT INTO app_settings (key, value, value_type, description) VALUES
  ('gps_accuracy_threshold', '50', 'NUMBER', 'Maximum GPS accuracy in meters'),
  ('gps_distance_threshold', '100', 'NUMBER', 'Maximum distance from target in meters'),
  ('offline_retention_days', '30', 'NUMBER', 'Days to keep offline data'),
  ('sync_interval_minutes', '5', 'NUMBER', 'Background sync interval');

-- ============================================
-- ADDITIONAL MASTER DATA SEED
-- ============================================

-- Provinces (Top 10 Indonesia)
INSERT INTO provinces (id, code, name, is_active) VALUES
  (uuid_generate_v4(), 'JKT', 'DKI Jakarta', true),
  (uuid_generate_v4(), 'JBR', 'Jawa Barat', true),
  (uuid_generate_v4(), 'JTG', 'Jawa Tengah', true),
  (uuid_generate_v4(), 'JTM', 'Jawa Timur', true),
  (uuid_generate_v4(), 'BTN', 'Banten', true),
  (uuid_generate_v4(), 'DIY', 'DI Yogyakarta', true),
  (uuid_generate_v4(), 'SMT', 'Sumatera Utara', true),
  (uuid_generate_v4(), 'SLS', 'Sulawesi Selatan', true),
  (uuid_generate_v4(), 'KTM', 'Kalimantan Timur', true),
  (uuid_generate_v4(), 'BLI', 'Bali', true);

-- Cities (Sample major cities per province)
WITH province_ids AS (
  SELECT id, code FROM provinces
)
INSERT INTO cities (id, code, name, province_id, is_active)
SELECT uuid_generate_v4(), city.code, city.name, p.id, true
FROM province_ids p
CROSS JOIN (VALUES
  ('JKT', 'JKT-PS', 'Jakarta Pusat'),
  ('JKT', 'JKT-BR', 'Jakarta Barat'),
  ('JKT', 'JKT-SL', 'Jakarta Selatan'),
  ('JKT', 'JKT-TM', 'Jakarta Timur'),
  ('JKT', 'JKT-UT', 'Jakarta Utara'),
  ('JBR', 'BDG', 'Bandung'),
  ('JBR', 'BKS', 'Bekasi'),
  ('JBR', 'BGR', 'Bogor'),
  ('JBR', 'DPK', 'Depok'),
  ('JBR', 'CRB', 'Cirebon'),
  ('JTG', 'SMG', 'Semarang'),
  ('JTG', 'SKT', 'Surakarta'),
  ('JTM', 'SBY', 'Surabaya'),
  ('JTM', 'MLG', 'Malang'),
  ('JTM', 'SDJ', 'Sidoarjo'),
  ('BTN', 'TGR', 'Tangerang'),
  ('BTN', 'SRP', 'Tangerang Selatan'),
  ('BTN', 'SRG', 'Serang'),
  ('DIY', 'YGY', 'Yogyakarta'),
  ('DIY', 'SLM', 'Sleman'),
  ('SMT', 'MDN', 'Medan'),
  ('SMT', 'BTM', 'Batam'),
  ('SLS', 'MKS', 'Makassar'),
  ('KTM', 'BPN', 'Balikpapan'),
  ('KTM', 'SMD', 'Samarinda'),
  ('BLI', 'DPS', 'Denpasar'),
  ('BLI', 'GYN', 'Gianyar')
) AS city(prov_code, code, name)
WHERE p.code = city.prov_code;

-- Industries
INSERT INTO industries (id, code, name, sort_order, is_active) VALUES
  (uuid_generate_v4(), 'CONSTRUCTION', 'Konstruksi', 1, true),
  (uuid_generate_v4(), 'MANUFACTURING', 'Manufaktur', 2, true),
  (uuid_generate_v4(), 'TRADING', 'Perdagangan', 3, true),
  (uuid_generate_v4(), 'MINING', 'Pertambangan', 4, true),
  (uuid_generate_v4(), 'OIL_GAS', 'Minyak & Gas', 5, true),
  (uuid_generate_v4(), 'POWER', 'Pembangkit Listrik', 6, true),
  (uuid_generate_v4(), 'TRANSPORTATION', 'Transportasi', 7, true),
  (uuid_generate_v4(), 'INFRASTRUCTURE', 'Infrastruktur', 8, true),
  (uuid_generate_v4(), 'PROPERTY', 'Properti', 9, true),
  (uuid_generate_v4(), 'TELECOMMUNICATION', 'Telekomunikasi', 10, true),
  (uuid_generate_v4(), 'FINANCIAL', 'Keuangan', 11, true),
  (uuid_generate_v4(), 'AGRICULTURE', 'Pertanian', 12, true),
  (uuid_generate_v4(), 'HEALTHCARE', 'Kesehatan', 13, true),
  (uuid_generate_v4(), 'RETAIL', 'Ritel', 14, true),
  (uuid_generate_v4(), 'HOSPITALITY', 'Perhotelan', 15, true),
  (uuid_generate_v4(), 'EDUCATION', 'Pendidikan', 16, true),
  (uuid_generate_v4(), 'GOVERNMENT', 'Pemerintahan', 17, true),
  (uuid_generate_v4(), 'OTHERS', 'Lainnya', 99, true);

-- LOBs (Line of Business per COB)
INSERT INTO lobs (id, cob_id, code, name, description, sort_order, is_active)
SELECT 
  uuid_generate_v4(), 
  c.id, 
  lob.code, 
  lob.name, 
  lob.description, 
  lob.sort_order, 
  true
FROM cobs c
CROSS JOIN (VALUES
  ('SB', 'KU', 'Kontra Bank Uang Muka', 'Jaminan uang muka', 1),
  ('SB', 'KP', 'Kontra Bank Pelaksanaan', 'Jaminan pelaksanaan', 2),
  ('SB', 'KPM', 'Kontra Bank Pemeliharaan', 'Jaminan pemeliharaan', 3),
  ('SB', 'PN', 'Jaminan Penawaran', 'Jaminan penawaran tender', 4),
  ('SB', 'PB', 'Jaminan Pembayaran', 'Jaminan pembayaran', 5),
  ('SB', 'BEA', 'Customs Bond', 'Jaminan kepabeanan', 6),
  ('KI', 'EQUIPMENT', 'Kredit Alat Berat', 'Kredit pembelian alat berat', 1),
  ('KI', 'PROPERTY', 'Kredit Properti', 'Kredit properti komersial', 2),
  ('KI', 'VEHICLE', 'Kredit Kendaraan', 'Kredit kendaraan operasional', 3),
  ('GI', 'FIRE', 'Fire Insurance', 'Asuransi kebakaran', 1),
  ('GI', 'CAR', 'Contractor All Risk', 'Asuransi proyek konstruksi', 2),
  ('GI', 'EAR', 'Erection All Risk', 'Asuransi pemasangan mesin', 3),
  ('GI', 'MARINE', 'Marine Cargo', 'Asuransi pengiriman barang', 4),
  ('GI', 'LIABILITY', 'Public Liability', 'Asuransi tanggung gugat', 5),
  ('GI', 'MV', 'Motor Vehicle', 'Asuransi kendaraan bermotor', 6),
  ('GI', 'PA', 'Personal Accident', 'Asuransi kecelakaan diri', 7)
) AS lob(cob_code, code, name, description, sort_order)
WHERE c.code = lob.cob_code;

-- Decline Reasons
INSERT INTO decline_reasons (id, code, name, description, sort_order, is_active) VALUES
  (uuid_generate_v4(), 'PRICE', 'Harga Tidak Kompetitif', 'Penolakan karena premi terlalu mahal', 1, true),
  (uuid_generate_v4(), 'COMPETITOR', 'Memilih Pesaing', 'Nasabah memilih asuransi/penjamin lain', 2, true),
  (uuid_generate_v4(), 'NO_BUDGET', 'Tidak Ada Anggaran', 'Nasabah tidak memiliki anggaran', 3, true),
  (uuid_generate_v4(), 'CANCELLED', 'Proyek Dibatalkan', 'Proyek nasabah dibatalkan', 4, true),
  (uuid_generate_v4(), 'DOCUMENT', 'Dokumen Tidak Lengkap', 'Persyaratan dokumen tidak terpenuhi', 5, true),
  (uuid_generate_v4(), 'TIMING', 'Waktu Tidak Sesuai', 'Timing proses tidak sesuai kebutuhan', 6, true),
  (uuid_generate_v4(), 'CREDIT', 'Masalah Kredit/Reasuransi', 'Tidak lolos assessment kredit', 7, true),
  (uuid_generate_v4(), 'RELATIONSHIP', 'Hubungan Dengan Pesaing', 'Sudah memiliki hubungan dengan competitor', 8, true),
  (uuid_generate_v4(), 'OTHER', 'Alasan Lainnya', 'Alasan lain yang tidak termasuk di atas', 99, true);

-- Pipeline Statuses per Stage
INSERT INTO pipeline_statuses (id, stage_id, code, name, description, sequence, is_default, is_active, created_at, updated_at)
SELECT 
  uuid_generate_v4(), 
  ps.id, 
  status.code, 
  status.name, 
  status.description, 
  status.sequence, 
  status.is_default, 
  true,
  NOW(),
  NOW()
FROM pipeline_stages ps
CROSS JOIN (VALUES
  ('NEW', 'NEW_CREATED', 'Baru Dibuat', 'Lead baru ditambahkan ke pipeline', 1, true),
  ('P3', 'P3_NEW', 'Baru Diinput', 'Lead baru ditambahkan', 1, true),
  ('P3', 'P3_CONTACTED', 'Sudah Dihubungi', 'Sudah melakukan kontak awal', 2, false),
  ('P3', 'P3_MEETING', 'Jadwal Meeting', 'Ada jadwal pertemuan', 3, false),
  ('P2', 'P2_QUOTATION', 'Quotation Sent', 'Penawaran sudah dikirim', 1, true),
  ('P2', 'P2_NEGOTIATING', 'Negosiasi', 'Dalam proses negosiasi harga/syarat', 2, false),
  ('P2', 'P2_REVISION', 'Revisi Penawaran', 'Ada revisi penawaran', 3, false),
  ('P1', 'P1_PROPOSAL', 'Proposal Submitted', 'Proposal final sudah disubmit', 1, true),
  ('P1', 'P1_WAITING', 'Menunggu Keputusan', 'Menunggu keputusan nasabah', 2, false),
  ('P1', 'P1_FINAL', 'Final Review', 'Review akhir sebelum keputusan', 3, false),
  ('ACCEPTED', 'ACCEPTED_ACTIVE', 'Aktif', 'Polis/Jaminan aktif', 1, true),
  ('DECLINED', 'DECLINED_CLOSED', 'Closed Lost', 'Pipeline ditolak', 1, true)
) AS status(stage_code, code, name, description, sequence, is_default)
WHERE ps.code = status.stage_code;

-- ============================================
-- END PART 3
-- ============================================
