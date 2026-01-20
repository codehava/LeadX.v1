# 📋 Functional Requirements

## Spesifikasi Kebutuhan Fungsional LeadX CRM

---

## 📑 Overview

Dokumen ini mendeskripsikan kebutuhan fungsional LeadX CRM secara detail, mencakup semua modul dan fitur yang akan diimplementasikan.

---

## 🎯 Prioritization Legend

| Priority | Description | Timeline |
|----------|-------------|----------|
| **P0** | Must-have, MVP blocking | Sprint 1-6 |
| **P1** | Should-have, post-MVP | Sprint 7-10 |
| **P2** | Nice-to-have, future | Sprint 11+ |

---

## 📦 FR-001: Authentication & Login

### Overview
| ID | FR-001 |
|-----|--------|
| **Priority** | P0 |
| **Roles** | Semua User |
| **Dependencies** | - |

### Requirements

#### FR-001.1: Email/Password Login
- User dapat login menggunakan email dan password
- Email harus valid dan terdaftar di sistem
- Password minimum 8 karakter
- Show/hide password toggle tersedia

#### FR-001.2: JWT Token Management
- Access token expire dalam 1 jam
- Refresh token expire dalam 7 hari
- Auto-refresh saat access token expire
- Token disimpan secure di device

#### FR-001.3: Password Reset
- User dapat request password reset via email
- Reset link valid 24 jam
- Konfirmasi password saat reset
- Notifikasi email setelah password berubah

#### FR-001.4: Session Management
- Single device login per default
- Optional: multi-device dengan notifikasi
- Force logout dari semua device
- Last login timestamp tracking

### Acceptance Criteria
```gherkin
GIVEN user belum login
WHEN user memasukkan email dan password yang valid
THEN user berhasil login dan diarahkan ke Dashboard

GIVEN user sudah login
WHEN access token expire
THEN sistem auto-refresh menggunakan refresh token

GIVEN user lupa password
WHEN user request reset password
THEN email reset dikirim dalam 5 menit
```

---

## 📦 FR-002: Customer Management

### Overview
| ID | FR-002 |
|-----|--------|
| **Priority** | P0 |
| **Roles** | RM, Admin |
| **Dependencies** | FR-001 |

### Requirements

#### FR-002.1: Customer List
- Menampilkan daftar customer milik user (RM: own, BH+: subordinates)
- Pagination/infinite scroll
- Search by name, code
- Filter by: province, city, industry, ownership type
- Sort by: name, created date, last activity

#### FR-002.2: Customer Create
- Form fields:
  - Nama (required, max 200 char)
  - Alamat (required)
  - Provinsi (required, dropdown)
  - Kota (required, dropdown, filtered by province)
  - Kode Pos (optional)
  - Telepon (optional)
  - Email (optional, validated)
  - Website (optional)
  - Tipe Perusahaan (required: PT/CV/UD/etc)
  - Kepemilikan (required: BUMN/Swasta/etc)
  - Industri (required, dropdown)
  - NPWP (optional)
  - Catatan (optional)
- Auto-generate customer code (CUS-XXXXX)
- GPS location auto-capture saat create (silent)

#### FR-002.3: Customer View Detail
- Header: Nama, Code, Status badge
- Smart buttons: Pipeline count, Activity count, Total TSI
- Quick actions: Call, Email, WhatsApp, Maps, Log Activity, Schedule
- Info sections: 
  - Info Umum
  - Alamat
  - Key Persons
  - HVC Links (jika ada)
- Tab sections:
  - Aktivitas
  - Pipeline
  - Catatan
  - Riwayat

#### FR-002.4: Customer Edit
- Semua field editable kecuali code
- Validation sama dengan create
- Track updated_at dan updated_by

#### FR-002.5: Customer Key Persons
- Add key person ke customer
- Fields: Nama, Jabatan, Departemen, Telepon, Email
- Mark as primary contact
- Soft delete (inactive)

