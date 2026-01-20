# 📚 LeadX CRM Documentation

## Overview

Dokumentasi komprehensif untuk pengembangan **LeadX CRM** - aplikasi mobile-first untuk tim sales PT Askrindo (Persero) dengan implementasi framework **4 Disciplines of Execution (4DX)**.

---

## 📁 Struktur Dokumentasi

```
docs/
├── README.md                           # File ini
│
├── 01-overview/                        # Gambaran Umum Proyek
│   ├── executive-summary.md            # Ringkasan eksekutif
│   ├── vision-and-goals.md             # Visi, misi, dan tujuan
│   ├── success-metrics.md              # KPI dan metrik keberhasilan
│   └── stakeholders.md                 # Daftar stakeholder
│
├── 02-requirements/                    # Spesifikasi Kebutuhan
│   ├── functional-requirements.md      # Kebutuhan fungsional
│   ├── non-functional-requirements.md  # Kebutuhan non-fungsional
│   ├── user-stories/                   # User stories per role
│   │   ├── rm-stories.md               # RM user stories
│   │   ├── bh-stories.md               # BH user stories
│   │   ├── bm-stories.md               # BM user stories
│   │   ├── roh-stories.md              # ROH user stories
│   │   └── admin-stories.md            # Admin user stories
│   └── acceptance-criteria.md          # Kriteria penerimaan
│
├── 03-architecture/                    # Arsitektur Sistem
│   ├── system-architecture.md          # Arsitektur keseluruhan
│   ├── tech-stack.md                   # Technology stack
│   ├── offline-first-design.md         # Desain offline-first
│   ├── data-sync-strategy.md           # Strategi sinkronisasi data
│   └── security-architecture.md        # Arsitektur keamanan
│
├── 04-database/                        # Desain Database
│   ├── schema-overview.md              # Overview skema database
│   ├── entity-relationship.md          # ER Diagram & relasi
│   ├── tables/                         # Dokumentasi per tabel
│   │   ├── organization.md             # Tabel organisasi
│   │   ├── master-data.md              # Tabel master data
│   │   ├── business-data.md            # Tabel data bisnis
│   │   ├── scoring-4dx.md              # Tabel 4DX scoring
│   │   └── cadence.md                  # Tabel cadence
│   └── rls-policies.md                 # Row Level Security
│
├── 05-ui-ux/                           # Desain UI/UX
│   ├── design-system.md                # Design system (colors, typography)
│   ├── navigation-architecture.md      # Arsitektur navigasi
│   ├── screen-flows/                   # Flow per modul
│   │   ├── authentication.md           # Auth flow
│   │   ├── customer-module.md          # Customer flow
│   │   ├── pipeline-module.md          # Pipeline flow
│   │   ├── activity-module.md          # Activity flow
│   │   ├── scoreboard-module.md        # Scoreboard flow
│   │   └── cadence-module.md           # Cadence flow
│   └── responsive-design.md            # Responsive guidelines
│
├── 06-features/                        # Detail Fitur
│   ├── core/                           # Fitur inti (P0)
│   │   ├── authentication.md           # Login & auth
│   │   ├── customer-management.md      # Manajemen customer
│   │   ├── pipeline-management.md      # Manajemen pipeline
│   │   ├── activity-scheduling.md      # Penjadwalan aktivitas
│   │   ├── scoreboard.md               # Scoreboard 4DX
│   │   └── cadence-meeting.md          # Cadence meeting
│   ├── secondary/                      # Fitur sekunder (P1)
│   │   ├── hvc-management.md           # HVC management
│   │   ├── broker-management.md        # Broker management
│   │   └── notifications.md            # Notifikasi
│   └── admin/                          # Fitur admin
│       ├── user-management.md          # User management
│       └── master-data.md              # Master data
│
├── 07-4dx-framework/                   # Implementasi 4DX
│   ├── 4dx-overview.md                 # Overview framework 4DX
│   ├── wig-management.md               # WIG (Wildly Important Goals)
│   ├── lead-lag-measures.md            # Lead & Lag measures
│   ├── scoreboard-design.md            # Desain scoreboard
│   └── cadence-accountability.md       # Cadence of accountability
│
├── 08-benchmarks/                      # Benchmarking & Best Practices
│   ├── crm-benchmarks.md               # Benchmark aplikasi CRM
│   ├── mobile-ux-best-practices.md     # Best practices mobile UX
│   ├── offline-first-patterns.md       # Pattern offline-first
│   ├── 4dx-software-comparison.md      # Perbandingan software 4DX
│   └── competitive-analysis.md         # Analisis kompetitor
│
├── 09-implementation/                  # Panduan Implementasi
│   ├── project-timeline.md             # Timeline proyek
│   ├── sprint-planning.md              # Perencanaan sprint
│   ├── development-phases.md           # Fase pengembangan
│   ├── testing-strategy.md             # Strategi testing
│   └── deployment-guide.md             # Panduan deployment
│
├── 10-appendix/                        # Lampiran
│   ├── glossary.md                     # Glosarium istilah
│   ├── references.md                   # Referensi
│   ├── changelog.md                    # Log perubahan
│   └── faq.md                          # FAQ
│
└── assets/                             # Aset dokumentasi
    ├── diagrams/                       # Diagram
    ├── mockups/                        # Mockup UI
    └── images/                         # Gambar lainnya
```

---

## 🚀 Quick Links

| Kategori | Dokumen Utama |
|----------|---------------|
| **Memulai** | [Executive Summary](01-overview/executive-summary.md) |
| **Requirements** | [Functional Requirements](02-requirements/functional-requirements.md) |
| **Arsitektur** | [System Architecture](03-architecture/system-architecture.md) |
| **Database** | [Schema Overview](04-database/schema-overview.md) |
| **UI/UX** | [Design System](05-ui-ux/design-system.md) |
| **4DX** | [4DX Overview](07-4dx-framework/4dx-overview.md) |
| **Benchmarks** | [CRM Benchmarks](08-benchmarks/crm-benchmarks.md) |

---

## 📋 Dokumen Info

| Field | Nilai |
|-------|-------|
| **Produk** | LeadX CRM |
| **Klien** | PT Askrindo (Persero) |
| **Versi** | 2.0 |
| **Tanggal** | Januari 2025 |
| **Status** | In Development |

---

## 👥 Tim Kontributor

| Role | Responsibility |
|------|----------------|
| Product Owner | Definisi requirements & prioritas |
| Tech Lead | Arsitektur & technical decisions |
| UI/UX Designer | Desain interface & experience |
| Developer | Implementasi fitur |
| QA | Testing & quality assurance |

---

*Dokumentasi ini dikelola dengan prinsip "Living Documentation" - terus diperbarui seiring perkembangan proyek.*
