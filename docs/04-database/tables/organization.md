# 🏢 Organization Tables

## Database Tables - Organization Structure

---

## 📋 Overview

Tabel-tabel yang menyimpan struktur organisasi LeadX CRM.

---

## 📊 Tables

### users

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| email | VARCHAR(255) | Unique email |
| name | VARCHAR(200) | Full name |
| role | VARCHAR(20) | RM/BH/BM/ROH/ADMIN |
| parent_id | UUID | FK to supervisor |
| branch_id | UUID | FK to branches |
| regional_id | UUID | FK to regional_offices |
| is_active | BOOLEAN | Account status |

See: [users.md](users.md) for full documentation.

---

### branches

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| code | VARCHAR(20) | Branch code |
| name | VARCHAR(100) | Branch name |
| regional_id | UUID | FK to regional_offices |
| address | TEXT | Address |
| is_active | BOOLEAN | Status |

---

### regional_offices

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| code | VARCHAR(20) | Regional code |
| name | VARCHAR(100) | Regional name |
| is_active | BOOLEAN | Status |

---

## 🔗 Relationships

```
regional_offices ──◀── branches ──◀── users
                                      │
                                      ▼
                                   users (parent_id)
```

---

*Organization Tables - January 2025*
