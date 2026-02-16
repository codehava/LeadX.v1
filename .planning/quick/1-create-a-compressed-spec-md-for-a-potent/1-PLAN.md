---
phase: quick
plan: 1
type: execute
wave: 1
depends_on: []
files_modified:
  - .planning/ITERATION-SPEC.md
autonomous: true
must_haves:
  truths:
    - "A single markdown file captures the full project spec, requirements, architecture, GSD iteration results, and lessons learned"
    - "The spec is readable by a future Claude instance without access to the .planning directory"
    - "Lessons learned are actionable and specific, not generic advice"
  artifacts:
    - path: ".planning/ITERATION-SPEC.md"
      provides: "Compressed iteration spec for v6 planning"
      contains: "## Lessons Learned"
  key_links: []
---

<objective>
Create a single compressed spec document (.planning/ITERATION-SPEC.md) that captures everything a future GSD-based iteration would need: what LeadX is, the full requirements (validated + active + remaining), the architecture and tech decisions, what was accomplished across 5 completed phases (16 plans, 2.7 hours), key patterns established, lessons learned from deviations/UAT/bugs, and recommendations for the next iteration.

Purpose: Enable a sixth GSD iteration to start with full context without needing to read 17 SUMMARY files, 5 RESEARCH files, 2 UAT files, STATE.md, PROJECT.md, and ROADMAP.md separately.
Output: .planning/ITERATION-SPEC.md
</objective>

<execution_context>
@C:/Users/cartr/.claude/get-shit-done/workflows/execute-plan.md
@C:/Users/cartr/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create comprehensive ITERATION-SPEC.md</name>
  <files>.planning/ITERATION-SPEC.md</files>
  <action>
Create .planning/ITERATION-SPEC.md with the following sections. This is a DENSE reference document, not documentation prose. Compress ruthlessly -- favor tables, lists, and structured data over paragraphs.

**## Project Identity**
- What LeadX is (1-2 sentences)
- Core value proposition (1 sentence)
- Target users and environment (field sales, poor connectivity)
- Tech stack table: Flutter + Supabase + Drift + Riverpod + Freezed + GoRouter

**## Architecture Summary**
- Clean Architecture layers (presentation/domain/data) with key conventions
- Offline-first pattern: write local -> queue sync -> push when online -> UI reads local only
- Code generation dependency chain (Freezed, Riverpod, Drift, JSON serialization)
- Database: 30+ Drift tables mirroring Supabase PostgreSQL, migration versioning at v10

**## Requirements Status**
Three tables:
1. **Validated** (shipped): Auth, RBAC, Customer CRUD, Key Person, Pipeline, Activity, HVC, Broker, 4DX scoring, Admin panel, etc.
2. **Active** (in progress): Reliable sync, conflict resolution, offline UX, typed errors, queue pruning, stubbed feature completion
3. **Out of Scope**: No new features beyond stubs, no CI/CD, no analytics, no OAuth, no real-time collab

**## Completed Phases (v5 Iteration)**

For EACH of the 5 completed phases, capture in a compressed row/block:
- Phase name, plan count, total duration
- What was accomplished (bullet list of concrete deliverables)
- Key files created/modified
- Important decisions with rationale (table format)

Phases to document:
1. **Phase 01: Foundation & Observability** (3 plans, 41 min) -- SyncError hierarchy, schema v10 standardization, Sentry integration, Talker logging replacing 266+ debugPrint
2. **Phase 02: Sync Engine Core** (3 plans, 19 min) -- Queue coalescing (4 rules), 500ms debounced triggers, atomic Drift transactions (42 write methods across 8 repos), incremental per-entity sync timestamps with 30s safety margin
3. **Phase 02.1: Pre-existing Bug Fixes** (3 plans, 14 min) -- UTC timestamp serialization (toUtcIso8601 extension, 88+61 fixes), SearchableDropdown replacing AutocompleteField (11 fields), date-only field handling
4. **Phase 03: Error Classification & Recovery** (3 plans, 37 min) -- Sealed Result type, mapException/runCatching, Customer+Pipeline+Activity repo migration, OfflineBanner, AppErrorState
5. **Phase 03.1: Remaining Repo Result Migration** (5 plans, 64 min) -- 7 remaining repos migrated, dartz fully removed, auth test suite rebuilt with mocktail Fakes

**## Remaining Phases (v6 Scope)**

For each remaining phase (4-10), capture from ROADMAP.md:
- Goal, dependencies, success criteria
- Current plan status (planned vs TBD)

**## Established Patterns** (critical for v6 consistency)

Table of pattern name -> description -> where established:
- Sealed class hierarchies (SyncError, Result type)
- runCatching vs explicit try/catch+mapException decision matrix
- Atomic Drift transactions wrapping local write + queue insert
- triggerSync() outside transactions (fire-and-forget)
- Per-entity incremental sync with 30s safety margin
- toUtcIso8601() for all sync timestamps, substring(0,10) for DATE-only
- SearchableDropdown for all form dropdowns (modal bottom sheet)
- OfflineBanner + AppErrorState for offline-aware screens
- AppLogger with module prefixes (sync.queue, sync.push, etc.)
- Repository constructor injection pattern (_database field)
- StreamProvider + Drift .watch() for reactive UI (no manual invalidation)
- Lookup cache invalidation pattern (invalidateCaches() after sync pull)

**## Key Decisions Registry**

