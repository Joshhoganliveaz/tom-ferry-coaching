---
phase: 2
slug: card-rendering-interactivity
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-25
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual browser testing (no JS test framework — single HTML file, no build) |
| **Config file** | none |
| **Quick run command** | Open `index.html` in browser, check console for errors |
| **Full suite command** | Open `index.html`, visually verify all 8 requirements |
| **Estimated runtime** | ~30 seconds (manual visual inspection) |

---

## Sampling Rate

- **After every task commit:** Open `index.html` in browser, verify no console errors, spot-check rendering
- **After every plan wave:** Full visual walkthrough of all 8 requirements
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 02-01-01 | 01 | 1 | CARD-01 | manual | Visual: card headers show name, status badge, version, date, URL | n/a | ⬜ pending |
| 02-01-02 | 01 | 1 | CARD-02 | manual | Visual: three health bars with color coding and labels | n/a | ⬜ pending |
| 02-01-03 | 01 | 1 | CARD-03 | manual | Visual: version history expands, newest-first | n/a | ⬜ pending |
| 02-01-04 | 01 | 1 | CARD-04 | manual | Visual: Up Next box shows only when data exists | n/a | ⬜ pending |
| 02-01-05 | 01 | 1 | CARD-05 | manual | Visual: priority scores on non-shipped cards only | n/a | ⬜ pending |
| 02-02-01 | 02 | 1 | NAV-01 | manual | Visual: summary stats counts match actual data | n/a | ⬜ pending |
| 02-02-02 | 02 | 1 | NAV-02 | manual | Click each filter tab, verify visible cards | n/a | ⬜ pending |
| 02-02-03 | 02 | 1 | NAV-03 | manual | Change sort, verify card order | n/a | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements. No test framework installation needed — this is a static HTML file tested by opening in a browser. The existing Phase 1 validation function (`validateProject()`) provides data-level sanity checks via console warnings.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Card headers render correctly | CARD-01 | No JS test framework; visual UI | Open index.html, verify each card shows name, colored status badge, version, date, clickable URL |
| Health bars show correct levels | CARD-02 | Visual color/width verification | Check 3 bars per card, verify enum maps to correct color (canyon/gold/olive) and width |
| Version history newest-first | CARD-03 | DOM order verification | Expand details on a card with multiple versions, confirm newest date is first |
| Up Next conditional render | CARD-04 | Presence/absence check | Compare card with upNext data (gold box visible) vs card without (no box) |
| Priority scores conditional | CARD-05 | Conditional by status | Verify shipped cards lack priority section; in_progress/parking_lot cards show scores |
| Summary stats accuracy | NAV-01 | Count verification | Manually count cards per status, compare to stats bar numbers |
| Filter tabs work | NAV-02 | Interactive behavior | Click each tab, verify only matching cards visible |
| Sort reorders cards | NAV-03 | DOM reorder verification | Change sort option, verify card order changes correctly |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
