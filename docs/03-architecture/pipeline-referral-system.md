# 🔄 Pipeline Referral System

## Mekanisme Referral Pipeline Antar RM

---

## 📋 Overview

Pipeline Referral adalah mekanisme untuk **memindahkan prospek** dari satu RM ke RM lain dengan proses handshake yang memastikan kedua belah pihak setuju, dan approval dari Manager (BM atau ROH).

### Use Cases

| Scenario | Example |
|----------|---------|
| **Territory Mismatch** | Customer lokasi di luar area RM |
| **Expertise Required** | Butuh RM dengan keahlian COB tertentu |
| **Capacity Overflow** | RM terlalu banyak pipeline |
| **Relationship** | RM lain punya hubungan lebih baik dengan customer |

---

## 🔄 Referral Workflow

### Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       PIPELINE REFERRAL WORKFLOW                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │ STEP 1: REFERRER RM Creates Referral                                    ││
│  │                                                                          ││
│  │  RM Ahmad has a customer outside his territory.                         ││
│  │  He creates a referral to RM Budi who covers that area.                ││
│  │                                                                          ││
│  │  Required info: Customer, COB, LOB, Est. Premium, Target RM, Reason    ││
│  │                                                                          ││
│  │  Status: PENDING_RECEIVER                                                ││
│  └──────────────────────────────────────┬──────────────────────────────────┘│
│                                         │                                    │
│                                         ▼                                    │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │ STEP 2: RECEIVER RM Reviews & Responds                                  ││
│  │                                                                          ││
│  │  RM Budi receives notification of incoming referral.                    ││
│  │  He can view customer details and decide:                               ││
│  │                                                                          ││
│  │  ┌─────────────────┐         ┌─────────────────┐                        ││
│  │  │   ❌ REJECT     │         │   ✅ ACCEPT     │                        ││
│  │  │ (with reason)   │         │                 │                        ││
│  │  └────────┬────────┘         └────────┬────────┘                        ││
│  │           │                           │                                  ││
│  │           ▼                           ▼                                  ││
│  │  Status: RECEIVER_REJECTED    Status: RECEIVER_ACCEPTED                 ││
│  │  (END - notify referrer)      (continue to Step 3)                      ││
│  └──────────────────────────────────────┬──────────────────────────────────┘│
│                                         │                                    │
│                                         ▼                                    │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │ STEP 3: MANAGER (BM/ROH) Approval                                        ││
│  │                                                                          ││
│  │  The designated approver receives the approval request:                 ││
│  │  • If receiver has a BM in hierarchy → BM approves                      ││
│  │  • If receiver has no BM (kanwil RM) → ROH approves                     ││
│  │                                                                          ││
│  │  Approver reviews the referral details:                                 ││
│  │  • Customer information                                                  ││
│  │  • Estimated premium value                                               ││
│  │  • Referrer confirmation                                                 ││
│  │  • Receiver acceptance                                                   ││
│  │                                                                          ││
│  │  ┌─────────────────┐         ┌─────────────────┐                        ││
│  │  │   ❌ REJECT     │         │   ✅ APPROVE    │                        ││
│  │  │ (with reason)   │         │                 │                        ││
│  │  └────────┬────────┘         └────────┬────────┘                        ││
│  │           │                           │                                  ││
│  │           ▼                           ▼                                  ││
│  │  Status: BM_REJECTED          Status: APPROVED                          ││
│  │  (END - notify both)          (continue to Step 4)                      ││
│  └──────────────────────────────────────┬──────────────────────────────────┘│
│                                         │                                    │
│                                         ▼                                    │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │ STEP 4: PIPELINE CREATED                                                 ││
│  │                                                                          ││
│  │  System automatically creates pipeline:                                  ││
│  │  • Customer: From referral                                               ││
│  │  • Assigned RM: Receiver                                                 ││
│  │  • Lead Source: REFERRAL                                                 ││
│  │  • Referred By: Referrer RM                                              ││
│  │  • Initial Stage: NEW                                                    ││
│  │                                                                          ││
│  │  Status: PIPELINE_CREATED                                                ││
│  │                                                                          ││
│  │  🎁 REFERRER BONUS:                                                     ││
│  │  When pipeline reaches ACCEPTED (won), referrer gets bonus points       ││
│  │  based on final_premium × referral_bonus_percentage                     ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 👤 Approver Determination