Single table consolidating ALL decisions from STATE.md (there are ~40+). Group by category:
- Architecture decisions
- Error handling decisions
- Sync engine decisions
- UI/UX decisions
- Testing decisions

**## Lessons Learned**

This is the most important section. Extract from deviations, UAT gaps, and execution patterns:

### From UAT Failures
- Phase 02 UAT revealed 2 PRE-EXISTING bugs (timezone serialization, dropdown race condition) that required inserting Phase 02.1. Lesson: UAT catches pre-existing bugs, not just new regressions. Budget for inserted phases.
- Timezone bug: 86+ bare .toIso8601String() calls across 9 repos. Lesson: Centralize serialization helpers EARLY. A convention without enforcement (extension method) would have prevented this.
- Dropdown bug: AutocompleteField had a 200ms focus/tap race condition affecting all 11 form fields. Lesson: Prefer modal patterns over overlay patterns for selection UIs on mobile.

### From Execution Deviations
- Total deviations across 16 plans: ~20 auto-fixed issues. Categories:
  - **Blocking (Rule 3)**: Constructor changes requiring provider/test updates not in plan scope (most common)
  - **Missing Critical (Rule 2)**: Methods/files not identified in plan but required for completeness
  - **Bug Fixes (Rule 1)**: Pre-existing bugs discovered during related work
- Lesson: Plans that change interfaces (constructor params, return types) ALWAYS have downstream consumer updates. Plan for them explicitly.
- Lesson: Auto-fix rules (Rule 1-3) are essential -- Claude catches and fixes cascading issues during execution. Strict plan adherence would leave broken code.

### From Performance Data
- Average plan duration: 10 min (fastest: 3 min for Sentry, slowest: 35 min for auth test rewrite)
- Auth repository migration (03.1-03) was 4x slower due to pre-existing broken test suite requiring full rewrite with Fakes
- Lesson: Pre-existing test debt multiplies migration effort. Identify and budget for broken tests BEFORE planning migration scope.
- Lesson: Supabase types implementing Future break both mockito and mocktail. Use custom Fake classes with Future delegation.

### From Phase Insertions
- Both 02.1 and 03.1 were INSERTED phases not in original roadmap
- 02.1: Pre-existing bugs surfaced during UAT
- 03.1: Scope underestimate -- original Phase 3 only migrated 3 repos, leaving 7 repos + dartz dependency
- Lesson: Plan for "completion phases" after partial migrations. If migrating a pattern, budget for ALL instances, not just the core ones.

### From GSD Framework Usage
- 2-3 tasks per plan works well. Never exceeded context budget.
- Vertical slice approach worked for repo migrations (each plan = one repo end-to-end)
- SUMMARY.md frontmatter (dependency graph, tech tracking) is valuable for cross-phase context
- Research phase before planning prevented wrong library choices (e.g., Talker v4 vs v5 constraint)

**## Metrics Summary**

| Metric | Value |
|--------|-------|
| Total phases completed | 5 (+ 2 inserted) |
| Total plans completed | 16 |
| Total execution time | 2.7 hours |
| Average plan duration | 10 min |
| Total files modified | ~120+ |
| Total deviations auto-fixed | ~20 |
| Test suites passing | 55+ repo tests |
| dartz dependency | REMOVED |
| debugPrint calls remaining | 0 |
| Bare .toIso8601String() in sync | 0 |

**## Recommendations for v6**

1. Start Phase 4 (Conflict Resolution) -- already planned with 2 plans
2. Phase 5 (Background Sync) needs research: WorkManager + iOS BGTaskScheduler
3. Phase 6 (Sync Coordination) may merge with Phase 5 -- evaluate during discuss-phase
4. Phase 7 (Offline UX) is mostly UI polish -- good candidate for parallel execution
5. Phases 8-9 (stubbed features) are independent of sync work -- could run parallel after Phase 3
6. Phase 10 (scoring) has lowest priority and fewest dependencies
7. Consider UAT checkpoints after Phase 4 and Phase 5 -- sync changes are highest risk
8. Pre-audit test health before Phase 5-6 -- broken tests cost 4x in auth migration
  </action>
  <verify>
    - File exists at .planning/ITERATION-SPEC.md
    - Contains all required sections: Project Identity, Architecture Summary, Requirements Status, Completed Phases, Remaining Phases, Established Patterns, Key Decisions Registry, Lessons Learned, Metrics Summary, Recommendations
    - File is self-contained (readable without other .planning files)
    - Lessons learned section has specific examples with phase references, not generic advice
  </verify>
  <done>
    A single markdown file exists that compresses the full project spec, 5-phase iteration results (16 plans, 2.7 hours), 40+ decisions, ~20 deviations, UAT findings, and actionable lessons learned into a portable reference document for the next GSD iteration.
  </done>
</task>

</tasks>

<verification>
- .planning/ITERATION-SPEC.md exists and is well-structured
- All 5 completed phases are represented with concrete deliverables
- Lessons learned trace back to specific plan/phase evidence
- Remaining phases 4-10 are captured with goals and dependencies
</verification>

<success_criteria>
A future Claude instance given only ITERATION-SPEC.md and the codebase can understand: what LeadX is, what has been built, how it was built, what patterns to follow, what mistakes to avoid, and what to build next.
</success_criteria>

<output>
After completion, create `.planning/quick/1-create-a-compressed-spec-md-for-a-potent/1-SUMMARY.md`
</output>
