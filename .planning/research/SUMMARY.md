# Project Research Summary

**Project:** Live AZ Co Project Tracker
**Domain:** Single-page static project portfolio tracker / coaching accountability dashboard
**Researched:** 2026-03-25
**Confidence:** HIGH

## Executive Summary

This is a zero-dependency, single HTML file + JSON data project deployed on GitHub Pages. The pattern is well-established -- Josh already ships the Tenet Commission Calculator with identical architecture. The primary audience is Josh and his Tom Ferry coach Jeff Bannan during weekly coaching calls, with secondary use as a team tool catalog. The product is a read-only dashboard that renders ~16 project cards with status badges, health scores, version history, and priority rankings from a `projects.json` file that Claude Code maintains directly.

The recommended approach is vanilla HTML/CSS/JS with no framework, no build step, and no dependencies beyond Google Fonts CDN. Data lives in a separate `projects.json` fetched at runtime, which cleanly separates the maintenance workflow (Claude Code edits JSON, pushes, GitHub Pages auto-deploys) from the presentation layer. All research sources strongly agree this scope does not warrant any framework -- React, Vue, Alpine, Tailwind, or even a CSS framework would add complexity without benefit for a single page rendering 16 cards.

The primary risks are operational, not technical: browser caching serving stale JSON during a live coaching call (solvable with cache-busting fetch), JSON schema drift as Claude Code makes updates without validation (solvable with defensive rendering + schema documentation), and mobile layout breakage when Jeff views on his phone (solvable with mobile-first CSS). None of these are hard problems, but all three must be addressed in the initial build -- retrofitting any of them is painful.

## Key Findings

### Recommended Stack

No npm, no build step, no framework. The entire application is `index.html` + `projects.json` served from GitHub Pages.

**Core technologies:**
- **Vanilla HTML5/CSS3/JS (ES2020+):** Full application in one file -- CSS Grid for layout, CSS Custom Properties for brand tokens, template literals for rendering, fetch() for data loading
- **Google Fonts (CDN):** Source Serif 4 (headings) + DM Sans (body) per Live AZ Co brand conventions
- **GitHub Pages:** Free hosting, auto-deploys on push to main, stable bookmarkable URL
- **projects.json:** External data file as single source of truth, edited by Claude Code

**Explicitly excluded:** Tailwind (needs build step), React/Vue/Svelte (massive overkill), Alpine.js (adds dependency for 3 event handlers), localStorage (read-only page), any database, any auth.

### Expected Features

**Must have (table stakes):**
- Project cards with color-coded status badges (Shipped/In Progress/Parking Lot)
- Summary stats bar with aggregated counts
- Health bars (Adoption, Autonomy, Revenue Proximity) on each card
- Filter by status (All / Shipped / In Progress / Parking Lot)
- Deployed URL links per project
- Version + deployed date display
- Responsive layout (phone-friendly for coaching calls)
- Live AZ Co branding (Olive/Canyon/Gold/Cream/Charcoal)
- External projects.json data file

**Should have (differentiators):**
- Priority scores for unshipped projects (makesMoney, savesTime, servesClients, speedToFinish)
- Expandable version history per project (native details/summary)
- "Up Next" roadmap box per project
- Sort options (by health dimension, recency, priority)
- Coaching-call-optimized layout (large text, high contrast)
- Pre-populated seed data from ~16 real projects
- Last-updated timestamp

**Defer (v2+):** Nothing. FEATURES.md explicitly recommends shipping all table stakes + all differentiators in v1.0. Total scope is small enough that phasing adds overhead. This is one page.

**Anti-features (never build):** Edit UI/admin panel (Claude Code IS the editor), database backend, authentication, real-time updates, charts/D3, Gantt timelines, team assignment, search, dark mode, print/export.

### Architecture Approach

Static HTML fetches external JSON on page load, parses it in memory, computes summary stats, applies filter/sort, and renders cards to the DOM. All state is ephemeral -- refreshing re-fetches fresh data. The critical architectural decision is separating data (projects.json) from presentation (index.html) so Claude Code only ever touches the JSON file.

**Major components:**
1. **projects.json** -- Single source of truth for all project data, health scores, versions, roadmap notes
2. **Fetch-Parse-Render Pipeline** -- Async init function loads JSON, computes derived stats, renders DOM
3. **Summary Stats Bar** -- Dynamically computed from project array (never stored in JSON)
4. **Project Card Grid** -- Functional rendering via template literals, no classes or virtual DOM
5. **Filter/Sort Controls** -- Event delegation on parent container, triggers re-render from in-memory data
6. **Health Bars** -- CSS-driven with custom properties set via inline styles
7. **Version History Panel** -- Native details/summary HTML elements

### Critical Pitfalls

1. **Browser caching serves stale JSON** -- Use `fetch("projects.json?v=" + Date.now())` or `{ cache: "no-store" }`. Add visible last-updated timestamp so staleness is immediately obvious. This WILL break the first coaching call if not handled.
2. **JSON schema drift breaks rendering** -- Define schema explicitly, write a validation function that logs warnings on load, use defensive rendering (`project.health?.adoption ?? 0`), provide Claude Code a template object for new projects.
3. **Mobile layout breaks during coaching call** -- Design mobile-first, set `overflow-wrap: break-word`, test on 375px viewport, cap version history to 3 visible entries.
4. **Health score numbers are meaningless without context** -- Use color coding (red/yellow/green), add labels ("3/5 - Team Aware"), include scale definitions in a legend or tooltips.
5. **Summary stats drift from card data** -- Compute ALL summary stats dynamically from the project array in JS. Never store aggregates in the JSON.

## Implications for Roadmap

