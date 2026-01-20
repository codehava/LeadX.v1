# 📊 Executive Summary

## LeadX CRM - Sistem CRM Mobile-First untuk Tim Sales PT Askrindo

---

## 🎯 Ringkasan Proyek

**LeadX CRM** adalah aplikasi mobile-first yang dirancang khusus untuk mendigitalisasi dan mengoptimalkan aktivitas tim sales PT Askrindo (Persero) di seluruh Indonesia. Aplikasi ini mengimplementasikan framework **4 Disciplines of Execution (4DX)** untuk memastikan pencapaian target bisnis yang terukur dan akuntabel.

---

## ❓ Problem Statement

### Kondisi Saat Ini

Tim sales PT Askrindo tersebar di seluruh Indonesia dengan tantangan operasional berikut:

| Masalah | Dampak Bisnis |
|---------|---------------|
| Monitoring aktivitas sales tidak real-time | Management tidak dapat tracking harian, keputusan terlambat |
| Kesulitan tracking pipeline & konversi | Pipeline leakage, lost opportunities, revenue loss |
| Tidak ada sistem accountability terstruktur | Target tidak tercapai konsisten |
| Data tersebar dan tidak terintegrasi | Data duplication, inconsistency, reporting manual |
| Laporan manual dan tidak akurat | Decision making terhambat |

### Gap Analysis

```
┌─────────────────────────────────────────────────────────────────┐
│                      CURRENT STATE                               │
│  • Manual reporting via Excel                                    │
│  • Weekly/Monthly updates                                        │
│  • No GPS verification                                           │
│  • Scattered data sources                                        │
│  • No accountability framework                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                         [GAP]
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      DESIRED STATE                               │
│  • Real-time digital tracking                                    │
│  • Live dashboard & scoreboards                                  │
│  • GPS-verified field activities                                 │
│  • Centralized data platform                                     │
│  • 4DX accountability system                                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 💡 Solusi: LeadX CRM

### Value Proposition

| Kapabilitas | Deskripsi | Dampak |
|-------------|-----------|--------|
| **Real-time Activity Tracking** | GPS check-in untuk monitoring field work | Transparency & accountability |
| **Pipeline Management** | Terintegrasi dari lead hingga closing | Reduced pipeline leakage |
| **Framework 4DX** | Target setting & accountability terstruktur | Improved goal achievement |
| **Scoreboard** | Monitoring performa dan ranking real-time | Gamification & motivation |
| **Offline-Capable** | Full functionality tanpa koneksi internet | Field usability guaranteed |

### Key Differentiators

1. **Mobile-First Design** - Dioptimalkan untuk penggunaan di lapangan
2. **Offline-First Architecture** - Bekerja sempurna tanpa internet
3. **4DX Native** - Framework eksekusi built-in, bukan add-on
4. **GPS Silent Capture** - Auto-capture tanpa mengganggu user
5. **Hierarchical Visibility** - Data scoping otomatis per role

---

## 👥 Target Users

| Role | Jumlah | Peran Utama |
|------|--------|-------------|
| **Relationship Manager (RM)** | ~300 | Primary field user, customer CRUD, pipeline management |
| **Business Head (BH)** | ~50 | Team supervision, target setting, daily monitoring |
| **Branch Manager (BM)** | ~20 | Branch management, branch cadence |
| **Regional Office Head (ROH)** | ~5 | Regional supervision, strategic cadence |
| **Admin/Superadmin** | ~5 | System configuration, master data |
| **Total** | **~380** | |

### User Hierarchy

```
                    ┌─────────────────┐
                    │   SUPERADMIN    │  ← System-wide access
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │      ADMIN      │  ← Company-wide data
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
        ┌─────────┐    ┌─────────┐    ┌─────────┐
        │  ROH 1  │    │  ROH 2  │    │  ROH N  │  ← Regional scope
        └────┬────┘    └────┬────┘    └────┬────┘
             │              │              │
        ┌────┴────┐    ┌────┴────┐    ┌────┴────┐
        │ BM 1-3  │    │ BM 4-6  │    │ BM N    │  ← Branch scope
        └────┬────┘    └────┬────┘    └────┬────┘
             │              │              │
        ┌────┴────┐    ┌────┴────┐    ┌────┴────┐
        │BH 1-8   │    │BH 9-16  │    │BH N     │  ← Team scope
        └────┬────┘    └────┬────┘    └────┬────┘
             │              │              │
     ┌───────┴───────┐ ┌───────┴───────┐ ┌───────┴───────┐
     │RM 1-40        │ │RM 41-80       │ │RM N          │  ← Individual scope
     └───────────────┘ └───────────────┘ └───────────────┘
