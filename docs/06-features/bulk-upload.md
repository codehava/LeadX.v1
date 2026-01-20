# 📤 Bulk Upload

## Feature Specification

---

## 📋 Overview

| Attribute | Value |
|-----------|-------|
| **Feature ID** | FEAT-006 |
| **Priority** | P1 (Post-MVP) |
| **Status** | 📝 Planned |
| **FR Reference** | [FR-018](../02-requirements/functional-requirements.md#fr-018-bulk-upload) |

---

## 🎯 Description

Bulk Upload memungkinkan Admin untuk mengupload data HVC dan Broker dalam jumlah besar via Excel/CSV.

---

## 📁 Supported Data Types

| Data Type | Template | Max Rows |
|-----------|----------|----------|
| HVC | hvc_template.xlsx | 1000 |
| Broker | broker_template.xlsx | 1000 |
| Customer | customer_template.xlsx | 500 (future) |

---

## 🔄 Upload Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         BULK UPLOAD FLOW                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   1. DOWNLOAD         2. UPLOAD           3. VALIDATE        4. IMPORT      │
│  ┌──────────┐       ┌──────────┐        ┌──────────┐      ┌──────────┐     │
│  │ Template │ ───▶  │ File     │ ───▶   │ Preview  │ ───▶ │ Confirm  │     │
│  │ Download │       │ Select   │        │ & Errors │      │ Import   │     │
│  └──────────┘       └──────────┘        └──────────┘      └──────────┘     │
│                                               │                  │          │
│                                               ▼                  ▼          │
│                                         ┌──────────┐      ┌──────────┐     │
│                                         │ Fix File │      │ Report   │     │
│                                         │ Re-upload│      │ Download │     │
│                                         └──────────┘      └──────────┘     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## ✅ Validation Rules

### HVC Template

| Column | Required | Validation |
|--------|----------|------------|
| code | Yes | Unique, max 20 chars |
| name | Yes | Max 200 chars |
| type | Yes | Must exist in hvc_types |
| address | No | Max 500 chars |
| phone | No | Phone format |
| email | No | Email format |

### Broker Template

| Column | Required | Validation |
|--------|----------|------------|
| code | Yes | Unique, max 20 chars |
| name | Yes | Max 200 chars |
| type | Yes | Must exist in broker_types |
| license_number | No | Max 50 chars |
| address | No | Max 500 chars |

---

## 📱 Admin UI

### Upload Screen
1. Select data type (HVC/Broker)
2. Download template button
3. File dropzone (drag & drop)
4. Upload button

### Preview Screen
- Valid rows (green)
- Error rows (red with detail)
- Summary counts
- Proceed / Cancel

### Result Screen
- Success count
- Failed count
- Download error report
- Done button

---

## ⚙️ Technical Specs

| Setting | Value |
|---------|-------|
| Max file size | 5 MB |
| Supported formats | .xlsx, .csv |
| Batch size | 100 rows |
| Transaction | Per batch |

---

## 📚 Related Documents

- [HVC Management](../02-requirements/functional-requirements.md#fr-009-hvc-management)
- [Broker Management](../02-requirements/functional-requirements.md#fr-010-broker-management)

---

*Feature spec v1.0 - January 2025*
