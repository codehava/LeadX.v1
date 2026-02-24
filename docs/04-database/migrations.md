# 📦 Migration Documentation

## Database Migration Strategy LeadX CRM

---

## 📋 Overview

Dokumen ini menjelaskan strategi dan prosedur untuk database migrations pada LeadX CRM.

---

## 🔧 Migration Tool

LeadX menggunakan **Supabase Migrations** yang berbasis PostgreSQL.

### File Structure

```
supabase/
├── migrations/
│   ├── 20250101000000_initial_schema.sql
│   ├── 20250110000000_add_referral_tables.sql
│   ├── 20250115000000_add_role_permissions.sql
│   └── 20250120000000_add_audit_logs.sql
└── seed.sql
```

---

## 📝 Migration Naming Convention

**Format**: `YYYYMMDDHHMMSS_description.sql`

### Examples

| Migration File | Description |
|----------------|-------------|
| `20250101000000_initial_schema.sql` | Initial database schema |
| `20250110000000_add_referral_tables.sql` | Pipeline referral feature |
| `20250115000000_add_role_permissions.sql` | RBAC tables |
| `20250120000000_add_audit_logs.sql` | Audit trail |

---

## 🚀 Migration Commands

### Local Development

```bash
# Create new migration
supabase migration new add_new_feature

# Apply migrations locally
supabase db reset

# Check migration status
supabase migration list
```

### Staging/Production

```bash
# Apply to remote database
supabase db push --linked

# Push to specific environment
supabase db push --db-url postgres://...
```

---

## 📊 Migration Best Practices

### DO's

- ✅ Always backup before migrating production
- ✅ Test migrations on staging first
- ✅ Use transactions for multi-statement migrations
- ✅ Add IF EXISTS / IF NOT EXISTS for safety
- ✅ Document breaking changes

### DON'Ts

- ❌ Don't delete columns in production (deprecate instead)
- ❌ Don't rename tables without alias
- ❌ Don't run ALTER on large tables during peak hours
- ❌ Don't skip migration files

---

## 🔄 Rollback Strategy

### Reversible Migrations

```sql
-- Forward: Add column
ALTER TABLE customers ADD COLUMN segment VARCHAR(50);

-- Rollback: Remove column (ONLY if safe)
-- ALTER TABLE customers DROP COLUMN segment;
```

### Point-in-Time Recovery

Supabase Pro provides automated backups. For rollback:
1. Contact Supabase support
2. Or restore from manual backup

---

## 📅 Migration History

| Date | Migration | Description | Status |
|------|-----------|-------------|--------|
| 2025-01-01 | initial_schema | Base tables | ✅ Applied |
| 2025-01-10 | add_referral_tables | Referral system | ✅ Applied |
| 2025-01-15 | add_role_permissions | RBAC | ✅ Applied |
| 2025-01-20 | add_audit_logs | Audit trail | ✅ Applied |
| 2026-02-07 | multi_period_scoring | Multi-period scoring support | ✅ Applied |
| 2026-02-23 | add_users_deleted_at | Soft delete for users | ✅ Applied |
| 2026-02-23 | ranking_functions | Scoring ranking functions | ✅ Applied |
| 2026-02-24 | add_users_nip_unique | Unique constraint on users.nip | ✅ Applied |

---

## 📚 Related Documents

- [Schema Overview](schema-overview.md)
- [Entity Relationships](entity-relationships.md)
- [RLS Policies](rls-policies.md)

---

*Migration Documentation - January 2025*
