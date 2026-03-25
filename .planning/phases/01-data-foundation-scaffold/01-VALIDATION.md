---
phase: 1
slug: data-foundation-scaffold
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-25
---

# Phase 1 -- Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual browser verification (no test framework -- zero-dependency single HTML file) |
| **Config file** | None -- static HTML project |
| **Quick run command** | `python3 -m http.server 8000` then open `http://localhost:8000` |
| **Full suite command** | Open in browser + check console for validation warnings |
| **Estimated runtime** | ~5 seconds |

---

## Sampling Rate

- **After every task commit:** Run `python3 -m http.server 8000` and open in browser
- **After every plan wave:** Full visual check + console inspection
- **Before `/gsd:verify-work`:** All 8 requirements visually verified
- **Max feedback latency:** 5 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 1-01-01 | 01 | 1 | DATA-01 | manual | Open browser, check no validation warnings | N/A | ⬜ pending |
| 1-01-02 | 01 | 1 | DATA-02 | semi-auto | `python3 -c "import json; d=json.load(open('projects.json')); print(len(d['projects']), 'projects')"` | N/A | ⬜ pending |
| 1-01-03 | 01 | 1 | DATA-03 | manual | Open Network tab, verify `?v=` param on projects.json | N/A | ⬜ pending |
| 1-01-04 | 01 | 1 | DATA-04 | manual | Corrupt a field in projects.json, reload, check console | N/A | ⬜ pending |
| 1-01-05 | 01 | 1 | DATA-05 | manual | Visual check -- footer displays date/time | N/A | ⬜ pending |
| 1-02-01 | 02 | 1 | VIS-01 | manual | Visual check -- Olive/Canyon/Gold/Cream/Charcoal visible | N/A | ⬜ pending |
| 1-02-02 | 02 | 1 | VIS-02 | manual | DevTools > Computed > font-family shows Source Serif 4 / DM Sans | N/A | ⬜ pending |
| 1-02-03 | 02 | 1 | DEPLOY-01 | semi-auto | `ls` shows only index.html + projects.json (+ README) | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `projects.json` -- must be created with full schema and seed data
- [ ] `index.html` -- must be created with HTML skeleton, CSS branding, and fetch pipeline

*If none: "Existing infrastructure covers all phase requirements."*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Brand colors applied correctly | VIS-01 | Visual design judgment | Inspect page, verify Olive/Canyon/Gold/Cream/Charcoal CSS custom properties |
| Correct fonts loaded | VIS-02 | Font rendering is visual | DevTools > Elements > Computed > font-family |
| Cache-busting works | DATA-03 | Requires browser Network tab | Open DevTools > Network, reload, verify `?v=` on projects.json |
| Validation warnings on bad data | DATA-04 | Requires intentional data corruption | Edit projects.json to remove a field, reload, check console |

---

## Validation Sign-Off

- [ ] All tasks have manual verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without verification
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 5s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
