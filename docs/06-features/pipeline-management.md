# 📊 Pipeline Management

## Feature Specification

---

## 📋 Overview

| Attribute | Value |
|-----------|-------|
| **Feature ID** | FEAT-002 |
| **Priority** | P0 (MVP) |
| **Status** | ✅ Implemented |
| **FR Reference** | [FR-003](../02-requirements/functional-requirements.md#fr-003-pipeline-management) |

---

## 🎯 Description

Pipeline Management memungkinkan RM untuk mengelola prospek bisnis dari NEW hingga ACCEPTED/DECLINED dengan tracking stage progression.

---

## 📱 User Interface

### Pipeline List Screen
- Toggle: Kanban View / List View
- Kanban: Drag-drop antar stage
- List: Filter by stage, COB, date range
- Color coding per stage

### Pipeline Detail Screen
- Header: Customer, code, stage pill
- Values: TSI, Premium, Weighted value
- Lead source info (Broker if applicable)
- Activity timeline

### Pipeline Form
- Customer selection (searchable)
- COB → LOB cascade dropdown
- Lead source selection
- Estimated premium input
- Expected close date

---

## 🔄 Stage Workflow

```
NEW (10%) ──▶ P3 (25%) ──▶ P2 (50%) ──▶ P1 (75%) ──▶ ACCEPTED (100%)
                │            │            │
                ▼            ▼            ▼
            DECLINED     DECLINED     DECLINED (0%)
```

### Stage Descriptions

| Stage | Probability | Description |
|-------|-------------|-------------|
| NEW | 10% | Initial lead, minimal qualification |
| P3 | 25% | Prospect identified, initial contact made |
| P2 | 50% | Proposal sent, active negotiation |
| P1 | 75% | Verbal agreement, final negotiation |
| ACCEPTED | 100% | Policy issued, deal won |
| DECLINED | 0% | Deal lost (track reason) |

---

## 🗄️ Data Model

### Primary Entity: `pipelines`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| id | UUID | Yes | Primary key |
| code | VARCHAR(20) | Yes | Auto-generated PIP-XXXXX |
| customer_id | UUID | Yes | FK to customers |
| cob_id | UUID | Yes | FK to cob |
| lob_id | UUID | Yes | FK to lob |
| lead_source_id | UUID | Yes | FK to lead_sources |
| broker_id | UUID | No | FK to brokers (if source=BROKER) |
| broker_pic_id | UUID | No | FK to key_persons |
| tsi | DECIMAL | No | Total Sum Insured |
| potential_premium | DECIMAL | Yes | Expected premium |
| stage | VARCHAR(20) | Yes | Current stage |
| status_id | UUID | No | FK to pipeline_statuses |
| probability | DECIMAL | Yes | Stage probability |
| weighted_value | DECIMAL | Yes | Calculated field |
| is_tender | BOOLEAN | No | Is tender process |
| expected_close_date | DATE | No | |
| closed_at | TIMESTAMPTZ | No | When won/lost |
| assigned_to | UUID | Yes | FK to users |

---

## 📚 Related Documents

- [Entity Relationships](../04-database/entity-relationships.md)
- [Broker Management](../02-requirements/functional-requirements.md#fr-010-broker-management)

---

*Feature spec v1.0 - January 2025*
