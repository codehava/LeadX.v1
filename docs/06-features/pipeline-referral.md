# 🔄 Pipeline Referral

## Feature Specification

---

## 📋 Overview

| Attribute | Value |
|-----------|-------|
| **Feature ID** | FEAT-004 |
| **Priority** | P1 (Post-MVP) |
| **Status** | 📝 Planned |
| **FR Reference** | [FR-016](../02-requirements/functional-requirements.md#fr-016-pipeline-referral) |

---

## 🎯 Description

Pipeline Referral memungkinkan RM untuk meneruskan prospek ke RM lain (biasanya di territory berbeda) dengan approval workflow.

---

## 🔄 Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      PIPELINE REFERRAL WORKFLOW                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   REFERRER RM                 RECEIVER RM                RECEIVER BM        │
│       │                           │                           │             │
│   ┌───┴───┐                       │                           │             │
│   │Create │                       │                           │             │
│   │Referral│──── Notify ─────▶    │                           │             │
│   └───────┘                   ┌───┴───┐                       │             │
│       │                       │Accept/│                       │             │
│       │                       │Reject │                       │             │
│       │                       └───┬───┘                       │             │
│       │                           │                           │             │
│       │            ┌──────────────┴──────────────┐            │             │
│       │            ▼                             ▼            │             │
│       │        ACCEPTED                      REJECTED         │             │
│       │            │                             │            │             │
│       │            ▼                         Notify           │             │
│       │      Notify BM ──────────────▶    ┌───┴───┐          │             │
│       │            │                      │Approve/│          │             │
│       │            │                      │Decline │          │             │
│       │            │                      └───┬───┘          │             │
│       │            │               ┌──────────┴──────────┐    │             │
│       │            │               ▼                     ▼    │             │
│       │            │          APPROVED               DECLINED │             │
│       │            │               │                     │    │             │
│       │            │               ▼                 Notify   │             │
│       │            │        Create Pipeline                   │             │
│       │            │               │                          │             │
│       │            │               ▼ (if WON)                 │             │
│       │◀───Bonus───┴───────── Referral Bonus                  │             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📱 User Interface

### Create Referral Screen
- Customer selection (own customers)
- COB/LOB selection
- Estimated premium input
- Target RM search
- Reason/notes

### Incoming Referrals (Receiver)
- List pending referrals
- Customer preview
- Accept/Reject buttons

### Approval Queue (BM)
- List pending approvals
- View full details
- Approve/Decline actions

---

## 🗄️ Data Model

See [Entity Relationships - Pipeline Referral](../04-database/entity-relationships.md#pipeline-referral-relationship)

---

## 📚 Related Documents

- [Pipeline Referral System](../03-architecture/pipeline-referral-system.md)
- [Screen Flows](../05-ui-ux/screen-flows.md)

---

*Feature spec v1.0 - January 2025*
