# 📝 User Stories

## User Stories LeadX CRM

---

## 📋 Overview

Dokumen ini berisi user stories untuk LeadX CRM, diorganisir berdasarkan modul dan prioritas (P0 = Must Have, P1 = Should Have).

---

## 🔐 Authentication Module

### US-AUTH-001: Login
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | User (all roles) |
| **I want to** | Login dengan email dan password |
| **So that** | Saya dapat mengakses aplikasi sesuai role saya |

**Acceptance Criteria:**
- [x] Input email dan password
- [x] Validasi format email
- [x] Error message jika credential salah
- [x] Lockout setelah 5 kali gagal
- [x] Redirect ke dashboard setelah sukses
- [x] Token tersimpan secure

### US-AUTH-002: Logout
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | Logged-in user |
| **I want to** | Logout dari aplikasi |
| **So that** | Session saya aman |

**Acceptance Criteria:**
- [x] Button logout di menu
- [x] Konfirmasi sebelum logout
- [x] Clear session dan tokens
- [x] Redirect ke login page

### US-AUTH-003: Forgot Password
| Field | Value |
|-------|-------|
| **Priority** | P1 |
| **As a** | User yang lupa password |
| **I want to** | Reset password via email |
| **So that** | Saya dapat login kembali |

**Acceptance Criteria:**
- [x] Input email untuk reset
- [x] Email terkirim dengan link reset
- [x] Link valid 24 jam
- [x] Password baru sesuai policy

---

## 👤 Customer Module

### US-CUST-001: View Customer List
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM |
| **I want to** | Melihat daftar customer yang assigned ke saya |
| **So that** | Saya tahu customer mana yang harus difollow-up |

**Acceptance Criteria:**
- [x] List customer dengan search dan filter
- [x] Tampilkan nama, alamat, last activity
- [x] Sort by nama, tanggal terakhir visit
- [x] Infinite scroll / pagination
- [x] Pull-to-refresh
- [x] Works offline

### US-CUST-002: Create Customer
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM |
| **I want to** | Menambah customer baru |
| **So that** | Database customer bertambah |

**Acceptance Criteria:**
- [x] Form input: nama, alamat, provinsi, kota, kode pos
- [x] Form input: telepon, email, website
- [x] Dropdown: tipe perusahaan, kepemilikan, industri
- [x] GPS auto-capture untuk lokasi
- [x] Validasi field wajib
- [x] Simpan offline jika no internet
- [x] Auto-sync saat online

### US-CUST-003: View Customer Detail
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM |
| **I want to** | Melihat detail customer |
| **So that** | Saya tahu informasi lengkap customer |

**Acceptance Criteria:**
- [x] Tampilkan semua info customer
- [x] Tab: Info, Key Persons, Pipelines, Activities
- [x] Quick actions: Call, WhatsApp, Navigate
- [x] History activities
- [x] Works offline

### US-CUST-004: Edit Customer
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM |
| **I want to** | Mengubah data customer |
| **So that** | Data customer selalu akurat |

**Acceptance Criteria:**
- [x] Edit semua field
- [x] Validasi field wajib
- [x] Audit trail (who changed what)
- [x] Offline edit support

### US-CUST-005: Add Key Person
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM |
| **I want to** | Menambah key person di customer |
| **So that** | Saya tahu siapa contact person-nya |

**Acceptance Criteria:**
- [x] Form: nama, jabatan, department, telepon, email
- [x] Set primary contact
- [x] Multiple key persons per customer
- [x] Quick call/WhatsApp dari list

---

## 📊 Pipeline Module

### US-PIPE-001: View Pipeline List
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM |
| **I want to** | Melihat daftar pipeline saya |
| **So that** | Saya tahu status setiap prospek |

**Acceptance Criteria:**
- [x] Kanban view by stage (New, P3, P2, P1, Accepted, Declined)
- [x] List view dengan filter stage
- [x] Tampilkan: customer, COB, potential premium, expected close
- [x] Color coding by stage
- [x] Search dan filter

