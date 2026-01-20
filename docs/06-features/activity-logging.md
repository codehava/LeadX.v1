# 📅 Activity Logging

## Feature Specification

---

## 📋 Overview

| Attribute | Value |
|-----------|-------|
| **Feature ID** | FEAT-003 |
| **Priority** | P0 (MVP) |
| **Status** | ✅ Implemented |
| **FR Reference** | [FR-004, FR-005](../02-requirements/functional-requirements.md#fr-004-aktivitas-terjadwal) |

---

## 🎯 Description

Activity Logging memungkinkan RM untuk mencatat aktivitas sales (visit, call, meeting) dengan GPS verification dan photo attachment.

---

## 🔄 Activity Types

| Type | Location Required | Photo Required | Notes Required |
|------|-------------------|----------------|----------------|
| Visit | ✅ GPS Verified | Optional | ✅ Yes |
| Call | ❌ No | ❌ No | ✅ Yes |
| Meeting | ⚠️ Optional | Optional | ✅ Yes |
| Proposal | ❌ No | ❌ No | Optional |
| Follow-up | ❌ No | ❌ No | ✅ Yes |
| Email | ❌ No | ❌ No | Optional |
| WhatsApp | ❌ No | ❌ No | Optional |

---

## 📱 User Interface

### Activity List (Calendar View)
- Day/Week/Month toggle
- Color coding by status
- Today's activities prominent
- Pull-to-refresh

### Schedule Activity Form
- Object type selection (Customer/Pipeline/HVC/Broker)
- Activity type dropdown
- Date & time picker
- Summary & notes

### Execute Activity
- Auto GPS capture (silent)
- Distance verification UI
- Photo capture option
- Notes input (required)

---

## 📍 GPS Verification

### Flow Diagram

```
┌────────────────────────────────────────┐
│           START EXECUTE                 │
└──────────────────┬─────────────────────┘
                   ▼
┌────────────────────────────────────────┐
│      Capture GPS (Silent, Background)  │
└──────────────────┬─────────────────────┘
                   ▼
┌────────────────────────────────────────┐
│   Calculate Distance to Customer/HVC   │
└──────────────────┬─────────────────────┘
                   ▼
          ┌────────┴────────┐
          ▼                 ▼
   Distance ≤ 500m    Distance > 500m
          │                 │
          ▼                 ▼
    ✅ Verified       ⚠️ Warning Dialog
                            │
                   ┌────────┴────────┐
                   ▼                 ▼
              Override          Cancel
           (with reason)
                   │
                   ▼
          ⚠️ Marked as "Override"
```

### GPS Settings

| Setting | Value |
|---------|-------|
| Verification radius | 500m (configurable) |
| Override allowed | Yes, with reason |
| Timeout | 30 seconds |
| Accuracy threshold | ≤ 100m |

---

## 🗄️ Data Model

### Primary Entity: `activities`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| id | UUID | Yes | Primary key |
| object_type | VARCHAR(20) | Yes | CUSTOMER/PIPELINE/HVC/BROKER |
| object_id | UUID | Yes | FK to related entity |
| activity_type_id | UUID | Yes | FK to activity_types |
| summary | VARCHAR(255) | No | Short description |
| notes | TEXT | No | Detailed notes |
| scheduled_at | TIMESTAMPTZ | No | For scheduled activities |
| executed_at | TIMESTAMPTZ | No | When completed |
| status | VARCHAR(20) | Yes | PLANNED/COMPLETED/CANCELLED |
| is_immediate | BOOLEAN | Yes | Scheduled vs immediate |
| latitude | DECIMAL | No | GPS lat |
| longitude | DECIMAL | No | GPS long |
| distance_meters | DECIMAL | No | Distance from target |
| is_gps_verified | BOOLEAN | No | Within radius |
| gps_override_reason | TEXT | No | If overridden |
| photo_url | TEXT | No | Attachment |
| assigned_to | UUID | Yes | FK to users |

---

## ⭐ Scoring Bonus

| Condition | Bonus |
|-----------|-------|
| Immediate activity (is_immediate=true) | +15% |
| GPS verified (is_gps_verified=true) | +10% |
| Photo attached | +5% |

---

## 📚 Related Documents

- [4DX Lead Measures](../07-4dx-framework/lead-lag-measures.md)
- [Offline-First Design](../03-architecture/offline-first-design.md)

---

*Feature spec v1.0 - January 2025*
