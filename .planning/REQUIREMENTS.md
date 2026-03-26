# Requirements: Live AZ Co Project Tracker

**Defined:** 2026-03-25
**Core Value:** Josh can pull up one URL on a coaching call and Jeff instantly sees what's shipped, what's in progress, and the health of each project.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Data Layer

- [x] **DATA-01**: projects.json schema supports all project fields (name, description, status, currentVersion, deployedUrl, deployedDate, health scores, versions array, upNext, priority)
- [x] **DATA-02**: Seed data pre-populated for all ~16 projects with accurate versions, dates, and health scores from CLAUDE.md and project memory
- [x] **DATA-03**: HTML fetches projects.json with cache-busting parameter to prevent stale data on coaching calls
- [x] **DATA-04**: Schema validation function logs warnings for malformed or missing fields in project entries
- [x] **DATA-05**: Footer displays build/data timestamp showing when projects.json was last loaded

### Project Cards

- [ ] **CARD-01**: Card header displays project name, status badge (shipped/in_progress/parking_lot), version badge, deployed date, and clickable deployed URL
- [ ] **CARD-02**: Three health progress bars per card (Adoption, Autonomy, Revenue Proximity) with color coding per spec (red/gold/olive) and human-readable text labels
- [ ] **CARD-03**: Expandable version history section per card showing versions newest-first with date and changelog notes
- [ ] **CARD-04**: "Up Next" box with gold highlight showing next planned version and notes (visible only when upNext data exists)
- [ ] **CARD-05**: Priority scores section (makesMoney, savesTime, servesClients, speedToFinish as 1-5 ranks) visible only on in_progress and parking_lot cards

### Summary & Navigation

- [ ] **NAV-01**: Summary stats bar at top showing counts: Shipped (olive), In Progress (gold), Fully Independent (olive), Josh-Dependent (gold), Client-Facing (olive)
- [ ] **NAV-02**: Filter tabs (All / Shipped / In Progress / Parking Lot) that show/hide cards by status
- [ ] **NAV-03**: Sort options (most recently deployed, autonomy level) that reorder visible cards

### Visual Design

- [x] **VIS-01**: Live AZ Co branding applied -- Olive (#5C6B4F), Canyon (#8B6F5C), Gold (#C9953E), Cream (#FAF7F2), Charcoal (#2C2C2C)
- [x] **VIS-02**: Source Serif 4 for headings, DM Sans for body text (loaded via Google Fonts)
- [ ] **VIS-03**: Responsive layout -- cards stack vertically on mobile (375px+), summary stats bar wraps gracefully

### Deployment

- [x] **DEPLOY-01**: Single HTML file (index.html) + separate projects.json, no build process or dependencies
- [ ] **DEPLOY-02**: GitHub Pages deployment from main branch, auto-deploys on push
- [ ] **DEPLOY-03**: Claude Code can update projects.json, commit, and push to trigger deploy in under 60 seconds

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Enhanced Interactivity

- **INT-01**: Keyboard shortcuts for filter tabs (1-4 keys)
- **INT-02**: Card expand/collapse animation (smooth transitions)
- **INT-03**: Search/filter by project name

### Analytics

- **ANAL-01**: Track which projects Jeff asks about most (click tracking)
- **ANAL-02**: Health score trend over time (historical snapshots)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Admin panel / UI editing | Claude Code is the sole editor per design decision |
| Database or backend | JSON file is the source of truth, zero complexity |
| Authentication | Obscure URL sufficient for 3-5 known viewers |
| Real-time updates | Static deploy, refresh to see changes |
| Charts or graphing libraries | Health bars are sufficient visual, no charting dependencies |
| Mobile app | Web-first, responsive is enough |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| DATA-01 | Phase 1 | Complete |
| DATA-02 | Phase 1 | Complete |
| DATA-03 | Phase 1 | Complete |
| DATA-04 | Phase 1 | Complete |
| DATA-05 | Phase 1 | Complete |
| CARD-01 | Phase 2 | Pending |
| CARD-02 | Phase 2 | Pending |
| CARD-03 | Phase 2 | Pending |
| CARD-04 | Phase 2 | Pending |
| CARD-05 | Phase 2 | Pending |
| NAV-01 | Phase 2 | Pending |
| NAV-02 | Phase 2 | Pending |
| NAV-03 | Phase 2 | Pending |
| VIS-01 | Phase 1 | Complete |
| VIS-02 | Phase 1 | Complete |
| VIS-03 | Phase 3 | Pending |
| DEPLOY-01 | Phase 1 | Complete |
| DEPLOY-02 | Phase 3 | Pending |
| DEPLOY-03 | Phase 3 | Pending |

**Coverage:**
- v1 requirements: 19 total
- Mapped to phases: 19
- Unmapped: 0

---
*Requirements defined: 2026-03-25*
*Last updated: 2026-03-25 after roadmap creation*
