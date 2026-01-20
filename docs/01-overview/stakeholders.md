# 👥 Stakeholders

## Stakeholder Analysis LeadX CRM

---

## 📋 Overview

Dokumen ini mengidentifikasi semua stakeholder yang terlibat dalam proyek LeadX CRM, termasuk peran, kepentingan, dan strategi engagement.

---

## 🗺️ Stakeholder Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         STAKEHOLDER INFLUENCE MAP                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  HIGH INFLUENCE                                                              │
│  │                                                                           │
│  │    ┌─────────────┐              ┌─────────────┐                          │
│  │    │   Project   │              │   Sales     │                          │
│  │    │   Sponsor   │              │   Head      │                          │
│  │    └─────────────┘              └─────────────┘                          │
│  │                                                                           │
│  │              ┌─────────────┐                                             │
│  │              │   IT Head   │                                             │
│  │              └─────────────┘                                             │
│  │                                                                           │
│  │                                                                           │
│  │    ┌─────────────┐              ┌─────────────┐                          │
│  │    │    ROH      │              │     BM      │                          │
│  │    └─────────────┘              └─────────────┘                          │
│  │                                                                           │
│  │                                        ┌─────────────┐                   │
│  │                                        │     BH      │                   │
│  │                                        └─────────────┘                   │
│  │                                                                           │
│  │                                              ┌─────────────┐             │
│  │                                              │     RM      │             │
│  │                                              └─────────────┘             │
│  │                                                                           │
│  LOW INFLUENCE ──────────────────────────────────────────────────────────── │
│                LOW INTEREST                              HIGH INTEREST       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 👔 Executive Stakeholders

### Project Sponsor
| Aspect | Details |
|--------|---------|
| **Role** | Budget approval, strategic decisions, escalation point |
| **Interest** | ROI, business impact, timeline adherence |
| **Influence** | Very High - Go/No-Go authority |
| **Engagement** | Monthly steering committee, milestone reviews |
| **Success Criteria** | Premium growth, sales efficiency improvement |

### Sales Head
| Aspect | Details |
|--------|---------|
| **Role** | Business requirements owner, adoption champion |
| **Interest** | Team productivity, target achievement, visibility |
| **Influence** | High - User acceptance authority |
| **Engagement** | Weekly status, UAT review, change management |
| **Success Criteria** | User adoption, activity increase, pipeline growth |

### IT Head
| Aspect | Details |
|--------|---------|
| **Role** | Technical oversight, security compliance, infrastructure |
| **Interest** | System reliability, security, integration |
| **Influence** | High - Technical approval |
| **Engagement** | Technical reviews, security audits, go-live approval |
| **Success Criteria** | System uptime, data security, performance |

---

## 👥 User Stakeholders

### Regional Office Head (ROH)
| Aspect | Details |
|--------|---------|
| **Count** | ~5 |
| **Role** | Regional performance monitoring, strategic cadence |
| **Interest** | Regional performance dashboard, target tracking |
| **Influence** | Medium-High - Regional rollout authority |
| **Engagement** | UAT participation, regional feedback |
| **Key Needs** | Regional dashboard, cross-branch comparison |

### Branch Manager (BM)
| Aspect | Details |
|--------|---------|
| **Count** | ~20 |
| **Role** | Branch performance management, branch cadence |
| **Interest** | Branch-level visibility, team accountability |
| **Influence** | Medium - Branch adoption champion |
| **Engagement** | Training facilitation, feedback collection |
| **Key Needs** | Branch dashboard, team activity monitoring |

### Business Head (BH)
| Aspect | Details |
|--------|---------|
| **Count** | ~50 |
| **Role** | Team supervision, daily monitoring, target setting |
| **Interest** | Team performance, individual RM tracking |
| **Influence** | Medium - First-line adoption driver |
| **Engagement** | UAT testing, day-to-day support |
| **Key Needs** | Team view, individual RM activities, scoreboard |

### Relationship Manager (RM)
| Aspect | Details |
|--------|---------|
| **Count** | ~300 |
| **Role** | Primary user - customer visit, pipeline management |
| **Interest** | Easy-to-use app, offline capability, quick data entry |
| **Influence** | High (collectively) - Adoption determines success |
| **Engagement** | Training, onboarding, feedback, support |
| **Key Needs** | Mobile-first, offline mode, GPS tracking, minimal input |

