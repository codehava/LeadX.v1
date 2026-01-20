# 📅 Sprint Planning

## Perencanaan Sprint Detail LeadX CRM

---

## 📋 Overview

Dokumen ini berisi breakdown sprint untuk pengembangan LeadX CRM MVP menggunakan metodologi Scrum dengan sprint 2 minggu.

---

## 🗓️ Sprint Overview

| Sprint | Dates | Focus Area | Goal |
|--------|-------|------------|------|
| Sprint 0 | Week 1-2 | Setup & Foundation | Dev environment, project structure |
| Sprint 1 | Week 3-4 | Core Authentication | Login, logout, user management |
| Sprint 2 | Week 5-6 | Customer Module | CRUD customers, offline support |
| Sprint 3 | Week 7-8 | Pipeline Module | Pipeline stages, activities |
| Sprint 4 | Week 9-10 | Activity & GPS | Activity logging, GPS tracking |
| Sprint 5 | Week 11-12 | 4DX Scoreboard | Scoring, leaderboard |
| Sprint 6 | Week 13-14 | Cadence Module | Pre-meeting forms, attendance |
| Sprint 7 | Week 15-16 | Admin Panel | User mgmt, configuration |
| Sprint 8 | Week 17-18 | Integration & Polish | Sync, performance, bug fixes |
| Sprint 9 | Week 19-20 | UAT & Launch | Testing, deployment |
| Sprint 10 | Week 21-22 | Pipeline Referral | Cross-branch referral system |
| Sprint 11 | Week 23-24 | Role & Permission | Granular access control |
| Sprint 12 | Week 25-26 | Bulk Upload | Mass data import |

---

## 📊 Sprint 0: Foundation

**Goal**: Setup development environment and project foundation

### User Stories

| ID | Story | Points | Assignee |
|----|-------|--------|----------|
| S0-01 | Setup Flutter project with folder structure | 3 | Dev Lead |
| S0-02 | Configure Supabase project (dev) | 5 | Backend |
| S0-03 | Setup CI/CD pipeline | 5 | DevOps |
| S0-04 | Create base UI components | 5 | Frontend |
| S0-05 | Configure Drift local database | 3 | Backend |

**Capacity**: 21 points

### Definition of Done
- [ ] Flutter project runs on iOS, Android, Web
- [ ] Supabase connection established
- [ ] GitHub Actions pipeline working
- [ ] Base design system components created

---

## 📊 Sprint 1: Authentication

**Goal**: Implement secure authentication flow

### User Stories

| ID | Story | Points |
|----|-------|--------|
| S1-01 | Login screen UI | 3 |
| S1-02 | Supabase Auth integration | 5 |
| S1-03 | JWT token storage (secure) | 3 |
| S1-04 | Auto-refresh token logic | 5 |
| S1-05 | Logout functionality | 2 |
| S1-06 | Session persistence | 3 |

**Capacity**: 21 points

---

## 📊 Sprint 2: Customer Module

**Goal**: Complete customer CRUD with offline support

### User Stories

| ID | Story | Points |
|----|-------|--------|
| S2-01 | Customer list screen | 5 |
| S2-02 | Customer detail screen | 5 |
| S2-03 | Create customer form | 5 |
| S2-04 | Edit customer | 3 |
| S2-05 | Offline customer storage (Drift) | 5 |
| S2-06 | Customer search & filter | 5 |

**Capacity**: 28 points

---

## 📊 Sprint 3: Pipeline Module

**Goal**: Pipeline management with stage workflow

### User Stories

| ID | Story | Points |
|----|-------|--------|
| S3-01 | Pipeline list (Kanban view) | 8 |
| S3-02 | Create pipeline form | 5 |
| S3-03 | Pipeline detail screen | 5 |
| S3-04 | Stage transition logic | 5 |
| S3-05 | Pipeline offline storage | 5 |

**Capacity**: 28 points

---

## 📊 Sprint 4: Activity & GPS

**Goal**: Activity logging with GPS verification

### User Stories

| ID | Story | Points |
|----|-------|--------|
| S4-01 | Activity logging screen | 5 |
| S4-02 | GPS capture service | 8 |
| S4-03 | Photo attachment | 5 |
| S4-04 | Check-in/Check-out flow | 5 |
| S4-05 | Activity history view | 5 |