### US-PIPE-002: Create Pipeline
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM |
| **I want to** | Membuat pipeline baru |
| **So that** | Prospek tercatat di sistem |

**Acceptance Criteria:**
- [x] Pilih customer (required)
- [x] Pilih COB dan LOB
- [x] Input potential premium
- [x] Pilih lead source (Direct, Broker, Referral, Event)
- [x] Jika Broker: pilih broker dan PIC
- [x] Expected close date
- [x] Auto-assign ke RM yang membuat

### US-PIPE-003: Update Pipeline Stage
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM |
| **I want to** | Memindahkan pipeline ke stage berikutnya |
| **So that** | Progress prospek terupdate |

**Acceptance Criteria:**
- [x] Drag-drop di Kanban atau button di detail
- [x] Wajib ada notes saat pindah stage
- [x] Jika Accepted: input policy number, final premium
- [x] Jika Declined: pilih reason
- [x] Timestamp tercatat

### US-PIPE-004: View Pipeline Detail
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM |
| **I want to** | Melihat detail pipeline |
| **So that** | Saya tahu semua informasi prospek |

**Acceptance Criteria:**
- [x] Info lengkap pipeline
- [x] Stage history (timeline)
- [x] Related activities
- [x] Customer info preview
- [x] Quick actions

---

## 📅 Activity Module

### US-ACT-001: Schedule Activity
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM |
| **I want to** | Menjadwalkan aktivitas (visit, call, meeting) |
| **So that** | Saya punya rencana kerja harian |

**Acceptance Criteria:**
- [x] Pilih tipe aktivitas (Visit, Call, Meeting, etc.)
- [x] Pilih target (Customer, Pipeline, HVC, Broker)
- [x] Set tanggal dan jam
- [x] Optional notes
- [x] Appear di calendar view

### US-ACT-002: Execute Activity (Check-in)
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM di lokasi customer |
| **I want to** | Check-in untuk mencatat visit |
| **So that** | Aktivitas terverifikasi dengan GPS |

**Acceptance Criteria:**
- [x] Silent GPS capture saat check-in
- [x] Calculate distance dari lokasi customer
- [x] Warning jika jarak >500m
- [x] Override option dengan reason
- [x] Input notes wajib
- [x] Optional photo
- [x] Offline support

### US-ACT-003: Immediate Activity
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM |
| **I want to** | Mencatat aktivitas spontan (tidak terjadwal) |
| **So that** | Semua aktivitas tercatat meski tidak direncanakan |

**Acceptance Criteria:**
- [x] Quick add button
- [x] Same form as scheduled
- [x] Mark as "immediate" activity
- [x] GPS capture

### US-ACT-004: View My Activities
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM |
| **I want to** | Melihat aktivitas saya (calendar view) |
| **So that** | Saya tahu jadwal dan history aktivitas |

**Acceptance Criteria:**
- [x] Calendar view (day, week, month)
- [x] List view dengan filter status
- [x] Color by status (Planned, Completed, Overdue)
- [x] Tap untuk detail

---

## 🏢 HVC Module

### US-HVC-001: View HVC List
| Field | Value |
|-------|-------|
| **Priority** | P1 |
| **As a** | RM |
| **I want to** | Melihat daftar HVC |
| **So that** | Saya tahu HVC mana yang relevan |

**Acceptance Criteria:**
- [x] List HVC dengan search
- [x] Tampilkan nama, tipe, jumlah customer linked
- [x] Map view dengan geofence

### US-HVC-002: View HVC Customers
| Field | Value |
|-------|-------|
| **Priority** | P1 |
| **As a** | RM |
| **I want to** | Melihat customer yang linked ke HVC |
| **So that** | Saya bisa planning visit ke kawasan |

**Acceptance Criteria:**
- [x] List customer per HVC
- [x] Filter by relationship type
- [x] Quick plan visit ke multiple customers

---

## 🤝 Broker Module

### US-BROKER-001: View Broker List
| Field | Value |
|-------|-------|
| **Priority** | P1 |
| **As a** | RM |
| **I want to** | Melihat daftar broker referral |
| **So that** | Saya bisa follow-up leads dari broker |