The system automatically determines who should approve the referral based on the receiver RM's organizational position:

| Scenario | Approver | `approver_type` |
|----------|----------|-----------------|
| Receiver has a branch with BM in hierarchy | BM of receiver | `BM` |
| Receiver has a branch but no BM in hierarchy | ROH of receiver's region | `ROH` |
| Receiver is at kanwil level (no branch) | ROH of receiver's region | `ROH` |

### Approver Lookup Logic

```
1. Check if receiver RM has a branch_id
2. If yes, search user_hierarchy for ancestor with role = 'BM'
3. If BM found → approver_type = 'BM'
4. If no BM found (or no branch):
   a. Search user_hierarchy for ancestor with role = 'ROH'
   b. If not found, find ROH by matching regional_office_id
   c. approver_type = 'ROH'
```

> **Note**: The `approver_type` is determined at referral creation time and stored in the `pipeline_referrals` table.

---

## 📊 Status Definitions

| Status | Description | Next Actions |
|--------|-------------|--------------|
| `PENDING_RECEIVER` | Referral created, waiting for receiver response | Receiver: Accept/Reject |
| `RECEIVER_ACCEPTED` | Receiver accepted, waiting for manager approval | BM/ROH: Approve/Reject |
| `RECEIVER_REJECTED` | Receiver declined the referral | **END STATE** |
| `PENDING_BM_APPROVAL` | Same as RECEIVER_ACCEPTED (alias) | BM/ROH: Approve/Reject |
| `BM_REJECTED` | Manager (BM or ROH) declined the referral | **END STATE** |
| `APPROVED` | All parties agreed | System: Create Pipeline |
| `PIPELINE_CREATED` | Pipeline has been created | **END STATE** |
| `CANCELLED` | Referrer cancelled before completion | **END STATE** |
| `EXPIRED` | No response within timeout period | **END STATE** |

> **Note**: Status names use "BM" for backward compatibility, but the actual approver may be BM or ROH based on `approver_type`.

---

## ⏱️ Timeout Rules

| Stage | Timeout | Action |
|-------|---------|--------|
| Receiver Response | 48 hours | Auto-cancel, notify referrer |
| Manager Approval (BM) | 24 hours | Escalate to ROH notification |
| Manager Approval (ROH) | 24 hours | Escalate to Admin notification |
| Overall | 7 days | Auto-expire referral |

> **Note**: Escalation differs based on `approver_type`. If ROH is already the approver, escalation goes to Admin.

---

## 🎁 Scoring & Bonus

### Referrer Bonus (Configurable in Admin)

When a pipeline from referral is **WON** (stage = ACCEPTED):

```
Referrer Bonus = Final Premium × Referral Bonus %

Example:
- Final Premium: Rp 100.000.000
- Referral Bonus %: 5%
- Referrer Bonus: Rp 5.000.000 (points equivalent)
```

### 4DX Impact

| Measure | Referrer | Receiver |
|---------|----------|----------|
| NEW_PIPELINE | ❌ | ✅ (counts for receiver) |
| PIPELINE_WON | ❌ | ✅ (counts for receiver) |
| PREMIUM_WON | ❌ | ✅ (counts for receiver) |
| REFERRAL_BONUS | ✅ (bonus score) | ❌ |

---

## 🗄️ Database Schema

