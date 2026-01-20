# LeadX CRM - Product Requirements Document (PRD)
## Part 1: Overview, Users & Requirements

---

## Informasi Dokumen

| Field | Nilai |
|-------|-------|
| Nama Produk | LeadX CRM - PT Askrindo (Persero) |
| Pemilik Dokumen | PT Askrindo (Persero) |
| Tanggal Dibuat | Januari 2025 |
| Terakhir Diperbarui | Januari 2025 |
| Versi | 2.0 |
| Status | Draft / Dalam Review |

### Dokumen Terkait

| Dokumen | Link | Tujuan |
|---------|------|--------|
| PRD Part 2 | [PRD_Part2_Architecture_Technical.md](./PRD_Part2_Architecture_Technical.md) | Arsitektur & Technical Stack |
| PRD Part 3 | [PRD_Part3_UI_Implementation_Planning.md](./PRD_Part3_UI_Implementation_Planning.md) | UI/UX, Timeline, & Implementasi |
| Database Schema | [schema_v2.sql](../HANDOVER_DOCS/schema_v2.sql) | Struktur database |
| Offline Sync | [OFFLINE_SYNC_ARCHITECTURE.md](../HANDOVER_DOCS/OFFLINE_SYNC_ARCHITECTURE.md) | Arsitektur offline sync |

### Persetujuan

| Jabatan | Nama | Tanggal |
|---------|------|---------|
| Project Sponsor | | |
| IT Head | | |
| Sales Head | | |
| Project Manager | | |

---

## 1. Ringkasan Eksekutif

### Deskripsi Tujuan Aplikasi

PT Askrindo sebagai perusahaan asuransi terkemuka membutuhkan sistem CRM modern untuk mengelola aktivitas tim sales yang tersebar di seluruh Indonesia. **LeadX CRM** adalah aplikasi mobile-first yang mengimplementasikan framework **4 Disciplines of Execution (4DX)** untuk memastikan pencapaian target bisnis yang terukur dan akuntabel.

Aplikasi ini mendigitalisasi seluruh proses sales dari:
- Customer prospecting & management
- Pipeline tracking (NEW → P3 → P2 → P1 → WON/LOST)
- **High Value Customer (HVC)** management dengan key persons
- **Broker/Agent** tracking sebagai lead source pipeline
- Kunjungan lapangan dengan GPS tracking
- Cadence meeting untuk accountability 4DX
- Real-time scoreboard & performance ranking

### Nilai Utama Aplikasi

| Kapabilitas | Deskripsi |
|-------------|-----------|
| **Real-time Activity Tracking** | GPS check-in untuk monitoring field work |
| **Pipeline Management** | Terintegrasi dari lead hingga closing |
| **Framework 4DX** | Target setting & accountability terstruktur |
| **Scoreboard** | Monitoring performa dan ranking real-time |
| **Offline-Capable** | Full functionality tanpa koneksi internet |

### Target User

| User | Jumlah | Peran Utama |
|------|--------|-------------|
| Relationship Manager (RM) | ~300 | Primary field user, customer CRUD, pipeline |
| Business Head (BH) | ~50 | Team supervision, target setting |
| Branch Manager (BM) | ~20 | Branch management, branch cadence |
| Regional Office Head (ROH) | ~5 | Regional supervision, strategic cadence |
| Admin/Superadmin | ~5 | System configuration |

---

## 2. Pernyataan Masalah

### Kondisi Saat Ini

Tim sales PT Askrindo tersebar di seluruh Indonesia dengan monitoring yang masih manual dan tidak real-time. Pain points utama:

| Masalah | Dampak |
|---------|--------|
| Monitoring aktivitas sales tidak real-time | Management tidak bisa tracking harian |
| Kesulitan tracking pipeline dan konversi | Pipeline leakage, lost opportunities |
| Tidak ada sistem accountability terstruktur | Target tidak tercapai konsisten |
| Data tersebar dan tidak terintegrasi | Data duplication, inconsistency |
| Laporan manual dan tidak akurat | Decision making terhambat |

### Target Dampak

| Metric | Current | Target | Improvement |
|--------|---------|--------|-------------|
| Visit per RM/week | ~5 | 10 | +100% |
| Pipeline conversion | ~25% | 40% | +60% |
| Data accuracy | ~60% | 95% | +58% |
| Report timeliness | Manual | Real-time | 100% |

---

## 3. Goals & Metrik Keberhasilan

### Tujuan Bisnis

| Goals | Metrik | Baseline | Target | Timeline |
|-------|--------|----------|--------|----------|
| Meningkatkan produktivitas sales | Visit per RM/week | 5 | 10 | 6 bulan |
| Meningkatkan konversi pipeline | Pipeline conversion rate | 25% | 40% | 6 bulan |
| Digitalisasi data | Data accuracy | 60% | 95% | 3 bulan |
| Management visibility | Report timeliness | Manual | Real-time | 3 bulan |
| User adoption | Daily active users (RM) | 0% | 80% | 6 bulan |

