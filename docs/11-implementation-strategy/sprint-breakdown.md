# 📅 Sprint Breakdown

## Detailed Sprint Plan for 2 Developers

---

## 📋 Sprint Overview

| Sprint | Weeks | Focus | Dev 1 Focus | Dev 2 Focus |
|--------|-------|-------|-------------|-------------|
| 1 | 1-2 | Setup | DB, Supabase | Design System |
| 2 | 3-4 | Auth | Auth Logic | Auth UI |
| 3 | 5-6 | Foundation | Offline, Sync | Navigation, Base |
| 4 | 7-8 | Customer | Repository | Screens |
| 5 | 9-10 | Pipeline | Repository | Kanban UI |
| 6 | 11-12 | Pipeline+ | Stage Logic | Drag/Drop |
| 7 | 13-14 | Activity | Repository | Calendar UI |
| 8 | 15-16 | Activity+ | GPS, Logging | Execution Flow |
| 9 | 17-18 | 4DX | Score Logic | Scoreboard UI |
| 10 | 19-20 | Referral | Backend | UI Flow |
| 11 | 21-22 | RBAC | Policies | Admin UI |
| 12 | 23-24 | Polish | Integration | UX Polish |

---

## 🔵 Sprint 1: Project Setup (Week 1-2)

### Developer 1 Tasks
```
□ Initialize Flutter project
□ Setup Supabase project
□ Create database schema (tables)
□ Configure RLS policies (basic)
□ Setup environment files
□ Configure CI/CD
```

### Developer 2 Tasks
```
□ Setup design system (colors, typography)
□ Create base widgets library
□ Setup theme configuration
□ Create button components
□ Create input components
□ Create card components
```

### Sprint Goal
> Project foundation ready, developers can work independently

---

## 🔵 Sprint 2: Authentication (Week 3-4)

### Developer 1 Tasks
```
□ Implement Supabase auth service
□ Create auth repository
□ Implement session management
□ Create auth state (Riverpod)
□ Handle token refresh
□ Implement logout
```

### Developer 2 Tasks
```
□ Create splash screen
□ Create login screen
□ Create forgot password screen
□ Implement form validation UI
□ Create loading states
□ Create error states
```

### Integration Point
> Auth repository → Login screen integration

---

## 🔵 Sprint 3: Offline Foundation (Week 5-6)

### Developer 1 Tasks
```
□ Setup Drift local database
□ Create sync queue table
□ Implement connectivity check
□ Create base sync service
□ Implement conflict resolution (basic)
□ Create data repositories base class
```

### Developer 2 Tasks
```
□ Setup go_router navigation
□ Create app shell (bottom nav)
□ Create drawer navigation
□ Implement route guards
□ Create placeholder screens
□ Implement responsive layout base
```

### Sprint Goal
> Offline-capable foundation, navigation complete

---

## 🟢 Sprint 4: Customer Module (Week 7-8)

### Developer 1 Tasks
```
□ Create customers table sync
□ Implement customer repository
□ Create customer search logic
□ Implement customer filters
□ Create key_persons repository
□ Unit tests for repository
```

### Developer 2 Tasks
```
□ Create customer list screen
□ Implement search bar
□ Create filter bottom sheet
□ Create customer card widget
□ Implement infinite scroll
□ Create empty state
```

### Integration Point
> Customer repository → Customer list integration

---

## 🟢 Sprint 5: Customer Detail + Pipeline Start (Week 9-10)

### Developer 1 Tasks
```
□ Create customer detail fetch
□ Implement pipelines table sync
□ Create pipeline repository
□ Implement pipeline stages enum
□ Create pipeline filters
□ Unit tests
```

### Developer 2 Tasks
```
□ Create customer detail screen
□ Create tabs (Info, Pipelines, Activities)
□ Create key persons list
□ Create add key person form
□ Start pipeline list screen
□ Create pipeline card widget
```

---

## 🟢 Sprint 6: Pipeline Kanban (Week 11-12)

### Developer 1 Tasks
```
□ Implement stage transition logic
□ Create transition history
□ Implement stage validation rules
□ Create pipeline stats calculator
□ Implement weighted value calculation
□ Integration tests
```

### Developer 2 Tasks
```
□ Create kanban board layout
□ Implement horizontal scroll columns
□ Create drag & drop (ReorderableListView)
□ Stage change confirmation dialog
□ Implement pipeline filters
□ Create pipeline detail screen
```

### Sprint Goal
> Full pipeline management with kanban

---

## 🟡 Sprint 7: Activity Module (Week 13-14)

### Developer 1 Tasks
```
□ Create activities table sync
□ Implement activity repository
□ Create activity types config
□ Implement scheduling logic
□ Create reminders service
□ Implement local notifications
```

### Developer 2 Tasks
```
□ Create activity calendar view
□ Implement day/week/month view
□ Create activity markers
□ Create schedule activity form
□ Implement date/time picker
□ Create activity type selector
```

---

## 🟡 Sprint 8: Activity Execution (Week 15-16)

### Developer 1 Tasks
```
□ Implement GPS service
□ Create distance calculator
□ Implement GPS verification logic
□ Create override workflow
□ Implement photo upload
□ Create activity completion logic
```

### Developer 2 Tasks
```
□ Create activity execution screen
□ Implement GPS status indicator
□ Create notes input
□ Implement photo capture
□ Create completion confirmation
□ Implement success animation
```

### Sprint Goal
> Full activity management with GPS verification

---

## 🟠 Sprint 9: 4DX Scoreboard (Week 17-18)

### Developer 1 Tasks
```
□ Implement score calculation engine
□ Create lead/lag measure calculator
□ Implement bonus/penalty logic
□ Create weekly score aggregation
□ Implement ranking algorithm
□ Create score history tracking
```

### Developer 2 Tasks
```
□ Create personal scoreboard screen
□ Implement score gauge widget
□ Create progress bars
□ Create team leaderboard
□ Implement ranking cards
□ Create achievement badges
```

### Sprint Goal
> 4DX scoreboard fully functional

---

## 🔴 Sprint 10: Pipeline Referral (Week 19-20)

### Developer 1 Tasks
```
□ Create referral table
□ Implement referral workflow logic
□ Create approval chain
□ Implement notifications
□ Track referral status
□ Create referral bonus logic
```

### Developer 2 Tasks
```
□ Create refer pipeline form
□ Create RM selector
□ Create incoming referrals list
□ Implement accept/reject flow
□ Create referral status badges
□ Create referral history view
```

---

## 🔴 Sprint 11: Role & Permission (Week 21-22)

### Developer 1 Tasks
```
□ Implement role-permission tables
□ Create RLS policies per role
□ Implement permission checker
□ Create role hierarchy logic
□ Implement admin overrides
□ Security testing
```

### Developer 2 Tasks
```
□ Create admin settings screens
□ Create role management UI
□ Create permission matrix view
□ Create user role assignment
□ Implement conditional UI elements
□ Create permission denied screen
```

---

## 🔴 Sprint 12: Polish & Integration (Week 23-24)

### Developer 1 Tasks
```
□ End-to-end testing
□ Performance optimization
□ Sync optimization
□ Error handling review
□ Security audit
□ Documentation update
```

### Developer 2 Tasks
```
□ UX polish
□ Animation refinements
□ Loading states review
□ Empty states review
□ Error states review
□ Accessibility check
```

### Sprint Goal
> Production-ready release

---

## 📚 Related Documents

- [Team Assignment](team-assignment.md)
- [Dependency Map](dependency-map.md)
- [Sprint Planning](../09-implementation/sprint-planning.md)

---

*Sprint Breakdown - January 2025*
