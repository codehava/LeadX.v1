# 🎯 WIG Management

## Wildly Important Goals dalam LeadX CRM

---

## 📋 Overview

**Discipline 1: Focus on the Wildly Important** - Semakin banyak yang dicoba, semakin sedikit yang tercapai. WIG adalah goal yang HARUS dicapai.

---

## 🏛️ WIG Hierarchy

```
COMPANY WIG
├── Regional WIG (ROH)
│   ├── Branch WIG (BM)
│   │   ├── Team WIG (BH)
│   │   │   └── Individual Contribution (RM)
```

### Cascade Rules

| Level | Max WIGs | Set By | Approved By |
|-------|----------|--------|-------------|
| Company | 2 | Director | Board |
| Regional | 2 | ROH | Director |
| Branch | 2 | BM | ROH |
| Team | 2 | BH | BM |

---

## 📝 WIG Format

**Standard Format**: `From X to Y by When`

### Examples

| Level | WIG Statement |
|-------|---------------|
| Company | From Rp 50B to Rp 75B annual premium by Dec 2025 |
| Regional | From 40% to 60% conversion rate by Q2 2025 |
| Branch | From 100 to 150 active customers by Mar 2025 |
| Team | From 80 to 95 average score by Feb 2025 |

---

## 🎯 WIG Types

### Lag-Based WIGs (Results)

| Type | Example | Measure |
|------|---------|---------|
| Revenue | Increase premium from X to Y | Total premium won |
| Growth | Add X new customers | Customer count |
| Conversion | Improve win rate to X% | Pipeline conversion |

### Lead-Based WIGs (Activities)

| Type | Example | Measure |
|------|---------|---------|
| Activity | Increase visits from X to Y/week | Visit count |
| Coverage | Visit 100% of HVC customers monthly | HVC coverage % |
| Quality | Achieve 90% GPS verification | Verified activities % |

---

## 📊 WIG Tracking

### Progress Visualization

```
COMPANY WIG: Premium Rp 50B → Rp 75B by Dec 2025

Progress: ████████████░░░░░░░░  58.3%
Current:  Rp 62.5B
Target:   Rp 75B
Gap:      Rp 12.5B
Time:     7 months remaining
```

### Status Indicators

| Status | Criteria | Action |
|--------|----------|--------|
| 🟢 On Track | ≥ 90% of expected progress | Continue execution |
| 🟡 At Risk | 70-89% of expected progress | Investigate blockers |
| 🔴 Off Track | < 70% of expected progress | Immediate intervention |

---

## 🗄️ Database Schema

```sql
CREATE TABLE wigs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(200) NOT NULL,
  description TEXT,
  level VARCHAR(20), -- COMPANY, REGIONAL, BRANCH, TEAM
  owner_id UUID REFERENCES users(id),
  parent_wig_id UUID REFERENCES wigs(id),
  measure_type VARCHAR(20), -- LAG, LEAD
  measure_code VARCHAR(50),
  baseline_value NUMERIC NOT NULL,
  target_value NUMERIC NOT NULL,
  current_value NUMERIC DEFAULT 0,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status VARCHAR(20) DEFAULT 'ACTIVE',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE wig_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  wig_id UUID REFERENCES wigs(id),
  recorded_date DATE NOT NULL,
  value NUMERIC NOT NULL,
  notes TEXT,
  recorded_by UUID REFERENCES users(id)
);
```

---

## ⚙️ Admin Configuration

### WIG Settings (Admin Panel)

- **Max WIGs per level**: Configurable (default 2)
- **WIG approval workflow**: Enable/disable
- **Progress update frequency**: Daily/Weekly
- **Auto-calculate from measures**: Enable/disable

---

## 📚 Related Documents

- [4DX Overview](4dx-overview.md)
- [Lead-Lag Measures](lead-lag-measures.md)
- [Scoreboard Design](scoreboard-design.md)

---

*Dokumen ini adalah bagian dari LeadX CRM 4DX Framework Documentation.*