Based on research, the FEATURES.md recommendation to ship everything in v1.0 is sound. However, the build should follow a strict dependency order. I recommend 3 phases that can realistically be completed in one focused session but provide natural commit/verification points.

### Phase 1: Data Foundation + Skeleton
**Rationale:** Everything depends on the JSON schema. Get it right first, validate it, and establish the fetch pipeline. This is the critical path identified in both ARCHITECTURE.md and FEATURES.md.
**Delivers:** projects.json with full schema and seed data for all ~16 projects, HTML skeleton with CSS variables and brand fonts, fetch-parse pipeline with cache-busting and schema validation, defensive rendering utilities (escapeHtml, null-safe accessors).
**Addresses:** External data file, Live AZ Co branding, last-updated timestamp
**Avoids:** Schema drift (Pitfall 2), stale cache (Pitfall 1), stale summary stats (Pitfall 6)

### Phase 2: Core Rendering + Interactivity
**Rationale:** With data flowing, build all visual components in dependency order: summary bar first (validates data flow), then cards, then card sub-components, then filter/sort.
**Delivers:** Summary stats bar (computed dynamically), project cards with status badges and deploy URLs, health bars with color coding and labels, version history accordion, "Up Next" roadmap boxes, priority scores for unshipped projects, filter by status, sort controls.
**Addresses:** All table stakes + all differentiators from FEATURES.md
**Avoids:** Meaningless health numbers (Pitfall 5), scroll confusion from expandable sections (Pitfall 4)

### Phase 3: Responsive Polish + Deploy
**Rationale:** CSS polish and mobile testing must happen after all content is rendered (you cannot test responsive layout on empty cards). GitHub Pages deployment is the final step.
**Delivers:** Mobile-first responsive layout, coaching-call-optimized typography and spacing, GitHub Pages deployment with verified URL, build timestamp in footer, pre-call verification workflow documented.
**Addresses:** Responsive layout, coaching-call-ready layout
**Avoids:** Mobile overflow (Pitfall 3), deploy delay confusion (Pitfall 7), font layout shift (Pitfall 8)

### Phase Ordering Rationale

- JSON schema MUST come first -- every rendering component depends on it, and schema changes after rendering is built cause cascading breakage
- Summary stats before cards validates the data pipeline with the simplest possible render
- Filter/sort requires cards to exist in the DOM
- Responsive CSS requires all content to be present to test properly
- Deployment last ensures the first public URL shows a complete product

### Research Flags

Phases with standard patterns (skip research-phase):
- **Phase 1:** Well-documented pattern (fetch + JSON + GitHub Pages). Josh has done this before with Tenet Calculator.
- **Phase 2:** Standard DOM rendering with template literals. No novel patterns.
- **Phase 3:** Standard CSS responsive design + GitHub Pages setup.

No phases need deeper research. This is a thoroughly understood domain with a proven prior implementation in the same codebase. The entire project follows established patterns.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Zero ambiguity. Vanilla HTML/CSS/JS + GitHub Pages. Proven by existing Tenet Calculator. |
| Features | HIGH | Features derived from explicit PROJECT.md requirements + coaching call context. Anti-features clearly bounded. |
| Architecture | HIGH | Single-file static site is the simplest possible architecture. Data flow is one fetch() call. |
| Pitfalls | HIGH | Pitfalls are operational (caching, mobile, schema drift), not technical unknowns. All have straightforward mitigations. |

**Overall confidence:** HIGH

### Gaps to Address

- **Seed data accuracy:** The ~16 projects need real health scores, version histories, and deploy URLs mined from existing repos and CLAUDE.md. This is a data entry task, not a research gap, but it is the most time-consuming part of Phase 1.
- **Health score calibration:** The 1-10 (or 1-5) scale for Adoption/Autonomy/Revenue Proximity needs Josh to define what each level means for his specific context. Research suggests including labels, but the actual rubric is a product decision.
- **GitHub Pages cache TTL:** Research confirms 10-minute default TTL, but actual behavior varies. Cache-busting via query param is the definitive fix regardless.
- **GitHub repo name and privacy:** PROJECT.md mentions "liveaz-project-tracker" as a candidate. Final name affects the public URL. Also confirm Josh is comfortable with project names/URLs being public on GitHub Pages, or consider a private repo (requires GitHub Pro/Team).
- **Filter state persistence:** PITFALLS.md suggests URL hash-based filter persistence (e.g., `#status=in-progress`). This is a nice-to-have that can be added in Phase 2 or deferred. The ARCHITECTURE.md explicitly warns against over-engineering client-side routing for this scope.

## Sources

### Primary (HIGH confidence)
- Josh's existing Tenet Commission Calculator -- proven identical architecture
- Josh's CLAUDE.md -- project inventory for seed data
- GitHub Pages documentation -- deployment and caching behavior

### Secondary (MEDIUM confidence)
- [Smartsheet: Project Portfolio Dashboards](https://www.smartsheet.com/content/project-portfolio-dashboards)
- [Dashboard Design Patterns](https://dashboarddesignpatterns.github.io/patterns.html)
- [GitHub Community: Pages Caching](https://github.com/orgs/community/discussions/11884)
- [MDN: Request cache property](https://developer.mozilla.org/en-US/docs/Web/API/Request/cache)
- [Sisu: Real Estate Performance Platform](https://sisu.co/)
- [Coach Simple: Real Estate Coaching Software](https://realestate.coachsimple.net/)

### Tertiary (LOW confidence)
- General dashboard design best practices articles (DesignRush, Mastt, ITONICS) -- directionally useful but not domain-specific

---
*Research completed: 2026-03-25*
*Ready for roadmap: yes*