### Goals User

| Role | Goals |
|------|-------|
| RM | Mengelola customer, pipeline, dan jadwal kunjungan dengan mudah |
| BH/BM | Memonitor performa tim dan melakukan cadence meeting |
| Management | Visibility real-time terhadap pipeline dan aktivitas sales |

### Non-Goals (Di Luar Cakupan)

> **PENTING**: Berikut fitur yang TIDAK akan ditangani proyek ini:

- ❌ Integration dengan Core Insurance System (phase 2)
- ❌ Commission calculation & payment
- ❌ Customer self-service portal
- ❌ Email marketing automation
- ❌ Advanced AI/ML predictions

---

## 4. User & Stakeholder

### Daftar Role User

| Role | Level | Deskripsi | Kemampuan Utama |
|------|-------|-----------|-----------------|
| **Superadmin** | 0 | IT Administrator | Full system access, user management, system configuration |
| **Admin** | 0 | Management/HQ staff | Master data, parameter configuration, company-wide reports |
| **ROH** | 1 | Regional Office Head | Regional monitoring, strategic decisions, regional cadence |
| **BM** | 2 | Branch Manager | Branch management, branch cadence, regional coordination |
| **BH** | 3 | Business Head | Team supervision, target setting, daily monitoring, team cadence |
| **RM** | 4 | Relationship Manager | Customer CRUD, pipeline management, visit execution, activity logging |

### User Stories

---

#### US-001: Customer Management (RM) — P0

**Budi** adalah seorang Relationship Manager (RM) di cabang Jakarta yang baru saja pulang dari kunjungan ke prospek baru. Sambil duduk di kafe, dia membuka LeadX di HP-nya dan menambahkan data customer baru: PT Maju Jaya, sebuah perusahaan konstruksi di daerah industrial Cikarang. Meskipun koneksi internet lemah, data tersimpan di local dan akan sync otomatis ketika online. GPS location tercapture otomatis di background tanpa mengganggu Budi.

**Acceptance:** CRUD customer + key persons, search/filter, GPS auto-capture, offline sync.

---

#### US-002: Pipeline Tracking (RM) — P0

Setelah meeting pertama dengan PT Maju Jaya, **Budi** membuat pipeline baru di LeadX. Dia memilih customer, memasukkan nilai potensial Rp 500 juta untuk produk Surety Bond, dan pipeline otomatis masuk ke stage NEW (10%). Setiap minggu, seiring progres negosiasi, Budi menggeser stage dari P3 → P2 → P1 hingga akhirnya WON. LeadX mencatat seluruh journey ini.

**Acceptance:** Pipeline linked to customer, stage progression (NEW→P3→P2→P1→WON/LOST), value tracking.

---

#### US-003: Activity Scheduling & Check-in (RM) — P0

**Budi** menjadwalkan kunjungan ke PT Maju Jaya untuk Selasa depan jam 10:00. Saat tiba di lokasi, dia membuka LeadX dan tap "Check-in". GPS tercapture otomatis sebagai bukti kehadiran. Setelah meeting, dia menambahkan notes dan foto dokumen. Jika ada halangan, dia bisa reschedule dengan alasan.

**Acceptance:** Planned activity, GPS check-in, multi-type (Visit/Call/Meeting), reschedule/cancel.

---

#### US-004: Scoreboard & Ranking (RM) — P0

Setiap pagi, **Budi** mengecek scoreboard-nya di LeadX. Dia melihat score 78/100 minggu ini, ranking #5 dari 20 RM di cabangnya. Progress bar menunjukkan dia sudah mencapai 80% target kunjungan dan 60% target pipeline. Trend chart menunjukkan peningkatan dari minggu lalu.

**Acceptance:** Personal score card, peer ranking, weekly trend, 4DX progress bars.

---

#### US-005: Target Assignment (BH) — P0

**Ibu Sari** adalah Business Head yang membawahi 8 RM. Di awal bulan, dia login ke LeadX dan assign target ke setiap RM: 10 kunjungan/minggu, 5 pipeline baru/bulan, Rp 2M total pipeline value. Dia bisa copy target dari bulan lalu dan adjust. Setiap RM langsung melihat target mereka di dashboard.

**Acceptance:** Set lead/lag measures per RM, copy template, cascade targets.

---

#### US-006: Cadence Meeting (BH) — P0

