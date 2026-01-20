# ⚙️ Non-Functional Requirements

## Spesifikasi Kebutuhan Non-Fungsional LeadX CRM

---

## 📋 Overview

Dokumen ini mendeskripsikan kebutuhan non-fungsional (NFR) yang harus dipenuhi LeadX CRM untuk memastikan kualitas, keamanan, dan kehandalan sistem.

---

## 🚀 Performance Requirements

### NFR-001: Response Time

| Metric | Target | Condition |
|--------|--------|-----------|
| App launch (cold start) | < 3 seconds | Standard device, cached data |
| App launch (warm start) | < 1 second | App in background |
| Screen navigation | < 300ms | Within app |
| List loading | < 1 second | 50 items, online |
| Search results | < 500ms | Local search |
| Form submission | < 2 seconds | Online, sync |
| Offline data access | < 100ms | All read operations |

### NFR-002: Throughput

| Metric | Target |
|--------|--------|
| Concurrent users | 500 users simultaneously |
| API requests/second | 100 requests/second per region |
| Sync operations | 1000 records/minute |
| Report generation | < 30 seconds for 10,000 records |

### NFR-003: Resource Usage

| Resource | Target | Condition |
|----------|--------|-----------|
| App size (APK) | < 50 MB | Initial download |
| Local database | < 200 MB | 1 year data per user |
| Memory usage | < 150 MB | Active usage |
| Battery drain | < 5% per hour | Normal usage |
| Network data | < 10 MB/day | Average usage |

---

## 📴 Offline Requirements

### NFR-004: Offline Capability

| Feature | Requirement |
|---------|-------------|
| Offline duration | Unlimited (until storage full) |
| Read operations | 100% available offline |
| Write operations | 100% available offline (queued) |
| Data freshness | Last sync timestamp visible |
| Sync indicator | Always visible when pending sync |

### NFR-005: Sync Performance

| Metric | Target |
|--------|--------|
| Sync detection | < 5 seconds after reconnection |
| Full sync (initial) | < 5 minutes for 10,000 records |
| Incremental sync | < 30 seconds for 100 changes |
| Conflict resolution | < 2 seconds per conflict |
| Sync retry | 3 retries with exponential backoff |

### NFR-006: Conflict Resolution

| Scenario | Strategy |
|----------|----------|
| Same record, different fields | Field-level merge |
| Same record, same field | Server wins with notification |
| Delete conflict | Server wins, log conflict |
| Network failure during sync | Retry, maintain queue |

---

## 🔒 Security Requirements

### NFR-007: Authentication

| Requirement | Specification |
|-------------|---------------|
| Authentication method | Email/password + JWT |
| Password complexity | Min 8 chars, 1 upper, 1 number |
| Session timeout | 1 hour (access token), 7 days (refresh) |
| Failed login attempts | Lock after 5 attempts, 15 min cooldown |
| Password reset | Email-based, 24h expiry |

### NFR-008: Authorization

| Requirement | Specification |
|-------------|---------------|
| Access control model | RBAC (Role-Based Access Control) |
| Data visibility | Hierarchical (owner + ancestors) |
| Row Level Security | Enforced at database level |
| API authorization | JWT validation on every request |

### NFR-009: Data Protection

| Requirement | Specification |
|-------------|---------------|
| Data at rest (mobile) | SQLite encryption (SQLCipher) |
| Data in transit | TLS 1.3 minimum |
| Token storage | Secure storage (Keychain/Keystore) |
| Sensitive data logging | No passwords/tokens in logs |
| PII handling | Masked in error reports |

### NFR-010: Compliance

| Requirement | Specification |
|-------------|---------------|
| Data retention | Per company policy (configurable) |
| Audit logging | All CRUD operations logged |
| GDPR-like compliance | Data export, deletion capability |
| Backup | Daily automated backup (Supabase) |

---

## 📱 Reliability Requirements

### NFR-011: Availability

| Metric | Target |
|--------|--------|
| System uptime | 99.5% (excluding planned maintenance) |
| Planned maintenance | Max 4 hours/month, off-peak |
| Unplanned downtime | < 2 hours MTTR |
| Offline availability | 100% for cached data |

### NFR-012: Fault Tolerance

| Scenario | Behavior |
|----------|----------|
| Network disconnection | Seamless offline transition |
| API timeout | Retry with exponential backoff |
| Database error | Graceful error message, retry option |
| App crash | Auto-restart, preserve sync queue |
| Server error (5xx) | Queue operation, notify user |

### NFR-013: Data Integrity

| Requirement | Specification |
|-------------|---------------|
| Transaction safety | ACID compliance |
| Sync queue | Persistent across app restarts |
| Data validation | Client + server validation |
| Referential integrity | Database constraints enforced |

---

## 📍 Geolocation Requirements

### NFR-014: Location Accuracy

| Metric | Target |
|--------|--------|
| GPS accuracy threshold | 100 meters acceptable |
| Location capture method | Background, silent |
| Battery optimization | Fused location provider |
| Fallback | Network-based location if GPS unavailable |
| Permission denial | Allow operation without location |