**Capacity**: 28 points

---

## 📊 Sprint 5-6: 4DX Module

**Goal**: Scoreboard and cadence implementation

### Sprint 5

| ID | Story | Points |
|----|-------|--------|
| S5-01 | Personal scoreboard UI | 8 |
| S5-02 | Lead measure calculation | 8 |
| S5-03 | Lag measure calculation | 8 |
| S5-04 | Team leaderboard | 5 |

### Sprint 6

| ID | Story | Points |
|----|-------|--------|
| S6-01 | Cadence schedule view | 5 |
| S6-02 | Pre-meeting form (Q1-Q4) | 8 |
| S6-03 | Attendance tracking | 5 |
| S6-04 | Score bonus/penalty | 5 |

---

## 📊 Sprint 7: Admin Panel

**Goal**: Web admin for configuration

### User Stories

| ID | Story | Points |
|----|-------|--------|
| S7-01 | Admin dashboard | 5 |
| S7-02 | User management CRUD | 8 |
| S7-03 | Role/permission config | 8 |
| S7-04 | 4DX measure configuration | 8 |

---

## 📊 Sprint 8: Integration

**Goal**: Polish and integration

### User Stories

| ID | Story | Points |
|----|-------|--------|
| S8-01 | Sync queue optimization | 8 |
| S8-02 | Performance optimization | 5 |
| S8-03 | Bug fixes from testing | 8 |
| S8-04 | RLS policy testing | 5 |

---

## 📊 Sprint 9: UAT & Launch

**Goal**: User acceptance testing and production deployment

### Tasks

| ID | Task | Owner |
|----|------|-------|
| S9-01 | UAT with pilot users | QA |
| S9-02 | Bug fixes from UAT | Dev |
| S9-03 | Production deployment | DevOps |
| S9-04 | User training materials | PM |
| S9-05 | Go-live support | All |

---

## 📊 Sprint 10: Pipeline Referral

**Goal**: Cross-branch referral system

### User Stories

| ID | Story | Points |
|----|-------|--------|
| S10-01 | Create referral form UI | 5 |
| S10-02 | Referral API endpoints | 8 |
| S10-03 | Incoming referrals list (receiver) | 5 |
| S10-04 | Accept/Reject workflow | 5 |
| S10-05 | BM approval queue | 5 |
| S10-06 | Referral bonus calculation | 5 |
| S10-07 | Notification integration | 3 |

**Capacity**: 36 points

### Definition of Done
- [ ] RM can create referral to another RM
- [ ] Receiver can accept/reject referral
- [ ] BM can approve accepted referrals
- [ ] Pipeline created upon approval
- [ ] Bonus applied when pipeline WON

---

## 📊 Sprint 11: Role & Permission

**Goal**: Granular access control system

### User Stories

| ID | Story | Points |
|----|-------|--------|
| S11-01 | Roles management UI (Admin) | 8 |
| S11-02 | Permission matrix UI | 8 |
| S11-03 | Custom role creation | 5 |
| S11-04 | User-role assignment | 5 |
| S11-05 | Permission validation middleware | 8 |
| S11-06 | Permission caching | 5 |

**Capacity**: 39 points

### Definition of Done
- [ ] Admin can view all roles
- [ ] Admin can create custom roles
- [ ] Permissions assignable per role
- [ ] RLS enforces scope-based access
- [ ] Permissions cached per session

---

## 📊 Sprint 12: Bulk Upload

**Goal**: Mass data import capability

### User Stories

| ID | Story | Points |
|----|-------|--------|
| S12-01 | Template download endpoint | 3 |
| S12-02 | File upload UI (Admin) | 5 |
| S12-03 | HVC bulk upload processor | 8 |
| S12-04 | Broker bulk upload processor | 8 |
| S12-05 | Validation preview screen | 8 |
| S12-06 | Error report generation | 5 |

**Capacity**: 37 points

### Definition of Done
- [ ] Admin can download templates
- [ ] File upload with progress
- [ ] Preview with error highlighting
- [ ] Batch insert with transaction
- [ ] Error report downloadable

---

## 📚 Related Documents

- [Project Timeline](project-timeline.md)
- [Development Phases](development-phases.md)
- [Testing Strategy](testing-strategy.md)

---

*Dokumen ini adalah bagian dari LeadX CRM Implementation Documentation.*
