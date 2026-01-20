# 🎯 WIG Management

## Wildly Important Goals dalam LeadX CRM

---

## 📋 Overview

**Discipline 1: Focus on the Wildly Important** - Semakin banyak yang dicoba, semakin sedikit yang tercapai. WIG adalah goal yang HARUS dicapai.

### Key Principles

| Principle | Description |
|-----------|-------------|
| **Focus** | Maksimal 2 WIG aktif per level |
| **Clarity** | Format "From X to Y by When" |
| **Cascade** | WIG level atas diturunkan ke bawah |
| **Measurable** | Terhubung dengan Lead/Lag measures |
| **Time-bound** | Deadline yang jelas |

---

## 🏛️ WIG Hierarchy

### Cascade Structure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         WIG HIERARCHY CASCADE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  COMPANY WIG (Set by Director, Approved by Board)                           │
│  "From Rp 50B to Rp 75B annual premium by Dec 2025"                         │
│                               │                                              │
│                               │ cascade                                      │
│                               ▼                                              │
│  REGIONAL WIG (Set by ROH, Approved by Director)                            │
│  "From Rp 15B to Rp 22B regional premium by Dec 2025"                       │
│                               │                                              │
│                               │ cascade                                      │
│                               ▼                                              │
│  BRANCH WIG (Set by BM, Approved by ROH)                                    │
│  "From Rp 3B to Rp 4.5B branch premium by Dec 2025"                         │
│                               │                                              │
│                               │ cascade                                      │
│                               ▼                                              │
│  TEAM WIG (Set by BH, Approved by BM)                                       │
│  "From Rp 750M to Rp 1.1B team premium by Dec 2025"                         │
│                               │                                              │
│                               │ contribution                                 │
│                               ▼                                              │
│  INDIVIDUAL CONTRIBUTION (RM)                                                │
│  Progress tracked via Lead/Lag measures                                      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Cascade Rules

| Level | Max WIGs | Set By | Approved By | Visibility |
|-------|----------|--------|-------------|------------|
| Company | 2 | Director | Board | All |
| Regional | 2 | ROH | Director | Regional + below |
| Branch | 2 | BM | ROH | Branch + below |
| Team | 2 | BH | BM | Team members |

### Aggregate Validation

```
RULE: Sum of child WIG targets ≥ Parent WIG target

Example:
Company WIG Target: Rp 75B
└── Regional WIG Targets (sum): Rp 78B ✅ (> 75B, valid)
    ├── North: Rp 22B
    ├── Central: Rp 28B
    └── South: Rp 28B
```

---

## 📝 WIG Format

### Standard Format

**"From [Baseline] to [Target] by [Deadline]"**

### Components

| Component | Description | Example |
|-----------|-------------|---------|
| **From** | Current baseline value | Rp 50B |
| **To** | Target value | Rp 75B |
| **By** | Deadline | Dec 2025 |

### Good vs Bad WIG Examples

| ❌ Bad WIG | ✅ Good WIG | Why |
|-----------|------------|-----|
| "Increase sales" | "From Rp 50B to Rp 75B by Dec 2025" | Specific, measurable |
| "Get more customers" | "From 100 to 150 active customers by Mar 2025" | Clear baseline & target |
| "Improve performance" | "From 80 to 95 average team score by Feb 2025" | Quantifiable |

---

## 🎯 WIG Types

### Lag-Based WIGs (Results)

| Type | Example WIG | Measure Code |
|------|-------------|--------------|
| Revenue | From Rp 50B to Rp 75B annual premium by Dec 2025 | `premium_won` |
| Growth | From 100 to 150 active customers by Q2 2025 | `customer_count` |
| Conversion | From 40% to 60% pipeline win rate by Q4 2025 | `win_rate` |
| Retention | From 85% to 95% policy renewal rate by Dec 2025 | `renewal_rate` |

### Lead-Based WIGs (Activities)

| Type | Example WIG | Measure Code |
|------|-------------|--------------|
| Activity | From 20 to 30 customer visits per RM per week | `visit_count` |
| Coverage | From 60% to 100% HVC customers visited monthly | `hvc_coverage` |
| Quality | From 70% to 90% GPS-verified activities | `gps_verified_rate` |
| Pipeline | From 5 to 10 new pipelines created per RM per week | `pipeline_created` |

---

