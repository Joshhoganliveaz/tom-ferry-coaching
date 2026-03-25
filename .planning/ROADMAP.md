# Roadmap: Live AZ Co Project Tracker

## Overview

Ship a single-page project portfolio tracker that Josh can pull up on coaching calls with Jeff Bannan. The build follows a strict dependency chain: data schema and seed data first (everything renders from JSON), then all visual components and interactivity, then responsive polish and GitHub Pages deployment. Three phases, each producing a verifiable artifact.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Data Foundation + Scaffold** - JSON schema, seed data, HTML skeleton with branding, fetch-parse pipeline
- [ ] **Phase 2: Card Rendering + Interactivity** - Project cards, health bars, summary stats, filter/sort controls
- [ ] **Phase 3: Responsive Polish + Deploy** - Mobile layout, GitHub Pages deployment, maintenance workflow

## Phase Details

### Phase 1: Data Foundation + Scaffold
**Goal**: A branded HTML page loads real project data from an external JSON file with validation and cache-busting
**Depends on**: Nothing (first phase)
**Requirements**: DATA-01, DATA-02, DATA-03, DATA-04, DATA-05, VIS-01, VIS-02, DEPLOY-01
**Success Criteria** (what must be TRUE):
  1. Opening index.html in a browser shows a branded page with Live AZ Co colors and fonts (Olive/Canyon/Gold/Cream/Charcoal, Source Serif 4 + DM Sans)
  2. The page fetches projects.json with cache-busting so a hard refresh always shows current data
  3. projects.json contains accurate seed data for all ~16 projects with correct versions, dates, health scores, and deploy URLs
  4. Console shows validation warnings if any project entry has malformed or missing fields
  5. Footer displays the timestamp of when projects.json was last loaded
**Plans**: TBD

Plans:
- [ ] 01-01: TBD
- [ ] 01-02: TBD

### Phase 2: Card Rendering + Interactivity
**Goal**: All project data renders as interactive cards with health bars, version history, priority scores, summary stats, and filter/sort controls
**Depends on**: Phase 1
**Requirements**: CARD-01, CARD-02, CARD-03, CARD-04, CARD-05, NAV-01, NAV-02, NAV-03
**Success Criteria** (what must be TRUE):
  1. Each project displays as a card with name, status badge (color-coded shipped/in_progress/parking_lot), version, deployed date, and clickable deploy URL
  2. Three health bars per card (Adoption, Autonomy, Revenue Proximity) show color-coded progress with human-readable labels
  3. Summary stats bar at top shows live counts by status and health dimensions, computed dynamically from the data
  4. Clicking filter tabs (All / Shipped / In Progress / Parking Lot) shows only matching cards; sort options reorder visible cards
  5. Version history expands per card showing entries newest-first; "Up Next" box appears only when data exists; priority scores appear only on unshipped projects
**Plans**: TBD

Plans:
- [ ] 02-01: TBD
- [ ] 02-02: TBD

### Phase 3: Responsive Polish + Deploy
**Goal**: The tracker is deployed on GitHub Pages with a responsive layout that works on phones during coaching calls
**Depends on**: Phase 2
**Requirements**: VIS-03, DEPLOY-02, DEPLOY-03
**Success Criteria** (what must be TRUE):
  1. On a 375px mobile viewport, cards stack vertically and the summary stats bar wraps gracefully with no horizontal scroll
  2. The site is live on GitHub Pages at a bookmarkable URL, auto-deploying on push to main
  3. Claude Code can update projects.json, commit, and push to trigger a deploy that is visible within 60 seconds of the push completing
**Plans**: TBD

Plans:
- [ ] 03-01: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Data Foundation + Scaffold | 0/2 | Not started | - |
| 2. Card Rendering + Interactivity | 0/2 | Not started | - |
| 3. Responsive Polish + Deploy | 0/1 | Not started | - |