```

---

## 📈 Success Metrics

### Business KPIs

| Metric | Baseline | Target | Timeline | Improvement |
|--------|----------|--------|----------|-------------|
| Visit per RM/week | 5 | 10 | 6 bulan | +100% |
| Pipeline conversion rate | 25% | 40% | 6 bulan | +60% |
| Data accuracy | 60% | 95% | 3 bulan | +58% |
| Report timeliness | Manual | Real-time | 3 bulan | 100% |
| Daily active users (RM) | 0% | 80% | 6 bulan | +80% |

### Product KPIs

| Metric | Target |
|--------|--------|
| App load time | < 3 seconds |
| Offline sync reliability | > 99% |
| User satisfaction (NPS) | > 50 |
| System uptime | > 99% |

---

## 🚀 High-Level Scope

### In Scope (Phase 1)

| Module | Priority | Description |
|--------|----------|-------------|
| Authentication | P0 | Login, JWT, password management |
| Customer Management | P0 | CRUD customer + key persons |
| Pipeline Management | P0 | 6-stage pipeline tracking |
| Activity Scheduling | P0 | GPS check-in, visit tracking |
| Scoreboard 4DX | P0 | Lead/lag measures, ranking |
| Cadence Meeting | P0 | Weekly accountability |
| Admin Panel | P0 | User & master data management |
| Offline Mode | P0 | Full offline capability |
| HVC Management | P1 | High Value Customer tracking |
| Broker Management | P1 | Broker/agent reference |
| Notifications | P1 | In-app notifications |

### Out of Scope (Future Phases)

| Feature | Reason |
|---------|--------|
| Core Insurance System Integration | Phase 2 - requires separate integration project |
| Commission Calculation & Payment | Handled by existing finance system |
| Customer Self-Service Portal | Different product line |
| Email Marketing Automation | Different product category |
| Advanced AI/ML Predictions | Phase 3 - requires data maturity |

---

## 🏗️ Technology Overview

| Layer | Technology |
|-------|------------|
| **Mobile App** | Flutter 3.x (iOS + Android) |
| **Web Admin** | Flutter Web |
| **Backend** | Supabase (PostgreSQL + PostGIS) |
| **Auth** | Supabase GoTrue (JWT) |
| **Offline Storage** | Drift (SQLite) |
| **Real-time** | Supabase Realtime (WebSocket) |
| **File Storage** | Supabase Storage (S3) |

### Infrastructure Cost Estimate

| Service | Provider | Cost/Month |
|---------|----------|------------|
| Hosting | Supabase Pro (Singapore) | $25 |
| CDN | Cloudflare (Free) | $0 |
| Web Hosting | Cloudflare Pages | $0 |
| Monitoring | Sentry Free | $0 |
| **Total** | | **~$25/month** |

---

## 📅 Project Timeline

| Milestone | Target Week | Duration | Status |
|-----------|-------------|----------|--------|
| MVP Release | Week 12 | 12 weeks | ⏳ In Progress |
| 4DX Full Release | Week 20 | 8 weeks | ⏸️ Not Started |
| Full Feature | Week 26 | 6 weeks | ⏸️ Not Started |
| Go-Live | Week 30 | 4 weeks | ⏸️ Not Started |

---

## ⚠️ Key Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| User adoption rendah | Medium | High | Training intensif, gamification, change management |
| Offline sync issues | Medium | High | Extensive testing, conflict resolution strategy |
| Scope creep | High | Medium | Strict change control, clear boundaries |
| Performance issues | Low | Medium | Load testing, optimization |
| GPS accuracy in certain areas | Medium | Medium | Fallback mechanisms, manual override option |

---

## 📞 Project Contacts

| Role | Responsibility |
|------|----------------|
| **Project Sponsor** | Budget approval, strategic decisions |
| **IT Head** | Technical oversight, security compliance |
| **Sales Head** | User requirements, adoption strategy |
| **Project Manager** | Daily coordination, timeline management |

---

## 📚 Related Documents

| Document | Description |
|----------|-------------|
| [Vision and Goals](vision-and-goals.md) | Detailed vision & objectives |
| [Success Metrics](success-metrics.md) | KPI definitions & tracking |
| [Stakeholders](stakeholders.md) | Stakeholder analysis |
| [Functional Requirements](../02-requirements/functional-requirements.md) | Detailed requirements |

---

*Dokumen ini adalah ringkasan eksekutif. Untuk detail lengkap, silakan lihat dokumen terkait.*
