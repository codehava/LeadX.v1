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
| Branch Manager (BM) | ~20 | Branch management, HVC/Broker assignment |
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
| **BM** | 2 | Branch Manager | Branch management, HVC/Broker assignment, branch cadence |
| **BH** | 3 | Business Head | Team supervision, target setting, daily monitoring, team cadence |
| **RM** | 4 | Relationship Manager | Customer CRUD, pipeline management, visit execution, activity logging |

### User Stories

| ID | Sebagai... | Saya ingin... | Agar... | Prioritas |
|----|------------|---------------|---------|-----------|
| US-001 | RM | menambah dan mengelola data customer | data prospek terdigitalisasi | P0 |
| US-002 | RM | membuat dan tracking pipeline | dapat memonitor peluang bisnis | P0 |
| US-003 | RM | menjadwalkan dan melakukan check-in kunjungan | aktivitas lapangan tertrack | P0 |
| US-004 | RM | melihat scoreboard dan ranking | mengetahui performa saya | P0 |
| US-005 | BH | mengassign target ke RM | target individual ter-set | P0 |
| US-006 | BH | melakukan cadence meeting | accountability terjaga | P0 |
| US-007 | BM | memonitor performa cabang | visibility terhadap team | P0 |
| US-008 | BM | mengassign HVC/Broker ke RM | distribusi resource teratur | P1 |
| US-009 | Admin | mengkonfigurasi parameter sistem | sistem sesuai kebutuhan bisnis | P0 |
| US-010 | Admin | mengelola user dan hierarchy | struktur organisasi ter-manage | P0 |

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
| **FR-009** | HVC Management | Admin | P1 | Admin-only CRUD, key persons, visibility based on customer ownership |
| **FR-010** | Broker/Agent Management | Admin | P1 | Admin-only CRUD, visible to all users, used as Pipeline lead source |
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