### Admin/Superadmin
| Aspect | Details |
|--------|---------|
| **Count** | ~5 |
| **Role** | System configuration, user management, master data |
| **Interest** | Admin efficiency, data accuracy |
| **Influence** | Low-Medium - Supporting role |
| **Engagement** | Admin training, configuration support |
| **Key Needs** | Web admin panel, bulk operations, reporting |

---

## 🛠️ Project Team

### Internal Team

| Role | Responsibility | Engagement |
|------|----------------|------------|
| **Project Manager** | Daily coordination, timeline, risk management | Daily |
| **Business Analyst** | Requirements, user stories, UAT coordination | Daily |
| **UX Designer** | UI/UX design, user research | Sprint-based |
| **QA Lead** | Testing strategy, quality assurance | Sprint-based |

### Development Team

| Role | Responsibility | Engagement |
|------|----------------|------------|
| **Tech Lead** | Architecture decisions, code review | Daily |
| **Flutter Developer (Ivan)** | Mobile app development | Daily |
| **Flutter Developer (Hanif)** | Mobile app development | Daily |
| **DevOps** | Infrastructure, CI/CD, monitoring | As needed |

---

## 📊 RACI Matrix

| Activity | Sponsor | Sales Head | IT Head | PM | Dev Team | Users |
|----------|---------|------------|---------|-----|----------|-------|
| Project Approval | **A** | C | C | R | I | I |
| Requirements Sign-off | I | **A** | C | R | C | C |
| Technical Design | I | I | **A** | C | R | I |
| Development | I | I | C | **A** | R | I |
| UAT | C | **A** | C | R | C | R |
| Go-Live Decision | **A** | R | R | R | C | I |
| Training | I | C | I | **A** | C | R |
| Support | I | I | C | **A** | R | R |

**Legend:** R=Responsible, A=Accountable, C=Consulted, I=Informed

---

## 📢 Communication Plan

### Stakeholder Communication

| Stakeholder | Channel | Frequency | Content |
|-------------|---------|-----------|---------|
| Project Sponsor | Steering Meeting | Monthly | Progress, risks, decisions |
| Sales Head | Status Meeting | Weekly | Features, adoption, feedback |
| IT Head | Technical Review | Bi-weekly | Architecture, security, infra |
| ROH/BM/BH | Email Update | Bi-weekly | Release notes, training |
| RM | In-app + WhatsApp | As needed | Tips, updates, support |
| Project Team | Daily Standup | Daily | Progress, blockers |

### Escalation Path

```
Level 1: Dev Team → Tech Lead
       ↓
Level 2: Tech Lead → Project Manager
       ↓
Level 3: PM → IT Head / Sales Head
       ↓
Level 4: IT/Sales Head → Project Sponsor
```

---

## 🎯 Change Management Strategy

### Adoption Approach

| Phase | Focus | Activities |
|-------|-------|------------|
| **Awareness** | Why change? | Town halls, executive messaging |
| **Understanding** | What changes? | Feature demos, roadshow |
| **Commitment** | Buy-in | Champion program, early wins |
| **Adoption** | How to use? | Training, hands-on practice |
| **Mastery** | Optimize | Advanced features, feedback loop |

### Champions Program

| Region | Champion | Role |
|--------|----------|------|
| Jakarta | TBD | Early adopter, trainer, feedback |
| West Java | TBD | Early adopter, trainer, feedback |
| Central Java | TBD | Early adopter, trainer, feedback |
| East Java | TBD | Early adopter, trainer, feedback |
| Sumatera | TBD | Early adopter, trainer, feedback |

---

## ⚠️ Risk by Stakeholder

| Stakeholder | Risk | Mitigation |
|-------------|------|------------|
| RM | Low adoption, resistance to change | Gamification, training, make it easier than Excel |
| BH | Overwhelmed by monitoring | Simplified dashboard, alerts only |
| IT | Security concerns | RLS, audit log, encryption |
| Sponsor | Budget overrun | Fixed scope, agile approach |

---

## 📚 Related Documents

- [Executive Summary](executive-summary.md)
- [Vision and Goals](vision-and-goals.md)
- [Success Metrics](success-metrics.md)

---

*Document version 1.0 - January 2025*
