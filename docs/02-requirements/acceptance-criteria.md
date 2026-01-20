# ✅ Acceptance Criteria

## Kriteria Penerimaan Detail per User Story

---

## 📋 Overview

Dokumen ini berisi acceptance criteria detail untuk setiap user story, digunakan sebagai basis untuk testing dan validasi feature.

---

## 🔐 Authentication Module

### US-AUTH-001: Login

**Story**: Sebagai User, saya ingin login ke aplikasi dengan email dan password.

| # | Criteria | Priority |
|---|----------|----------|
| 1 | Email field validates format (xxx@xxx.xxx) | Must |
| 2 | Password field minimum 8 characters | Must |
| 3 | Show error message for invalid credentials | Must |
| 4 | Redirect to dashboard on successful login | Must |
| 5 | Store JWT token securely (Keychain/Keystore) | Must |
| 6 | Show loading indicator during login | Should |
| 7 | Support "Remember Me" option | Could |

### US-AUTH-002: Logout

| # | Criteria | Priority |
|---|----------|----------|
| 1 | Clear all local tokens | Must |
| 2 | Clear sensitive cached data | Must |
| 3 | Redirect to login screen | Must |
| 4 | Sync pending changes before logout (if online) | Should |

---

## 👥 Customer Module

### US-CUST-001: View Customer List

| # | Criteria | Priority |
|---|----------|----------|
| 1 | Display customer name, company, last activity | Must |
| 2 | RM only sees own customers | Must |
| 3 | BH+ sees subordinate customers | Must |
| 4 | Support search by name/company | Must |
| 5 | Support filter by status | Should |
| 6 | Pagination (infinite scroll) | Should |
| 7 | Sort by name/date/activity | Could |

### US-CUST-002: Create Customer

| # | Criteria | Priority |
|---|----------|----------|
| 1 | Customer name required | Must |
| 2 | Phone number optional, validates format | Should |
| 3 | Email optional, validates format | Should |
| 4 | Company name optional | Should |
| 5 | Save works offline | Must |
| 6 | GPS captured on creation | Must |
| 7 | Assigned to creating RM automatically | Must |

### US-CUST-003: View Customer Detail

| # | Criteria | Priority |
|---|----------|----------|
| 1 | Display all customer fields | Must |
| 2 | Show related pipelines | Must |
| 3 | Show activity history | Must |
| 4 | Show key persons list | Should |
| 5 | Quick action buttons (call, email, navigate) | Should |

---

## 📊 Pipeline Module

### US-PIPE-001: Create Pipeline

| # | Criteria | Priority |
|---|----------|----------|
| 1 | Select existing customer (required) | Must |
| 2 | Select COB and LOB | Must |
| 3 | Input potential premium | Must |
| 4 | Select lead source | Must |
| 5 | If Broker: select broker and PIC | Must |
| 6 | Expected close date required | Must |
| 7 | Initial stage = LEADS | Must |

### US-PIPE-002: Update Pipeline Stage

| # | Criteria | Priority |
|---|----------|----------|
| 1 | Can move to next valid stage | Must |
| 2 | Cannot skip stages | Must |
| 3 | Require reason when moving to REJECTED | Must |
| 4 | GPS captured on stage change | Must |
| 5 | Stage history recorded | Should |

---

## 📍 Activity Module

### US-ACT-001: Log Activity

| # | Criteria | Priority |
|---|----------|----------|
| 1 | Select activity type (Visit, Call, Meeting, etc) | Must |
| 2 | GPS captured automatically | Must |
| 3 | Date/time captured automatically | Must |
| 4 | Notes field available | Should |
| 5 | Photo attachment optional | Should |
| 6 | Link to customer required | Must |
| 7 | Link to pipeline optional | Should |
| 8 | Works offline | Must |

### US-ACT-002: Check-in/Check-out

| # | Criteria | Priority |
|---|----------|----------|
| 1 | GPS captured on check-in | Must |
| 2 | GPS captured on check-out | Must |
| 3 | Duration calculated automatically | Must |
| 4 | Show elapsed time during visit | Should |
| 5 | Notification if check-out forgotten (>4 hours) | Could |

---

## 🎯 4DX Module

### US-4DX-001: View Scoreboard

| # | Criteria | Priority |
|---|----------|----------|
| 1 | Display current score (0-150) | Must |
| 2 | Show lead measures with progress | Must |
| 3 | Show lag measures with progress | Must |
| 4 | Display rank in team | Must |
| 5 | Show trend (↑↓─) | Should |
| 6 | Weekly trend chart | Could |

### US-4DX-002: Submit Pre-Meeting Form

| # | Criteria | Priority |
|---|----------|----------|
| 1 | Q1 auto-populated from last Q4 | Must |
| 2 | Q2, Q3, Q4 required fields | Must |
| 3 | Minimum character count for Q2, Q4 | Should |
| 4 | Deadline indicator | Must |
| 5 | On-time submission bonus applied | Must |

---

## 📱 Offline Requirements

### All Modules

| # | Criteria | Priority |
|---|----------|----------|
| 1 | Core CRUD works without internet | Must |
| 2 | Data syncs when online | Must |
| 3 | Conflict resolution handled | Must |
| 4 | Sync status indicator visible | Should |
| 5 | Manual sync option available | Should |

---

## 📚 Related Documents

- [User Stories](user-stories.md)
- [Functional Requirements](functional-requirements.md)
- [Testing Strategy](../09-implementation/testing-strategy.md)

---

*Dokumen ini adalah bagian dari LeadX CRM Requirements Documentation.*
