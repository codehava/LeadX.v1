# 🔐 Role & Permission

## Feature Specification

---

## 📋 Overview

| Attribute | Value |
|-----------|-------|
| **Feature ID** | FEAT-005 |
| **Priority** | P1 (Post-MVP) |
| **Status** | 📝 Planned |
| **FR Reference** | [FR-017](../02-requirements/functional-requirements.md#fr-017-role--permission-management) |

---

## 🎯 Description

Role & Permission management memungkinkan Admin untuk mengelola akses granular berdasarkan role dengan custom permission assignment.

---

## 👥 System Roles

| Role | Level | Scope | Custom |
|------|-------|-------|--------|
| RM | Field | OWN | ❌ System |
| BH | Team Lead | TEAM | ❌ System |
| BM | Branch | BRANCH | ❌ System |
| ROH | Regional | REGIONAL | ❌ System |
| ADMIN | System | ALL | ❌ System |
| SUPERADMIN | Super | ALL | ❌ System |
| (Custom) | Varies | Configurable | ✅ Custom |

---

## 🔑 Permission Structure

### Resource Categories

| Category | Resources |
|----------|-----------|
| Customer | customers, key_persons |
| Pipeline | pipelines, stages, statuses |
| Activity | activities, activity_types |
| HVC | hvc, hvc_types, customer_hvc_links |
| Broker | brokers, broker_pics |
| Report | reports, exports |
| Admin | users, roles, settings |

### Action Types

| Action | Code | Description |
|--------|------|-------------|
| Create | CREATE | Add new records |
| Read | READ | View records |
| Update | UPDATE | Modify records |
| Delete | DELETE | Remove records |
| Export | EXPORT | Download data |

### Scope Levels

| Scope | Description | Includes |
|-------|-------------|----------|
| OWN | Only own records | - |
| TEAM | Own + subordinates | OWN |
| BRANCH | Entire branch | TEAM |
| REGIONAL | Entire region | BRANCH |
| ALL | Everything | REGIONAL |

---

## 📱 Admin UI

### Role List Screen
- System roles (read-only)
- Custom roles (editable)
- User count per role
- Quick actions

### Permission Matrix
- Rows: Permissions
- Columns: Scope levels
- Checkbox selection
- Save/Reset buttons

---

## 🗄️ Data Model

See [Entity Relationships - Role Permission](../04-database/entity-relationships.md#role--permission-relationship)

---

## 📚 Related Documents

- [Role Permission System](../03-architecture/role-permission-system.md)
- [RLS Policies](../04-database/rls-policies.md)

---

*Feature spec v1.0 - January 2025*
