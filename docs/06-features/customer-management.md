# 👤 Customer Management

## Feature Specification

---

## 📋 Overview

| Attribute | Value |
|-----------|-------|
| **Feature ID** | FEAT-001 |
| **Priority** | P0 (MVP) |
| **Status** | ✅ Implemented |
| **FR Reference** | [FR-002](../02-requirements/functional-requirements.md#fr-002-customer-management) |

---

## 🎯 Description

Customer Management memungkinkan RM untuk mengelola data customer termasuk informasi perusahaan, key persons, dan HVC linkage.

---

## 📱 User Interface

### Customer List Screen
- Search bar dengan real-time filtering
- Filter chips: Province, City, Industry
- Infinite scroll dengan pull-to-refresh
- FAB untuk create customer

### Customer Detail Screen
- Header: Name, code, status badge
- Smart buttons: Pipelines, Activities, TSI
- Quick actions: Call, Email, WhatsApp, Maps
- Tabs: Info, Key Persons, Pipelines, Activities, History

### Customer Form
- Section 1: Basic Info (name, type, ownership)
- Section 2: Address (province, city, postal)
- Section 3: Contact (phone, email, website)
- Section 4: HVC Link (optional)

---

## 🗄️ Data Model

### Primary Entity: `customers`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| id | UUID | Yes | Primary key |
| code | VARCHAR(20) | Yes | Auto-generated CUS-XXXXX |
| name | VARCHAR(200) | Yes | Company name |
| address | TEXT | Yes | Street address |
| province_id | UUID | Yes | FK to provinces |
| city_id | UUID | Yes | FK to cities |
| postal_code | VARCHAR(10) | No | |
| phone | VARCHAR(20) | No | |
| email | VARCHAR(100) | No | Validated format |
| website | VARCHAR(200) | No | |
| company_type_id | UUID | Yes | FK to company_types |
| ownership_type_id | UUID | Yes | FK to ownership_types |
| industry_id | UUID | Yes | FK to industries |
| npwp | VARCHAR(30) | No | Tax ID |
| latitude | DECIMAL | No | GPS auto-capture |
| longitude | DECIMAL | No | GPS auto-capture |
| assigned_to | UUID | Yes | FK to users |
| is_active | BOOLEAN | Yes | Default true |

### Related Entities
- `key_persons` - Contact persons
- `customer_hvc_links` - HVC relationships
- `pipelines` - Business opportunities
- `activities` - Visit/call logs

---

## 🔐 Access Control

| Role | List | View | Create | Edit | Delete |
|------|------|------|--------|------|--------|
| RM | Own | Own | Yes | Own | No |
| BH | Team | Team | Yes | Team | No |
| BM | Branch | Branch | Yes | Branch | No |
| Admin | All | All | Yes | All | Yes |

---

## 📴 Offline Support

| Operation | Offline | Sync Strategy |
|-----------|---------|---------------|
| List/View | ✅ Yes | Cache 1000 records |
| Create | ✅ Yes | Queue for sync |
| Edit | ✅ Yes | Queue for sync |
| Delete | ❌ No | Online only |

---

## 📚 Related Documents

- [Schema Overview](../04-database/schema-overview.md)
- [Screen Flows](../05-ui-ux/screen-flows.md)
- [User Stories](../02-requirements/user-stories.md#customer-module)

---

*Feature spec v1.0 - January 2025*
