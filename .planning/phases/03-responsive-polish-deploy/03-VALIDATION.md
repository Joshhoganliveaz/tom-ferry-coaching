---
phase: 3
slug: responsive-polish-deploy
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-25
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual browser testing (no JS test framework — vanilla HTML project) |
| **Config file** | none |
| **Quick run command** | Open `index.html` in Chrome DevTools responsive mode at 375px |
| **Full suite command** | Manual checklist verification |
| **Estimated runtime** | ~60 seconds (manual) |

---

## Sampling Rate

- **After every task commit:** Visual inspection in browser at 375px width
- **After every plan wave:** Full smoke test of deployed site
- **Before `/gsd:verify-work`:** All three requirements verified
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 03-01-01 | 01 | 1 | VIS-03 | manual | Chrome DevTools > Toggle device toolbar > iPhone SE (375px) | N/A | ⬜ pending |
| 03-01-02 | 01 | 1 | DEPLOY-02 | smoke | `curl -s -o /dev/null -w "%{http_code}" <github-pages-url>` | N/A | ⬜ pending |
| 03-01-03 | 01 | 1 | DEPLOY-03 | smoke | Edit projects.json, commit, push, curl after 60s | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

*Existing infrastructure covers all phase requirements.* No test framework needed for this vanilla HTML project. All verification is manual/smoke testing.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Cards stack vertically, stats wrap, no horizontal scroll at 375px | VIS-03 | Visual layout verification requires human judgment | Open index.html in Chrome DevTools, set viewport to 375px, verify card stacking and no horizontal scroll |
| Site live on GitHub Pages with auto-deploy | DEPLOY-02 | Requires external service verification | Push to main, verify site loads at GitHub Pages URL |
| Deploy visible within 60 seconds of push | DEPLOY-03 | Timing-dependent, requires real push cycle | Update projects.json, commit, push, poll URL for update within 60s |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
