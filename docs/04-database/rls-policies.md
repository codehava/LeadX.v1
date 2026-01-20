# 🔐 RLS Policies

## Row Level Security Policies LeadX CRM

---

## 📋 Overview

Dokumen ini mendefinisikan semua Row Level Security (RLS) policies yang diterapkan di PostgreSQL untuk mengontrol akses data berdasarkan role dan hierarchy user.

---

## 🏛️ Access Control Principles

### Role Hierarchy

```
SUPERADMIN (All data)
├── ADMIN (All data)
├── ROH (Regional data)
│   ├── BM (Branch data)
│   │   ├── BH (Team data)
│   │   │   └── RM (Own data only)
```

### Access Patterns

| Role | Own Data | Subordinate Data | Branch | Regional | All |
|------|----------|------------------|--------|----------|-----|
| RM | ✅ | ❌ | ❌ | ❌ | ❌ |
| BH | ✅ | ✅ (direct) | ❌ | ❌ | ❌ |
| BM | ✅ | ✅ | ✅ | ❌ | ❌ |
| ROH | ✅ | ✅ | ✅ | ✅ | ❌ |
| ADMIN | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## 🔑 Core RLS Policies

### Users Table

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users can view themselves
CREATE POLICY "users_self_view" ON users
FOR SELECT USING (id = auth.uid());

-- Supervisors can view subordinates
CREATE POLICY "users_subordinate_view" ON users
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = auth.uid()
    AND descendant_id = users.id
  )
);

-- Admins can view all
CREATE POLICY "users_admin_all" ON users
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users u
    WHERE u.id = auth.uid()
    AND u.role IN ('ADMIN', 'SUPERADMIN')
  )
);
```

### Customers Table

```sql
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

-- RM can access own customers
CREATE POLICY "customers_rm_own" ON customers
FOR ALL USING (assigned_rm_id = (SELECT auth.uid()));

-- Supervisors can access subordinate customers
CREATE POLICY "customers_supervisor" ON customers
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = customers.assigned_rm_id
  )
);

-- Admins full access
CREATE POLICY "customers_admin" ON customers
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = (SELECT auth.uid())
    AND role IN ('ADMIN', 'SUPERADMIN')
  )
);
```

### Pipelines Table

```sql
ALTER TABLE pipelines ENABLE ROW LEVEL SECURITY;

-- Same pattern as customers
CREATE POLICY "pipelines_rm_own" ON pipelines
FOR ALL USING (assigned_rm_id = (SELECT auth.uid()));

CREATE POLICY "pipelines_supervisor" ON pipelines
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = pipelines.assigned_rm_id
  )
);
```

### Activities Table

```sql
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;

-- Users can access own activities
CREATE POLICY "activities_own" ON activities
FOR ALL USING (user_id = (SELECT auth.uid()));

-- Supervisors can view subordinate activities
CREATE POLICY "activities_supervisor" ON activities
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = activities.user_id
  )
);
```

---

## 🔧 User Hierarchy (Closure Table)

```sql
-- Precomputed hierarchy for efficient RLS queries
CREATE TABLE user_hierarchy (
  ancestor_id UUID NOT NULL REFERENCES users(id),
  descendant_id UUID NOT NULL REFERENCES users(id),
  depth INTEGER NOT NULL,
  PRIMARY KEY (ancestor_id, descendant_id)
);

-- Indexes for performance
CREATE INDEX idx_hierarchy_ancestor ON user_hierarchy(ancestor_id);
CREATE INDEX idx_hierarchy_descendant ON user_hierarchy(descendant_id);

-- Trigger to maintain hierarchy on user changes
CREATE OR REPLACE FUNCTION update_user_hierarchy()
RETURNS TRIGGER AS $$
BEGIN
  -- Remove old relations
  DELETE FROM user_hierarchy WHERE descendant_id = NEW.id;
  
  -- Add self-reference
  INSERT INTO user_hierarchy VALUES (NEW.id, NEW.id, 0);
  
  -- Add ancestor relations
  IF NEW.supervisor_id IS NOT NULL THEN
    INSERT INTO user_hierarchy (ancestor_id, descendant_id, depth)
    SELECT ancestor_id, NEW.id, depth + 1
    FROM user_hierarchy
    WHERE descendant_id = NEW.supervisor_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

## ⚡ Performance Optimizations

### Required Indexes

```sql
-- Index on RLS policy columns
CREATE INDEX idx_customers_assigned_rm ON customers(assigned_rm_id);
CREATE INDEX idx_pipelines_assigned_rm ON pipelines(assigned_rm_id);
CREATE INDEX idx_activities_user ON activities(user_id);

-- Wrap auth.uid() in SELECT for caching
-- Example of optimized policy:
CREATE POLICY "optimized_policy" ON customers
FOR SELECT USING (
  assigned_rm_id = (SELECT auth.uid())  -- Cached!
);
```

---

## ✅ RLS Checklist

- [x] Enable RLS on all user-facing tables
- [x] Create policies for SELECT, INSERT, UPDATE, DELETE
- [x] Index all columns used in policies
- [x] Use `(SELECT auth.uid())` for caching
- [x] Document all policies with comments
- [x] Test with different user roles

---

## 📚 Related Documents

- [Security Architecture](../03-architecture/security-architecture.md)
- [Schema Overview](schema-overview.md)
- [Entity Relationships](entity-relationships.md)

---

*Dokumen ini adalah bagian dari LeadX CRM Database Documentation.*