#### FR-002.6: GPS Auto-Capture
- Capture GPS coordinates saat create (background)
- Tidak prompt user untuk location
- Store null jika GPS unavailable (don't block)
- Accuracy threshold: 100m acceptable

### Acceptance Criteria
```gherkin
GIVEN RM sedang di lapangan
WHEN RM menambah customer baru
THEN GPS tercapture otomatis tanpa prompt
AND customer tersimpan dengan lokasi

GIVEN RM melihat customer list
WHEN RM search "ABC"
THEN hasil filter menampilkan customer dengan nama mengandung "ABC"

GIVEN RM melihat customer detail
WHEN RM tap tombol WhatsApp
THEN WhatsApp terbuka dengan nomor customer terisi
```

### Data Visibility Rules
| Role | Visibility |
|------|------------|
| RM | Own customers only |
| BH | Team customers (own + subordinate RMs) |
| BM | Branch customers |
| ROH | Regional customers |
| Admin | All customers |

---

## 📦 FR-003: Pipeline Management

### Overview
| ID | FR-003 |
|-----|--------|
| **Priority** | P0 |
| **Roles** | RM, Admin |
| **Dependencies** | FR-002 |

### Requirements

#### FR-003.1: Pipeline List
- Menampilkan daftar pipeline milik user
- Group by stage (Kanban view option)
- List view dengan stage pills
- Search by customer name, pipeline code
- Filter by: stage, COB, LOB, lead source, date range
- Sort by: potential premium, created date, expected close

#### FR-003.2: Pipeline Create
- Form fields:
  - Customer (required, searchable dropdown)
  - COB/Class of Business (required)
  - LOB/Line of Business (required, filtered by COB)
  - Lead Source (required: Direct/Broker/Referral/etc)
  - Broker (conditional, required if source=BROKER)
  - Broker PIC (conditional, if broker selected)
  - Customer Contact (optional, key person dropdown)
  - TSI/Total Sum Insured (optional)
  - Potential Premium (required)
  - Expected Close Date (optional)
  - Is Tender (boolean)
  - Notes (optional)
- Auto-generate pipeline code (PIP-XXXXX)
- Auto-set stage = NEW (10%)

#### FR-003.3: Pipeline Stage Progression
```
NEW (10%) → P3 (25%) → P2 (50%) → P1 (75%) → ACCEPTED (100%)
                ↓           ↓          ↓
              DECLINED   DECLINED   DECLINED (0%)
```
- Stage change via:
  - Pill tap (progress modal)
  - Edit form
- Require notes saat DECLINED
- Track stage history di audit log
- Weighted value = Potential Premium × Probability

#### FR-003.4: Pipeline Status per Stage
- Setiap stage memiliki status sub-options:
  - NEW: New Lead, Initial Contact Made
  - P3: Prospect Identified, Need Analysis Done
  - P2: Proposal Sent, Negotiation
  - P1: Verbal Agreement, Final Negotiation
  - ACCEPTED: Policy Issued, Payment Confirmed
  - DECLINED: Price Issue, Competition, No Budget, Other

#### FR-003.5: Pipeline View Detail
- Header: Customer name, Code, Stage pill, Status
- Smart buttons: Activity count, Days in stage
- Info sections:
  - Product Info (COB/LOB)
  - Values (TSI, Premium, Weighted)
  - Lead Source (Broker info if applicable)
- Tab sections:
  - Aktivitas
  - Riwayat

#### FR-003.6: Pipeline Edit
- All fields editable
- Stage change triggers validation
- DECLINED requires reason

### Acceptance Criteria
```gherkin
GIVEN RM membuat pipeline baru
WHEN RM memilih COB "Surety Bond"
THEN LOB dropdown hanya menampilkan LOB di bawah Surety Bond

GIVEN pipeline di stage P2
WHEN RM mengubah stage ke DECLINED
THEN modal muncul untuk input alasan decline

GIVEN pipeline di stage P1
WHEN RM mengubah stage ke ACCEPTED
THEN closed_at timestamp tercatat
```

---

## 📦 FR-004: Aktivitas Terjadwal (Scheduled Activities)

### Overview
| ID | FR-004 |
|-----|--------|
| **Priority** | P0 |
| **Roles** | RM |
| **Dependencies** | FR-002, FR-003 |

### Requirements

#### FR-004.1: Activity List (Pending Tab)
- Menampilkan aktivitas PLANNED
- Group by date (Today, Tomorrow, This Week, Upcoming)
- Show: Object name, type icon, time, status
- Quick actions: Execute, Reschedule, Cancel

#### FR-004.2: Activity Create (Schedule Mode)
- Form fields:
  - Object Type (CUSTOMER/HVC/BROKER/PIPELINE)
  - Object selection (based on type)
  - Activity Type (Visit/Call/Meeting/Proposal/Follow-up/Email/WhatsApp)
  - Date & Time (required)
  - Summary (optional, max 255 char)
  - Notes (optional)
- Save as **PLANNED** (is_immediate = false)

#### FR-004.3: Activity Execute
- Execute screen shows:
  - Activity summary
  - GPS capture status (auto, background)
  - Photo capture (optional)
  - Notes field (required for certain types)
- GPS captured silently in background
- Status changes to **COMPLETED**
- executed_at timestamp recorded

#### FR-004.4: Activity Reschedule
- Select new date/time
- Original activity marked as **RESCHEDULED**
- New activity created as **PLANNED**
- Link maintained: rescheduled_from_id, rescheduled_to_id

#### FR-004.5: Activity Cancel
- Confirm dialog
- Reason input (optional)
- Status changes to **CANCELLED**
- cancelled_at timestamp recorded

#### FR-004.6: Activity Types Configuration
| Type | Location Required | Photo Required | Notes Required |
|------|-------------------|----------------|----------------|
| Visit | Yes (Physical) | Optional | Yes |
| Call | No | No | Yes |
| Meeting | Yes (Physical/Virtual) | Optional | Yes |
| Proposal | No | No | No |
| Follow-up | No | No | Yes |
| Email | No | No | No |
| WhatsApp | No | No | No |

### Acceptance Criteria
```gherkin
GIVEN RM menjadwalkan visit ke customer
WHEN waktu visit tiba dan RM tap Execute
THEN GPS tercapture otomatis tanpa prompt user

GIVEN aktivitas sudah PLANNED
WHEN RM tidak bisa hadir dan tap Reschedule
THEN aktivitas lama menjadi RESCHEDULED
AND aktivitas baru terbuat dengan status PLANNED
```

---

## 📦 FR-005: Aktivitas Langsung (Immediate Activities)

### Overview
| ID | FR-005 |
|-----|--------|
| **Priority** | P0 |
| **Roles** | RM |
| **Dependencies** | FR-002, FR-003 |

### Requirements

#### FR-005.1: Immediate Activity Create
- Same form as FR-004.2 but:
  - "Mark as Done" button instead of "Schedule"
  - is_immediate = true
  - status = COMPLETED immediately
  - executed_at = now
- GPS captured at creation time

#### FR-005.2: Immediate Activity Use Cases
- Logging activity yang baru saja dilakukan
- Quick logging dari customer detail
- Logging via Quick Actions (Call/Email/WA)

#### FR-005.3: Scoring Bonus
- Immediate activities get +15% scoring bonus
- Encourages real-time logging

### Acceptance Criteria
```gherkin
GIVEN RM baru selesai meeting
WHEN RM membuat activity dengan "Mark as Done"
THEN activity langsung tersimpan sebagai COMPLETED
AND mendapat bonus scoring 15%
```

---

## 📦 FR-006: Dashboard & Scoreboard

### Overview
| ID | FR-006 |
|-----|--------|
| **Priority** | P0 |
| **Roles** | Semua User |
| **Dependencies** | FR-002, FR-003, FR-004, FR-005 |

### Requirements

#### FR-006.1: Personal Scoreboard
- Display:
  - Final Score (0-100)
  - Rank in Team/Branch/Region/Company
  - Lead Measures progress bars
  - Lag Measures progress bars
  - Bonus/Penalty points
  - Weekly trend chart

#### FR-006.2: Team Scoreboard (BH+ only)
- Leaderboard view of subordinates
- Sortable by score, lead, lag
- Drill-down to individual scorecards
- Team aggregate metrics

#### FR-006.3: Dashboard Home
- Scoreboard summary card
- Today's activities list
- Pipeline highlights (hot, won this week)
- Quick action buttons

#### FR-006.4: Score Calculation
```
Final Score = (Lead Score × 60%) + (Lag Score × 40%) + Bonuses - Penalties

Lead Score = Average(Lead Measure Achievements)
Lag Score = Average(Lag Measure Achievements)

Measure Achievement = (Actual / Target) × 100, capped at 150%
```

### Acceptance Criteria
```gherkin
GIVEN RM membuka Dashboard
WHEN data loaded
THEN scoreboard summary menampilkan score dan rank terkini

GIVEN BH membuka Team Scoreboard
WHEN melihat leaderboard
THEN semua RM di bawahnya tampil dengan score masing-masing
```

---

## 📦 FR-007: Target Assignment

### Overview
| ID | FR-007 |
|-----|--------|
| **Priority** | P0 |
| **Roles** | BH, BM, Admin |
| **Dependencies** | FR-006 |

### Requirements

#### FR-007.1: Target Setting by Period
- Select scoring period (weekly/monthly/quarterly)
- Set targets per subordinate per measure
- Bulk set dengan copy from template/previous period

#### FR-007.2: Target Cascade
- ROH sets target for BMs
- BM sets target for BHs  
- BH sets target for RMs
- Aggregate validation (child targets ≤ parent target)

#### FR-007.3: Target Measures
- Configurable per period
- Default Lead Measures:
  - Visit count
  - Call count
  - New customer count
  - New pipeline count
- Default Lag Measures:
  - Pipeline won count
  - Premium won (value)

### Acceptance Criteria
```gherkin
GIVEN BH ingin set target untuk RMs
WHEN BH membuka Target Assignment
THEN BH dapat set target per RM per measure

GIVEN BM sudah set aggregate target
WHEN BH set target individual
THEN sistem validasi bahwa total ≤ BM target
```

---

## 📦 FR-008: Cadence Meeting

### Overview
| ID | FR-008 |
|-----|--------|
| **Priority** | P0 |
| **Roles** | BH, BM, ROH |
| **Dependencies** | FR-006, FR-007 |

### Requirements

#### FR-008.1: Cadence Schedule
- Weekly cadence auto-generated
- Configurable day/time per level:
  - Team Cadence (BH hosts): Monday 09:00
  - Branch Cadence (BM hosts): Friday 09:00
  - Regional Cadence (ROH hosts): Monthly

#### FR-008.2: Pre-Meeting Form
- Each participant fills before meeting:
  - Q1: Komitmen minggu lalu (auto from previous Q4)
  - Q2: Apa yang tercapai?
  - Q3: Hambatan yang dihadapi?
  - Q4: Komitmen minggu depan?
- Submission deadline before meeting time
- Late submission penalty

#### FR-008.3: Meeting Execution
- Host opens meeting
- View all participant submissions
- Mark attendance
- Add BH notes per participant
- Complete meeting

#### FR-008.4: Attendance Scoring
- Attendance gives bonus points
- No-show gives penalty
- Late submission gives minor penalty

### Acceptance Criteria
```gherkin
GIVEN cadence meeting dijadwalkan
WHEN RM belum mengisi pre-meeting form 1 jam sebelum meeting
THEN notifikasi reminder dikirim

GIVEN BH sedang menjalankan cadence
WHEN BH mark attendance untuk RM yang hadir
THEN RM mendapat bonus points
```

---

## 📦 FR-009: HVC Management

### Overview
| ID | FR-009 |
|-----|--------|
| **Priority** | P1 |
| **Roles** | Admin (CRUD), RM (View) |
| **Dependencies** | FR-002 |

### Requirements

#### FR-009.1: HVC List (Admin)
- Full CRUD for HVC
- Search, filter, sort

#### FR-009.2: HVC View (RM)
- Read-only access
- Only see HVC linked to owned customers
- View HVC detail: name, type, address, key persons

#### FR-009.3: Customer-HVC Links
- Many-to-many relationship
- Link types: Holding, Subsidiary, Affiliate, JV, Tenant, Member, Supplier, Contractor, Distributor
- Admin can link/unlink customers

### Acceptance Criteria
```gherkin
GIVEN RM memiliki customer yang linked ke HVC
WHEN RM melihat customer detail
THEN badge HVC muncul dan dapat di-tap untuk lihat detail
```

---

## 📦 FR-010: Broker Management

### Overview
| ID | FR-010 |
|-----|--------|
| **Priority** | P1 |
| **Roles** | Admin (CRUD), All (View) |
| **Dependencies** | FR-003 |

### Requirements

#### FR-010.1: Broker List
- Admin: Full CRUD
- Others: View only, all brokers visible

#### FR-010.2: Broker as Lead Source
- Pipeline creation can select Broker as source
- Track pipelines originated from each Broker
- Broker performance metrics (filtered by user's pipelines)

#### FR-010.3: Broker Key Persons (PICs)
- Admin can add/edit Broker PICs
- Select PIC when creating pipeline from Broker

### Acceptance Criteria
```gherkin
GIVEN RM membuat pipeline dari referral broker
WHEN RM select lead source = Broker
THEN dropdown broker muncul untuk dipilih
```

---

## 📦 FR-011: Admin Panel

### Overview
| ID | FR-011 |
|-----|--------|
| **Priority** | P0 |
| **Roles** | Admin, Superadmin |
| **Dependencies** | - |

### Requirements

#### FR-011.1: User Management
- CRUD users
- Set role (RM/BH/BM/ROH/Admin)
- Set hierarchy (parent_id)
- Assign to branch/regional
- Activate/deactivate user

#### FR-011.2: Master Data Management
- CRUD for all reference tables:
  - Provinces, Cities
  - Company Types, Ownership Types, Industries
  - COB, LOB
  - Pipeline Stages, Pipeline Statuses
  - Lead Sources, Decline Reasons
  - Activity Types
  - HVC Types

#### FR-011.3: 4DX Configuration
- Manage Measure Definitions
- Configure Scoring Periods
- Set default weights

### Acceptance Criteria
```gherkin
GIVEN Admin menambah user baru
WHEN Admin set role=RM dan parent_id=BH
THEN user baru muncul di hierarchy BH tersebut
```

---

## 📦 FR-012: Notifications

### Overview
| ID | FR-012 |
|-----|--------|
| **Priority** | P1 |
| **Roles** | Semua User |
| **Dependencies** | Supabase Realtime |

### Requirements

#### FR-012.1: In-App Notifications
- Notification inbox/bell icon
- Categories: Activity, Pipeline, Score, System
- Mark as read/unread
- Delete/clear all

#### FR-012.2: Notification Types
| Event | Recipients |
|-------|------------|
| Activity reminder | Activity owner |
| Cadence reminder | Participants |
| Score update | User |
| Pipeline stage change | RM, BH |
| System announcement | All |

#### FR-012.3: Notification Preferences
- Toggle on/off per category
- Quiet hours setting

---

## 📦 FR-013: Reporting & Export

### Overview
| ID | FR-013 |
|-----|--------|
| **Priority** | P1 |
| **Roles** | BM, ROH, Admin |
| **Dependencies** | All data modules |

### Requirements

#### FR-013.1: Report Types
- Activity Report (by user, period)
- Pipeline Report (funnel, conversion)
- Score Report (leaderboard, trends)
- Customer Report (by region, industry)

#### FR-013.2: Export Options
- Excel (.xlsx)
- PDF
- CSV

---

## 📦 FR-014: Offline Mode

### Overview
| ID | FR-014 |
|-----|--------|
| **Priority** | P0 |
| **Roles** | Semua User |
| **Dependencies** | Local DB (Drift) |

### Requirements

#### FR-014.1: Full Offline Capability
- All read operations work offline
- All write operations work offline
- Data stored in local SQLite

#### FR-014.2: Sync Queue
- Changes queued when offline
- Auto-sync when online
- Queue visible in settings

#### FR-014.3: Conflict Resolution
- Server-wins with timestamp validation
- User notified of conflicts
- Manual resolution option

### Acceptance Criteria
```gherkin
GIVEN device offline
WHEN RM membuat customer baru
THEN customer tersimpan di local DB
AND sync queue bertambah

GIVEN sync queue ada pending items
WHEN device kembali online
THEN background sync berjalan
AND items ter-sync ke server
```

---

## 📦 FR-015: Riwayat (Audit Trail)

### Overview
| ID | FR-015 |
|-----|--------|
| **Priority** | P1 |
| **Roles** | Semua User |
| **Dependencies** | All data modules |

### Requirements

#### FR-015.1: History Display
- Timeline view on detail pages
- Show: action, user, timestamp, changes
- Sorted newest-first

#### FR-015.2: Tracked Actions
- CREATE, UPDATE, DELETE
- Stage/status changes
- Activity execution
- Key person changes

---

## 📊 Requirements Traceability Matrix

| FR ID | Priority | Module | Depends On | Related Stories |
|-------|----------|--------|------------|-----------------|
| FR-001 | P0 | Auth | - | US-000 |
| FR-002 | P0 | Customer | FR-001 | US-001 |
| FR-003 | P0 | Pipeline | FR-002 | US-002 |
| FR-004 | P0 | Activity | FR-002, FR-003 | US-003 |
| FR-005 | P0 | Activity | FR-002, FR-003 | US-003 |
| FR-006 | P0 | Dashboard | FR-002-005 | US-004 |
| FR-007 | P0 | Target | FR-006 | US-005 |
| FR-008 | P0 | Cadence | FR-006, FR-007 | US-006 |
| FR-009 | P1 | HVC | FR-002 | US-008, US-010 |
| FR-010 | P1 | Broker | FR-003 | US-009, US-011 |
| FR-011 | P0 | Admin | - | US-012, US-013 |
| FR-012 | P1 | Notification | Realtime | - |
| FR-013 | P1 | Report | All | US-007 |
| FR-014 | P0 | Offline | - | US-001-006 |
| FR-015 | P1 | Audit | All | - |

---

*Dokumen ini adalah bagian dari LeadX CRM PRD. Untuk user stories lengkap, lihat folder user-stories/.*