```sql
CREATE TABLE pipeline_referrals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(20) UNIQUE NOT NULL, -- REF-YYYYMMDD-XXX

  -- Customer & Business Info
  customer_id UUID NOT NULL REFERENCES customers(id),
  cob_id UUID NOT NULL REFERENCES cob(id),
  lob_id UUID NOT NULL REFERENCES lob(id),
  potential_premium DECIMAL(18,2) NOT NULL,

  -- Parties Involved
  referrer_rm_id UUID NOT NULL REFERENCES users(id),
  receiver_rm_id UUID NOT NULL REFERENCES users(id),

  -- Branch (nullable for kanwil-level RMs)
  referrer_branch_id UUID REFERENCES branches(id),      -- nullable
  receiver_branch_id UUID REFERENCES branches(id),      -- nullable

  -- Regional Office (for ROH fallback approval)
  referrer_regional_office_id UUID REFERENCES regional_offices(id),
  receiver_regional_office_id UUID REFERENCES regional_offices(id),

  -- Approver Type (determined at creation based on receiver's hierarchy)
  approver_type VARCHAR(10) NOT NULL DEFAULT 'BM' CHECK (approver_type IN ('BM', 'ROH')),

  -- Referral Details
  reason TEXT NOT NULL,
  notes TEXT,

  -- Status Tracking
  status VARCHAR(30) NOT NULL DEFAULT 'PENDING_RECEIVER',

  -- Receiver Response
  receiver_accepted_at TIMESTAMPTZ,
  receiver_rejected_at TIMESTAMPTZ,
  receiver_reject_reason TEXT,
  receiver_notes TEXT,

  -- Manager Approval (BM or ROH based on approver_type)
  bm_approved_at TIMESTAMPTZ,
  bm_approved_by UUID REFERENCES users(id),
  bm_rejected_at TIMESTAMPTZ,
  bm_reject_reason TEXT,
  bm_notes TEXT,

  -- Result
  pipeline_id UUID REFERENCES pipelines(id),
  bonus_calculated BOOLEAN DEFAULT FALSE,
  bonus_amount DECIMAL(18,2),

  -- Timestamps
  expires_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  cancel_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_referrals_referrer ON pipeline_referrals(referrer_rm_id);
CREATE INDEX idx_referrals_receiver ON pipeline_referrals(receiver_rm_id);
CREATE INDEX idx_referrals_status ON pipeline_referrals(status);
CREATE INDEX idx_referrals_customer ON pipeline_referrals(customer_id);

-- RLS Policies
ALTER TABLE pipeline_referrals ENABLE ROW LEVEL SECURITY;

-- Users can see referrals they're involved in
CREATE POLICY "referral_participant_view" ON pipeline_referrals
FOR SELECT USING (
  referrer_rm_id = (SELECT auth.uid())
  OR receiver_rm_id = (SELECT auth.uid())
  OR EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND (
      descendant_id = pipeline_referrals.referrer_rm_id
      OR descendant_id = pipeline_referrals.receiver_rm_id
    )
  )
);
```

---

## 📱 UI Components

### Referrer View

```
┌─────────────────────────────────────────────────────────────────┐
│  MY REFERRALS                                      [+ New Referral]│
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Outgoing (I referred)                                          │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  REF-20250120-001                                         │  │
│  │  Customer: PT ABC Indonesia                               │  │
│  │  To: Budi Santoso (JKT-02)                               │  │
│  │  Premium: Rp 500.000.000                                  │  │
│  │  Status: ⏳ Waiting Manager Approval                       │  │
│  │  [View Details]                                           │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Incoming (Referred to me)                                      │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  REF-20250119-003                                         │  │
│  │  Customer: PT XYZ Corp                                    │  │
│  │  From: Ahmad (JKT-01)                                     │  │
│  │  Premium: Rp 200.000.000                                  │  │
│  │  Status: 📩 Action Required                               │  │
│  │  [Accept] [Reject]                                        │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Manager Approval Dashboard (BM/ROH)

```
┌─────────────────────────────────────────────────────────────────┐
│  REFERRALS PENDING MY APPROVAL                [Manager Dashboard]│
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  ⚠️ REF-20250120-001               Pending 2 hours        │  │
│  │                                                           │  │
│  │  From: Ahmad (JKT-01) → To: Budi (JKT-02)                │  │
│  │  Customer: PT ABC Indonesia                               │  │
│  │  COB: Surety Bond | LOB: Bid Bond                        │  │
│  │  Premium: Rp 500.000.000                                  │  │
│  │                                                           │  │
│  │  Reason: "Customer location outside my territory..."      │  │
│  │                                                           │  │
│  │  ✅ Referrer Confirmed | ✅ Receiver Accepted             │  │
│  │                                                           │  │
│  │  [View Customer] [❌ Reject] [✅ Approve]                 │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📚 Related Documents

- [Role & Permission](role-permission-system.md)
- [Schema Overview](../04-database/schema-overview.md)
- [Screen Flows](../05-ui-ux/screen-flows.md)
- [4DX Lead-Lag Measures](../07-4dx-framework/lead-lag-measures.md)

---

*Dokumen ini adalah bagian dari LeadX CRM Business Process Documentation.*