### NFR-015: Location Verification

| Requirement | Specification |
|-------------|---------------|
| Distance threshold | Configurable per activity type (default 500m) |
| Verification timing | At execution time, not scheduling |
| Override option | Available with reason input |
| Spoofing detection | Basic detection (optional) |

---

## 📊 Scalability Requirements

### NFR-016: User Scalability

| Tier | Users | Specification |
|------|-------|---------------|
| Initial | 400 | MVP capacity |
| Growth | 1,000 | Phase 2 target |
| Enterprise | 5,000 | Long-term capacity |

### NFR-017: Data Scalability

| Entity | Year 1 | Year 3 |
|--------|--------|--------|
| Users | 400 | 1,000 |
| Customers | 50,000 | 200,000 |
| Pipelines | 100,000 | 500,000 |
| Activities | 500,000 | 2,000,000 |

### NFR-018: Storage Scalability

| Storage Type | Initial | Maximum |
|--------------|---------|---------|
| Database | 10 GB | 100 GB |
| File Storage | 50 GB | 500 GB |
| Local (per user) | 100 MB | 500 MB |

---

## 🖥️ Compatibility Requirements

### NFR-019: Mobile Platforms

| Platform | Minimum Version | Target Version |
|----------|-----------------|----------------|
| Android | 6.0 (API 23) | 14 (API 34) |
| iOS | 12.0 | 17.x |

### NFR-020: Device Support

| Category | Specification |
|----------|---------------|
| Screen sizes | 4.7" to 12.9" |
| RAM minimum | 2 GB |
| Storage minimum | 100 MB free |
| Orientation | Portrait primary, landscape optional |

### NFR-021: Web Browsers (Admin)

| Browser | Minimum Version |
|---------|-----------------|
| Chrome | 100+ |
| Firefox | 100+ |
| Safari | 15+ |
| Edge | 100+ |

---

## ♿ Accessibility Requirements

### NFR-022: Accessibility Standards

| Requirement | Specification |
|-------------|---------------|
| Standard | WCAG 2.1 Level AA |
| Color contrast | 4.5:1 minimum (text) |
| Touch targets | 44×44 px minimum |
| Screen reader | TalkBack/VoiceOver compatible |
| Font scaling | Support up to 200% |
| Reduced motion | Respect system preference |

---

## 🌐 Internationalization Requirements

### NFR-023: Language Support

| Requirement | Specification |
|-------------|---------------|
| Primary language | Bahasa Indonesia |
| Secondary language | English (future) |
| Date format | DD/MM/YYYY (configurable) |
| Currency | IDR (Rp) |
| Number format | Indonesian (1.000.000,00) |
| Timezone | WIB (UTC+7), WITA, WIT |

---

## 📱 Usability Requirements

### NFR-024: Learnability

| Metric | Target |
|--------|--------|
| Basic task completion | < 30 minutes self-learning |
| Training required | < 2 hours for full proficiency |
| Help availability | In-app tooltips, FAQ |
| Error recovery | Clear error messages with actions |

### NFR-025: User Experience

| Requirement | Specification |
|-------------|---------------|
| Navigation depth | Max 3 levels from home |
| Action confirmation | For destructive actions only |
| Loading feedback | Progress indicators |
| Empty states | Helpful empty state messages |
| Undo capability | For accidental changes |

---

## 🔧 Maintainability Requirements

### NFR-026: Code Quality

| Metric | Target |
|--------|--------|
| Code coverage | > 80% |
| Static analysis | 0 critical issues |
| Documentation | All public APIs documented |
| Code style | Enforced via linter |

### NFR-027: Monitoring

| Requirement | Specification |
|-------------|---------------|
| Error tracking | Sentry integration |
| Performance monitoring | App performance metrics |
| Analytics | User behavior tracking (opt-in) |
| Alerting | Critical error notifications |

### NFR-028: Deployment

| Requirement | Specification |
|-------------|---------------|
| Deployment frequency | Bi-weekly releases |
| Rollback capability | < 30 minutes |
| Feature flags | Gradual rollout support |
| Hot fix capability | Same-day deployment |

---

## 📊 NFR Verification Matrix

| NFR ID | Verification Method | Frequency |
|--------|---------------------|-----------|
| NFR-001 | Performance testing | Per sprint |
| NFR-004 | Offline testing | Per sprint |
| NFR-007 | Security testing | Per release |
| NFR-011 | Uptime monitoring | Continuous |
| NFR-014 | Field testing | Per feature |
| NFR-022 | Accessibility audit | Per release |

---

## 📚 Related Documents

- [Functional Requirements](functional-requirements.md) - Functional specs
- [System Architecture](../03-architecture/system-architecture.md) - Technical architecture
- [Testing Strategy](../09-implementation/testing-strategy.md) - Testing approach

---

*Dokumen ini adalah bagian dari LeadX CRM Requirements Documentation.*
