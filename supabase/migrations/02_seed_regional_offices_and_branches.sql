-- ============================================
-- LeadX CRM - Seed Data Part 2
-- Regional Offices and Branches
-- ============================================

-- ============================================
-- INSERT REGIONAL OFFICES
-- ============================================

INSERT INTO regional_offices (code, name, description, address, latitude, longitude, phone, is_active)
VALUES
  ('RO-JKT', 'Jakarta Regional Office', 'Head Office - Jakarta Region', 'Jl. Sudirman No. 1, Jakarta 12190', -6.2088, 106.8456, '(021) 1234-5678', true),
  ('RO-JWB', 'Jawa Barat Regional Office', 'Bandung Regional Office', 'Jl. Gatot Subroto No. 50, Bandung 40274', -6.9271, 107.6411, '(022) 2345-6789', true),
  ('RO-JWT', 'Jawa Timur Regional Office', 'Surabaya Regional Office', 'Jl. Pemuda No. 23, Surabaya 60181', -7.2504, 112.7488, '(031) 3456-7890', true),
  ('RO-SUM', 'Sumatera Regional Office', 'Medan Regional Office', 'Jl. Merdeka No. 45, Medan 20112', 3.1957, 98.6722, '(061) 4567-8901', true),
  ('RO-KAL', 'Kalimantan Regional Office', 'Banjarmasin Regional Office', 'Jl. Ahmad Yani No. 60, Banjarmasin 70113', -3.3260, 114.5947, '(0511) 5678-9012', true),
  ('RO-SUL', 'Sulawesi Regional Office', 'Makassar Regional Office', 'Jl. Hasanuddin No. 78, Makassar 90114', -5.1477, 119.4327, '(0411) 6789-0123', true);

-- ============================================
-- INSERT BRANCHES (organized by regional office)
-- ============================================

-- Jakarta Regional Office Branches
INSERT INTO branches (code, name, regional_office_id, address, latitude, longitude, phone, is_active)
VALUES
  ('BR-JKT-001', 'Jakarta Pusat Branch', (SELECT id FROM regional_offices WHERE code = 'RO-JKT'), 'Jl. Thamrin No. 12, Jakarta Pusat 10340', -6.1940, 106.8272, '(021) 2111-0001', true),
  ('BR-JKT-002', 'Jakarta Selatan Branch', (SELECT id FROM regional_offices WHERE code = 'RO-JKT'), 'Jl. Panglima Polim No. 88, Jakarta Selatan 12140', -6.2829, 106.7869, '(021) 2222-0002', true),
  ('BR-JKT-003', 'Jakarta Utara Branch', (SELECT id FROM regional_offices WHERE code = 'RO-JKT'), 'Jl. Gunung Sahari No. 34, Jakarta Utara 14410', -6.1389, 106.8369, '(021) 2333-0003', true),
  ('BR-JKT-004', 'Jakarta Barat Branch', (SELECT id FROM regional_offices WHERE code = 'RO-JKT'), 'Jl. Jatibaru No. 56, Jakarta Barat 11240', -6.1563, 106.7456, '(021) 2444-0004', true);

-- Jawa Barat Regional Office Branches
INSERT INTO branches (code, name, regional_office_id, address, latitude, longitude, phone, is_active)
VALUES
  ('BR-JWB-001', 'Bandung Pusat Branch', (SELECT id FROM regional_offices WHERE code = 'RO-JWB'), 'Jl. Braga No. 1, Bandung 40111', -6.9175, 107.6087, '(022) 3111-0001', true),
  ('BR-JWB-002', 'Cimahi Branch', (SELECT id FROM regional_offices WHERE code = 'RO-JWB'), 'Jl. Cihanjuang No. 45, Cimahi 40531', -6.8845, 107.5423, '(022) 3222-0002', true),
  ('BR-JWB-003', 'Sukabumi Branch', (SELECT id FROM regional_offices WHERE code = 'RO-JWB'), 'Jl. Jalak Harupat No. 123, Sukabumi 43122', -6.9271, 106.9281, '(0266) 3333-0003', true);

-- Jawa Timur Regional Office Branches
INSERT INTO branches (code, name, regional_office_id, address, latitude, longitude, phone, is_active)
VALUES
  ('BR-JWT-001', 'Surabaya Pusat Branch', (SELECT id FROM regional_offices WHERE code = 'RO-JWT'), 'Jl. Embong Malang No. 50, Surabaya 60261', -7.2471, 112.7381, '(031) 4111-0001', true),
  ('BR-JWT-002', 'Sidoarjo Branch', (SELECT id FROM regional_offices WHERE code = 'RO-JWT'), 'Jl. Raya Sidoarjo No. 200, Sidoarjo 61214', -7.4425, 112.7265, '(031) 4222-0002', true),
  ('BR-JWT-003', 'Malang Branch', (SELECT id FROM regional_offices WHERE code = 'RO-JWT'), 'Jl. Merdeka No. 78, Malang 65111', -7.9797, 112.6304, '(0341) 4333-0003', true);

-- Sumatera Regional Office Branches
INSERT INTO branches (code, name, regional_office_id, address, latitude, longitude, phone, is_active)
VALUES
  ('BR-SUM-001', 'Medan Pusat Branch', (SELECT id FROM regional_offices WHERE code = 'RO-SUM'), 'Jl. Balai Kota No. 1, Medan 20111', 3.1957, 98.6722, '(061) 5111-0001', true),
  ('BR-SUM-002', 'Pematangsiantar Branch', (SELECT id FROM regional_offices WHERE code = 'RO-SUM'), 'Jl. Sudirman No. 45, Pematangsiantar 21111', 2.6268, 99.0667, '(0622) 5222-0002', true);

-- Kalimantan Regional Office Branches
INSERT INTO branches (code, name, regional_office_id, address, latitude, longitude, phone, is_active)
VALUES
  ('BR-KAL-001', 'Banjarmasin Pusat Branch', (SELECT id FROM regional_offices WHERE code = 'RO-KAL'), 'Jl. Lambung Mangkurat No. 50, Banjarmasin 70111', -3.3260, 114.5947, '(0511) 6111-0001', true),
  ('BR-KAL-002', 'Samarinda Branch', (SELECT id FROM regional_offices WHERE code = 'RO-KAL'), 'Jl. Sudirman No. 88, Samarinda 75123', -0.5021, 117.1431, '(0541) 6222-0002', true);

-- Sulawesi Regional Office Branches
INSERT INTO branches (code, name, regional_office_id, address, latitude, longitude, phone, is_active)
VALUES
  ('BR-SUL-001', 'Makassar Pusat Branch', (SELECT id FROM regional_offices WHERE code = 'RO-SUL'), 'Jl. Somba Opu No. 1, Makassar 90111', -5.1477, 119.4327, '(0411) 7111-0001', true),
  ('BR-SUL-002', 'Manado Branch', (SELECT id FROM regional_offices WHERE code = 'RO-SUL'), 'Jl. Sam Ratulangi No. 123, Manado 95111', 1.4748, 124.8629, '(0431) 7222-0002', true);

-- ============================================
-- SUMMARY
-- ============================================
-- Regional Offices: 6
-- Total Branches: 17
-- ============================================