Setiap Senin pagi, **Ibu Sari** menjalankan cadence meeting dengan tim-nya. Sebelum meeting, setiap RM mengisi pre-meeting form: apa yang dikomitmenkan minggu lalu dan hasilnya. Saat meeting, LeadX menampilkan summary per RM. Di akhir, komitmen baru tercatat dan attendance ter-track untuk scoring.

**Acceptance:** Weekly cadence, pre-meeting form, attendance tracking, commitment log.

---

#### US-007: Branch Monitoring (BM) — P0

**Pak Rahmat** adalah Branch Manager cabang Jakarta. Dia membuka LeadX dan melihat dashboard cabang: total score 82/100, ranking #3 dari 12 cabang se-regional. Dia drill-down ke performance tiap BH dan RM di bawahnya. Dia identify bahwa team BH Sari perform paling baik, sementara team BH Andi perlu coaching.

**Acceptance:** Aggregated branch scores, drill-down to individuals, branch ranking.

---

#### US-008: HVC Visibility (RM) — P1

**Budi** sedang mengerjakan customer PT Maju Jaya ketika dia melihat badge "HVC" di detail customer. Dia tap badge tersebut dan melihat bahwa PT Maju Jaya ter-link ke **Bank BNI** sebagai High Value Customer. Dia bisa lihat key persons Bank BNI dan memahami bahwa PT Maju Jaya adalah vendor penting bagi Bank BNI. Informasi ini membantu Budi approach dengan strategy berbeda. Budi **hanya bisa melihat** HVC yang terhubung dengan customer-nya — tidak bisa edit.

**Acceptance:** View HVC linked to owned customers, see HVC details + key persons, **read-only access**.

---

#### US-009: Broker as Lead Source (RM) — P1

Saat membuat pipeline baru, **Budi** diminta memilih "Lead Source". Salah satu opsinya adalah Broker. Dia memilih **Broker PT Asuransi Partner** karena referral datang dari sana. LeadX mencatat source ini dan nantinya management bisa track berapa banyak business yang datang dari masing-masing Broker. Budi bisa lihat list semua Broker, tapi **tidak bisa edit** data Broker.

**Acceptance:** View Broker list, select as pipeline lead source, track pipelines by Broker, **read-only access**.

---

#### US-010: HVC Management (Admin) — P1

**Mas Deni** dari tim Admin HQ menerima data HVC baru dari management: **Bank Mandiri** adalah High Value Customer baru dengan 3 key persons. Dia login ke LeadX Admin Panel dan create HVC baru. Kemudian dia link Bank Mandiri ke 15 customer yang merupakan vendor-vendor Bank Mandiri. Sekarang semua RM yang handle customer tersebut bisa melihat bahwa customer mereka terhubung dengan Bank Mandiri.

**Acceptance:** Full CRUD HVC + key persons, link to multiple customers (many-to-many), manage HVC types.

---

#### US-011: Broker Management (Admin) — P1

Management menginformasikan bahwa **PT Broker Sejahtera** adalah partner referral baru. **Mas Deni** menambahkan Broker baru ke sistem dengan contact info lengkap. Ketika Broker tersebut resign dari partnership, Deni tidak menghapus data (karena ada history pipeline), tapi me-nonaktifkan Broker tersebut sehingga tidak muncul di dropdown lagi.

**Acceptance:** Full CRUD Broker, manage types, view originated pipelines, soft delete.

---

#### US-012: System Configuration (Admin) — P0

**Mas Deni** perlu menambahkan LOB baru "Asuransi Syariah" ke sistem. Dia buka Admin Panel → Master Data → LOB dan create entry baru. Dia juga configure 4DX measure definitions untuk periode Q2, menyesuaikan scoring parameters sesuai arahan management.

**Acceptance:** Manage master data, configure 4DX measures, scoring parameters.

---

#### US-013: User & Hierarchy Management (Admin) — P0

Ada RM baru bernama **Andi** yang join cabang Jakarta. **Mas Deni** create user account untuk Andi, assign role RM, dan set hierarchy: report ke BH Sari di cabang Jakarta, regional Jakarta Raya. Andi langsung bisa login dan melihat target-nya.

**Acceptance:** CRUD users, set hierarchy ROH→BM→BH→RM, assign to branch/regional.

### Analisis Stakeholder

| Stakeholder | Kepentingan | Tingkat Keterlibatan |
|-------------|-------------|----------------------|
| Project Sponsor | Budget approval, strategic decisions | Tinggi |
| IT Head | Technical oversight, security | Tinggi |
| Sales Head | User requirements, adoption | Tinggi |
| Change Champion | User adoption, training | Sedang |
| QA Lead | Testing strategy, quality | Sedang |

---

## 5. Requirements Fungsional

