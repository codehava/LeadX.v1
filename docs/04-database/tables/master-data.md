# 📦 Master Data Tables

## Database Tables - Master Data

---

## 📋 Overview

Tabel-tabel referensi yang jarang berubah (lookup tables).

---

## 📊 Tables

### provinces

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| code | VARCHAR(10) | Province code |
| name | VARCHAR(100) | Province name |

### cities

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| province_id | UUID | FK to provinces |
| code | VARCHAR(10) | City code |
| name | VARCHAR(100) | City name |

### industries

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| name | VARCHAR(100) | Industry name |
| is_active | BOOLEAN | Status |

### company_types

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| name | VARCHAR(50) | Type name (PT, CV, etc) |

### ownership_types

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| name | VARCHAR(50) | Ownership type (BUMN, Swasta) |

### cob (Class of Business)

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| code | VARCHAR(10) | COB code |
| name | VARCHAR(100) | COB name |

### lob (Line of Business)

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| cob_id | UUID | FK to cob |
| code | VARCHAR(10) | LOB code |
| name | VARCHAR(100) | LOB name |

---

## 🔗 Relationships

```
provinces ──◀── cities
cob ──◀── lob
```

---

*Master Data Tables - January 2025*