**Acceptance Criteria:**
- [x] List broker dengan search
- [x] Tampilkan nama, type, key persons
- [x] Pipelines sourced from broker

### US-BROKER-002: Create Pipeline from Broker
| Field | Value |
|-------|-------|
| **Priority** | P1 |
| **As a** | RM |
| **I want to** | Membuat pipeline dengan sumber broker |
| **So that** | Referral tercatat dengan benar |

**Acceptance Criteria:**
- [x] Select broker saat create pipeline
- [x] Select broker PIC
- [x] Lead source = BROKER

---

## 📊 Dashboard & Scoreboard

### US-DASH-001: View My Dashboard
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM |
| **I want to** | Melihat dashboard personal |
| **So that** | Saya tahu performa saya hari ini |

**Acceptance Criteria:**
- [x] Today's activities (planned vs completed)
- [x] This week's stats
- [x] Pipeline summary by stage
- [x] Quick actions

### US-SCORE-001: View 4DX Scoreboard
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM |
| **I want to** | Melihat scoreboard 4DX |
| **So that** | Saya tahu ranking dan target |

**Acceptance Criteria:**
- [x] WIG (Wildly Important Goal)
- [x] Lead measures (Visit count, Pipeline created)
- [x] Lag measures (Premium closed)
- [x] My score vs team
- [x] Leaderboard

---

## 👥 Team View (BH/BM/ROH)

### US-TEAM-001: View Team Performance
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | BH/BM/ROH |
| **I want to** | Melihat performa tim saya |
| **So that** | Saya bisa monitor dan coach |

**Acceptance Criteria:**
- [x] List subordinates dengan stats
- [x] Today's activities per RM
- [x] Pipeline summary per RM
- [x] Drill-down ke individual

### US-TEAM-002: View Team Scoreboard
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | BH/BM/ROH |
| **I want to** | Melihat scoreboard level tim/cabang/regional |
| **So that** | Saya tahu standing tim |

**Acceptance Criteria:**
- [x] Team aggregate score
- [x] Individual breakdown
- [x] Compare with other teams/branches

---

## 📅 Cadence Module

### US-CAD-001: Pre-Cadence Form
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | RM |
| **I want to** | Mengisi form sebelum cadence meeting |
| **So that** | Saya siap untuk meeting |

**Acceptance Criteria:**
- [x] Review last week commitments
- [x] Input this week commitments
- [x] Blockers/challenges
- [x] Submit before deadline

### US-CAD-002: View Cadence Meeting
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | BH (cadence host) |
| **I want to** | Melihat agenda cadence meeting |
| **So that** | Meeting berjalan terstruktur |

**Acceptance Criteria:**
- [x] List participants dengan form status
- [x] Scoreboard review
- [x] Commitment summary
- [x] Mark attendance

---

## ⚙️ Admin Module

### US-ADMIN-001: Manage Users
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | Admin |
| **I want to** | Mengelola user (CRUD) |
| **So that** | User dapat mengakses sistem |

**Acceptance Criteria:**
- [x] List users dengan filter by role, branch
- [x] Create user dengan role assignment
- [x] Edit user info dan role
- [x] Activate/Deactivate user
- [x] Reset password

### US-ADMIN-002: Manage Master Data
| Field | Value |
|-------|-------|
| **Priority** | P0 |
| **As a** | Admin |
| **I want to** | Mengelola master data |
| **So that** | Dropdown options up-to-date |

**Acceptance Criteria:**
- [x] CRUD: Industries, COB, LOB, Company Types, etc.
- [x] Activate/Deactivate items
- [x] Bulk import via CSV

---

## 📚 Related Documents

- [Functional Requirements](functional-requirements.md) - Requirement details
- [Screen Flows](../05-ui-ux/screen-flows.md) - UI Flows
- [Acceptance Criteria](acceptance-criteria.md) - Detailed AC

---

*User stories version 1.0 - January 2025*
