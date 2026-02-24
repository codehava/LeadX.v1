---
status: testing
phase: 10-scoring-optimization
source: [10-01-SUMMARY.md, 10-02-SUMMARY.md, 10-03-SUMMARY.md]
started: 2026-02-23T15:00:00Z
updated: 2026-02-23T15:00:00Z
---

## Current Test

number: 1
name: Leaderboard Shows Real Rankings
expected: |
  Open the Scoreboard tab, then navigate to the Leaderboard screen. Each user entry should display a numeric rank (1, 2, 3...) and a rank change indicator (up/down arrow or dash for no change). No entries should show blank or null rank values.
awaiting: user response

## Tests

### 1. Leaderboard Shows Real Rankings
expected: Open the Scoreboard tab, then navigate to the Leaderboard screen. Each user entry should display a numeric rank (1, 2, 3...) and a rank change indicator (up/down arrow or dash for no change). No entries should show blank or null rank values.
result: [pending]

### 2. Leaderboard Role Filter
expected: On the Leaderboard screen, a row of role filter chips should appear: "Semua Jabatan", "RM", "BH", "BM", "ROH". Tapping a role chip (e.g., "RM") should filter the leaderboard to show only users with that role. Ranks re-compute within the filtered set. Tapping "Semua Jabatan" clears the role filter.
result: [pending]

### 3. Leaderboard Geography + Role Combined Filtering
expected: Select a Branch or Region filter, then also select a role filter (e.g., "BM"). The leaderboard should show only users matching both filters. Ranks should be computed within that subset.
result: [pending]

### 4. Score Update Pending Indicator
expected: On the Scoreboard screen, if there are pending sync items for activities, pipelines, or customers, a banner/indicator should appear saying something like "Score update pending" (or Indonesian equivalent). If no pending items, no indicator should appear.
result: [pending]

### 5. Scoreboard Error Handling
expected: On the Scoreboard and Leaderboard screens, if data fails to load (e.g., while offline with no cached data), a styled error state should appear (not raw red error text). It should match the AppErrorState pattern used elsewhere in the app.
result: [pending]

### 6. Admin Scoring Summary Navigation
expected: As an admin user, navigate to the 4DX management section. A "Ringkasan Skor" (Scoring Summary) card should be visible. Tapping it should navigate to the scoring summary grid screen.
result: [pending]

### 7. Scoring Summary Grid Display
expected: On the scoring summary screen, a grid/table is shown with user names as rows and measure names as column headers. Each cell displays the user's actual value and percentage for that measure. A "Total" column at the end shows the composite score, color-coded (green >= 75%, amber >= 50%, red < 50%).
result: [pending]

### 8. Scoring Summary Period Selector
expected: The scoring summary screen has a period selector (dropdown). Changing the period should reload the grid data for the selected period.
result: [pending]

### 9. Manager Scoring Summary (Subordinates Only)
expected: As a manager (BH/BM/ROH), navigate to the scoring summary. The grid should only show users who are subordinates of the current manager — not all company users.
result: [pending]

## Summary

total: 9
passed: 0
issues: 0
pending: 9
skipped: 0

## Gaps

[none yet]
