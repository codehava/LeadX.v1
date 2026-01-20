# 👥 Developer Team Assignment

## Optimal Work Distribution for 2 Developers

---

## 🎯 Assignment Strategy

Pembagian didasarkan pada prinsip:
1. **Minimize dependencies** - Kurangi blocking antar developer
2. **Parallel work streams** - Maksimalkan pekerjaan paralel
3. **Specialization** - Sesuai keahlian masing-masing
4. **Clear ownership** - Tanggung jawab jelas per fitur

---

## 👨‍💻 Developer Profiles

### Developer 1: Backend & Core Logic
**Focus**: Database, API, Business Logic, Offline-First

**Skills Required**:
- Flutter (Riverpod, Drift)
- Supabase (PostgreSQL, RLS)
- State management
- Offline-first architecture

### Developer 2: Frontend & UI/UX
**Focus**: UI Components, Screens, Navigation, User Experience

**Skills Required**:
- Flutter UI development
- Design system implementation
- Responsive design
- Animation & micro-interactions

---

## 📊 Feature Assignment Matrix

### Phase 1: Foundation (Sprint 1-3)

| Feature | Dev 1 | Dev 2 | Notes |
|---------|-------|-------|-------|
| Project setup | ✅ | ✅ | Collaborate |
| Database schema | ✅ | | Dev 1 owns |
| Supabase config | ✅ | | Dev 1 owns |
| Design system | | ✅ | Dev 2 owns |
| Auth backend | ✅ | | Dev 1 owns |
| Auth UI | | ✅ | Dev 2 owns |
| Navigation setup | | ✅ | Dev 2 owns |
| Offline DB setup | ✅ | | Dev 1 owns |

### Phase 2: Core Features (Sprint 4-6)

| Feature | Dev 1 | Dev 2 | Notes |
|---------|-------|-------|-------|
| Customer repository | ✅ | | Backend |
| Customer UI screens | | ✅ | UI |
| Customer search/filter | ✅ | | Logic |
| Pipeline repository | ✅ | | Backend |
| Pipeline Kanban UI | | ✅ | Complex UI |
| Pipeline drag-drop | | ✅ | UI interaction |
| Stage transition logic | ✅ | | Business rules |
| Key person CRUD | ✅ | ✅ | Split |

### Phase 3: Activity & 4DX (Sprint 7-9)

| Feature | Dev 1 | Dev 2 | Notes |
|---------|-------|-------|-------|
| Activity repository | ✅ | | Backend |
| Activity calendar UI | | ✅ | Complex UI |
| GPS verification | ✅ | | Native integration |
| Activity logging flow | | ✅ | UI flow |
| Score calculation | ✅ | | Complex logic |
| Scoreboard UI | | ✅ | Charts, animations |
| Leaderboard | | ✅ | UI |
| 4DX config backend | ✅ | | Admin |

### Phase 4: Advanced (Sprint 10-12)

| Feature | Dev 1 | Dev 2 | Notes |
|---------|-------|-------|-------|
| Referral logic | ✅ | | Business rules |
| Referral UI | | ✅ | Flow UI |
| Role permission backend | ✅ | | RLS, policies |
| Role management UI | | ✅ | Admin UI |
| Bulk upload backend | ✅ | | File processing |
| Bulk upload UI | | ✅ | Progress UI |
| Cadence backend | ✅ | | Scheduling |
| Cadence UI | | ✅ | Meeting flow |

---

## 📅 Weekly Parallel Work

```
Week N Example:
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│  DEVELOPER 1 (Backend)         │  DEVELOPER 2 (Frontend)                   │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                │                                            │
│  Mon: Customer repository      │  Mon: Design system components            │
│  Tue: Customer search logic    │  Tue: Customer list screen                │
│  Wed: Pipeline repository      │  Wed: Customer detail screen              │
│  Thu: Stage transition rules   │  Thu: Pipeline kanban layout              │
│  Fri: API integration tests    │  Fri: Pipeline card components            │
│                                │                                            │
│  ─────────────────────────────────────────────────────────────────────────  │
│  HANDOFF: Repository ready  ─────────────────▶  UI can consume            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Collaboration Points

### Daily Sync
- 15 min standup
- Review PRs
- Unblock issues

### Sprint Planning
- Define interfaces first
- Agree on data models
- Set integration points

### Integration Days
- Every Friday: Integration testing
- Fix breaking changes
- Demo to stakeholder

---

## 📊 Workload Balance

### Sprint 1-3 Estimate

| Developer | Tasks | Effort |
|-----------|-------|--------|
| Dev 1 | 8 tasks | ~40 hours |
| Dev 2 | 7 tasks | ~40 hours |

### Sprint 4-6 Estimate

| Developer | Tasks | Effort |
|-----------|-------|--------|
| Dev 1 | 6 tasks | ~45 hours |
| Dev 2 | 7 tasks | ~45 hours |

---

## ⚠️ Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Blocking dependencies | Define interfaces early |
| Knowledge silo | Weekly knowledge sharing |
| Uneven workload | Flexible task reassignment |
| Integration issues | Daily PR reviews |

---

## 📚 Related Documents

- [Sprint Breakdown](sprint-breakdown.md)
- [Dependency Map](dependency-map.md)

---

*Team Assignment - January 2025*