| ID | Fitur | Role User | Prioritas | Kriteria Penerimaan |
|----|-------|-----------|-----------|---------------------|
| **FR-001** | Authentication & Login | Semua User | P0 | User dapat login dengan email/password, JWT token management, password reset |
| **FR-002** | Customer Management | RM, Admin | P0 | CRUD customer, key persons, GPS location auto-capture, search & filter |
| **FR-003** | Pipeline Management | RM, Admin | P0 | CRUD pipeline, 6-stage tracking (NEW→P3→P2→P1→WON/LOST), lead source, value tracking |
| **FR-004** | Aktivitas Terjadwal | RM | P0 | Create planned activity, GPS check-in, photo capture, execute/cancel/reschedule |
| **FR-005** | Aktivitas Langsung | RM | P0 | Log immediate activity (langsung COMPLETED), multi-object support, notes & attachment |
| **FR-006** | Dashboard/Scoreboard | Semua User | P0 | Personal score, ranking, progress bars, weekly trend, 4DX metrics |
| **FR-007** | Target Assignment | BH, BM, Admin | P0 | Set lead/lag measures, copy templates, cascade targets to subordinates |
| **FR-008** | Cadence Meeting | BH, BM | P0 | Schedule, pre-meeting form, execution, commitment tracking, attendance scoring |
| **FR-009** | HVC Management | Admin, RM (view) | P1 | Admin-only CRUD, key persons, RM can view HVC linked to their customers |
| **FR-010** | Broker/Agent Management | Admin, RM (view) | P1 | Admin-only CRUD, visible to all users as Pipeline lead source reference |
| **FR-011** | Admin Panel | Admin | P0 | User management, master data, configuration, all CRUD operations |
| **FR-012** | Notifications | Semua User | P1 | In-app notifications via Supabase Realtime, preferences, inbox |
| **FR-013** | Reporting & Export | BM, ROH, Admin | P1 | Various reports, Excel/PDF export |
| **FR-014** | Offline Mode | RM | P0 | Full read/write offline capability, automatic queue sync, conflict resolution |
| **FR-015** | Riwayat (History) | Semua User | P1 | View audit trail on detail pages, timeline display sorted newest-first |

### Detail Modul Aktivitas (Unified)

Sistem aktivitas terpadu menggabungkan jadwal kunjungan dan log aktivitas:

| Aspek | Detail |
|-------|--------|
| **Tipe** | Scheduled (rencana) atau Immediate (langsung selesai) |
| **Object** | Customer, HVC, Broker, atau Pipeline |
| **Jenis Aktivitas** | Visit, Call, Meeting, Proposal, Follow-up, Email, WhatsApp |

**Status Workflow:**
```
PLANNED → COMPLETED | CANCELLED | RESCHEDULED
         ↑
         └── Immediate (langsung COMPLETED)
```

**GPS Auto-Capture:**
- GPS coordinates captured automatically in background
- User NOT prompted for location - happens silently
- If GPS unavailable, store null and continue (don't block user)

### Detail Pipeline Stages

```
┌─────┐    ┌─────┐    ┌─────┐    ┌─────┐    ┌─────────┐
│ NEW │ →  │ P3  │ →  │ P2  │ →  │ P1  │ →  │ACCEPTED │
│     │    │Cold │    │Warm │    │Hot  │    │   Won   │
│ 10% │    │ 25% │    │ 50% │    │ 75% │    │  100%   │
└─────┘    └─────┘    └─────┘    └─────┘    └─────────┘
               │                      │
               └──────────────────────┴──→ ┌─────────┐
                                           │DECLINED │
                                           │  Lost   │
                                           │   0%    │
                                           └─────────┘
```

---

## 6. Requirements Non-Fungsional

| Kategori | Kebutuhan | Detail |
|----------|-----------|--------|
| **Performance** | Waktu muat halaman < 3 detik | Target load time untuk semua screen |
| **Keamanan** | JWT Authentication + RLS | Row Level Security untuk data isolation per user |
| **Skalabilitas** | Mendukung 400 User bersamaan | Single Supabase instance (Pro plan) |
| **Reliability** | Uptime 99% | Supabase managed infrastructure |
| **Offline** | Full offline support | Drift/SQLite untuk local storage |
| **Sync** | Background sync | Queue-based sync dengan conflict resolution (server wins) |
| **Geolocation** | GPS auto-capture | Silent background capture, no user prompts |

---

## PRD Checklist Part 1

- [x] Masalah didefinisikan dengan jelas disertai data
- [x] User stories memiliki kriteria penerimaan
- [x] Non-goals dinyatakan secara eksplisit
- [x] Metrik keberhasilan dapat diukur
- [x] Semua user roles dan permissions didefinisikan
- [x] Requirements fungsional lengkap dengan prioritas

---

*Lanjut ke: [PRD Part 2 - Architecture & Technical](./PRD_Part2_Architecture_Technical.md)*