## 📊 WIG Creation Workflow

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         WIG CREATION WORKFLOW                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   1. CREATE                    2. SUBMIT                 3. APPROVE         │
│  ┌──────────────┐            ┌──────────────┐          ┌──────────────┐     │
│  │ Owner fills  │  ───────▶  │ Submit for   │  ──────▶ │ Approver     │     │
│  │ WIG form     │            │ approval     │          │ reviews      │     │
│  └──────────────┘            └──────────────┘          └──────┬───────┘     │
│                                                                │             │
│                                          ┌─────────────────────┼─────────┐   │
│                                          │                     │         │   │
│                                          ▼                     ▼         │   │
│                               ┌──────────────┐      ┌──────────────┐    │   │
│                               │ ❌ REJECTED   │      │ ✅ APPROVED   │    │   │
│                               │ with feedback│      │               │    │   │
│                               └──────┬───────┘      └──────┬───────┘    │   │
│                                      │                     │            │   │
│                                      ▼                     ▼            │   │
│                               ┌──────────────┐      ┌──────────────┐    │   │
│                               │ Revise and   │      │ WIG ACTIVE   │    │   │
│                               │ resubmit     │      │ Tracking     │    │   │
│                               └──────────────┘      │ begins       │    │   │
│                                                     └──────────────┘    │   │
│                                                                         │   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### WIG Creation Form

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CREATE NEW WIG                                            [Cancel] [Save]  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  BASIC INFO                                                                  │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  Title *                                                              │   │
│  │  [Annual Premium Target 2025                                       ]  │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  Description                                                          │   │
│  │  [Increase total premium achievement for fiscal year 2025           ]  │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  WIG STATEMENT                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                      │
│  │  From *      │  │  To *        │  │  By *        │                      │
│  │  [50,000,000]│  │  [75,000,000]│  │  [Dec 2025]  │                      │
│  │  (Rp Juta)   │  │  (Rp Juta)   │  │  (Date)      │                      │
│  └──────────────┘  └──────────────┘  └──────────────┘                      │
│                                                                              │
│  MEASURE LINK                                                                │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  Type *:        [v] Lag Measure                                       │   │
│  │  Measure *:     [v] Premium Won (premium_won)                         │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  PARENT WIG (Optional, for cascade)                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  [v] Company Premium Target 2025                                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│                                              [Save Draft] [Submit for Review]│
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📈 WIG Tracking

### Progress Visualization

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  WIG PROGRESS CARD                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  🎯 Annual Premium Target 2025                               Status: 🟢     │
│  ─────────────────────────────────────────────────────────────────────      │
│                                                                              │
│  Progress: ███████████████████░░░░░░░░░░░  62.5%                            │
│                                                                              │
│  ┌───────────────┐    ┌───────────────┐    ┌───────────────┐               │
│  │   BASELINE    │    │    CURRENT    │    │    TARGET     │               │
│  │    Rp 50B     │ ▶  │   Rp 62.5B    │ ▶  │    Rp 75B     │               │
│  └───────────────┘    └───────────────┘    └───────────────┘               │
│                                                                              │
│  Gap to Target: Rp 12.5B                                                    │
│  Time Remaining: 7 months (210 days)                                        │
│  Required Run Rate: Rp 1.78B/month                                          │
│                                                                              │
│  Trend: ▲ +5.2% vs last month                                               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Status Indicators

| Status | Criteria | Color | Action Required |
|--------|----------|-------|-----------------|
| 🟢 On Track | ≥ 90% of expected progress | Green | Continue execution |
| 🟡 At Risk | 70-89% of expected progress | Yellow | Investigation needed |
| 🔴 Off Track | < 70% of expected progress | Red | Immediate intervention |
| ⚪ Not Started | 0% progress, within grace period | Gray | Awaiting start |

### Expected Progress Calculation

```
Expected Progress = (Days Elapsed / Total Days) × 100

Example:
- WIG Period: Jan 1 - Dec 31 (365 days)
- Today: July 1 (181 days elapsed)
- Expected Progress: (181/365) × 100 = 49.6%

If actual progress is 45%:
- Ratio: 45% / 49.6% = 90.7% → 🟢 On Track
```

---

## 🗄️ Database Schema

```sql
-- WIG Table
CREATE TABLE wigs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Basic info
  title VARCHAR(200) NOT NULL,
  description TEXT,
  
  -- Hierarchy
  level VARCHAR(20) NOT NULL,              -- COMPANY, REGIONAL, BRANCH, TEAM
  owner_id UUID NOT NULL REFERENCES users(id),
  parent_wig_id UUID REFERENCES wigs(id),  -- For cascade
  
  -- Measure link
  measure_type VARCHAR(20) NOT NULL,       -- LAG, LEAD
  measure_id UUID REFERENCES measure_definitions(id),
  
  -- WIG Statement
  baseline_value NUMERIC NOT NULL,
  target_value NUMERIC NOT NULL,
  current_value NUMERIC DEFAULT 0,
  
  -- Timeline
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  
  -- Workflow
  status VARCHAR(20) DEFAULT 'DRAFT',      -- DRAFT, PENDING_APPROVAL, APPROVED, REJECTED, ACTIVE, COMPLETED, CANCELLED
  submitted_at TIMESTAMPTZ,
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT,
  
  -- Progress tracking
  last_progress_update TIMESTAMPTZ,
  progress_percentage NUMERIC DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- WIG Progress History
CREATE TABLE wig_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  wig_id UUID NOT NULL REFERENCES wigs(id),
  recorded_date DATE NOT NULL,
  value NUMERIC NOT NULL,
  progress_percentage NUMERIC NOT NULL,
  status VARCHAR(20),                      -- ON_TRACK, AT_RISK, OFF_TRACK
  notes TEXT,
  recorded_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(wig_id, recorded_date)
);

-- Indexes
CREATE INDEX idx_wigs_owner ON wigs(owner_id);
CREATE INDEX idx_wigs_level ON wigs(level);
CREATE INDEX idx_wigs_status ON wigs(status);
CREATE INDEX idx_wigs_parent ON wigs(parent_wig_id);
CREATE INDEX idx_wig_progress_wig ON wig_progress(wig_id);
```

---

## ⚙️ Admin Configuration

### WIG Settings Panel

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  4DX SETTINGS > WIG Configuration                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  GENERAL SETTINGS                                                            │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                                                                       │   │
│  │  Max WIGs per Level                                                   │   │
│  │  ┌──────────┐                                                         │   │
│  │  │  [ 2 ]   │  (Recommended: 2, Max: 5)                              │   │
│  │  └──────────┘                                                         │   │
│  │                                                                       │   │
│  │  WIG Approval Workflow                                                │   │
│  │  [✓] Require approval for new WIGs                                   │   │
│  │  [✓] Notify approver via email                                       │   │
│  │  [✓] Auto-reject after 7 days pending                                │   │
│  │                                                                       │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  PROGRESS TRACKING                                                           │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                                                                       │   │
│  │  Progress Update Frequency                                            │   │
│  │  (•) Daily   ( ) Weekly   ( ) Monthly                                │   │
│  │                                                                       │   │
│  │  Auto-calculate from Measures                                         │   │
│  │  [✓] Enabled (WIG progress = linked measure progress)                │   │
│  │                                                                       │   │
│  │  Status Thresholds                                                    │   │
│  │  On Track:    [ 90 ]% or more of expected                            │   │
│  │  At Risk:     [ 70 ]% to [ 89 ]% of expected                         │   │
│  │  Off Track:   Below [ 70 ]% of expected                              │   │
│  │                                                                       │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  CASCADE VALIDATION                                                          │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                                                                       │   │
│  │  [✓] Require child WIGs sum ≥ parent WIG target                      │   │
│  │  [✓] Warn if child WIGs sum < 110% of parent (buffer)                │   │
│  │                                                                       │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│                                                         [Cancel] [Save]     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Configuration Options

| Setting | Options | Default | Description |
|---------|---------|---------|-------------|
| Max WIGs per level | 1-5 | 2 | Enforces focus discipline |
| Approval workflow | On/Off | On | Require supervisor approval |
| Progress frequency | Daily/Weekly/Monthly | Weekly | How often progress updated |
| Auto-calculate | On/Off | On | Calculate from linked measures |
| On Track threshold | 0-100% | 90% | Green status threshold |
| At Risk threshold | 0-100% | 70% | Yellow status threshold |
| Cascade validation | On/Off | On | Validate child ≥ parent |

---

## 📚 Related Documents

- [4DX Overview](4dx-overview.md) - Framework overview
- [Lead-Lag Measures](lead-lag-measures.md) - Scoring measures
- [Scoreboard Design](scoreboard-design.md) - Visual display
- [Cadence of Accountability](cadence-accountability.md) - Weekly meetings

---

*Dokumen ini adalah bagian dari LeadX CRM 4DX Framework Documentation - Updated January 2025*
