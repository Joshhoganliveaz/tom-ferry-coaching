# Phase 2: Card Rendering + Interactivity - Research

**Researched:** 2026-03-25
**Domain:** Vanilla HTML/CSS/JS -- card UI components, filtering, sorting, progress bars
**Confidence:** HIGH

## Summary

Phase 2 transforms the existing flat project list (rendered by Phase 1's `renderPage()`) into rich interactive cards with health bars, expandable version history, conditional sections, summary stats, and filter/sort controls. The entire implementation lives inside the single `index.html` file -- no frameworks, no build tools, no dependencies.

The data layer is already complete. `window.__projects` holds 16 parsed project objects with all required fields: status, adoption/autonomy/revenueProximity enums, versions arrays, upNext objects, and priority score objects. The existing CSS custom properties (`--olive`, `--gold`, `--canyon`, `--cream`, `--charcoal`) and font families are already loaded. Phase 2's job is purely rendering logic and CSS.

**Primary recommendation:** Replace the existing `renderPage()` function with a new multi-section renderer that builds summary stats bar, filter/sort controls, and card grid. Use CSS classes for show/hide filtering (toggling `.hidden` on cards) rather than re-rendering the DOM on each filter change. Keep all state in simple JS variables -- no state management library needed for this scope.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| CARD-01 | Card header: name, status badge (color-coded), version badge, deployed date, clickable deploy URL | Existing status badge CSS from Phase 1; add date + link elements to card header markup |
| CARD-02 | Three health bars (Adoption, Autonomy, Revenue Proximity) with color coding and text labels | CSS progress bar pattern using `<div>` width percentages; enum-to-percentage mapping defined below |
| CARD-03 | Expandable version history, newest-first | `<details>/<summary>` native HTML element; sort versions by date descending |
| CARD-04 | "Up Next" box with gold highlight, only when upNext data exists | Conditional rendering; gold-bordered box with `--gold` border-left |
| CARD-05 | Priority scores (1-5 ranks) visible only on in_progress and parking_lot cards | Conditional rendering based on `project.status !== 'shipped'`; small grid/flex layout for 4 scores |
| NAV-01 | Summary stats bar: live counts by status and health dimensions | Computed from `window.__projects` array using `.filter().length`; rendered above card grid |
| NAV-02 | Filter tabs (All / Shipped / In Progress / Parking Lot) | Tab buttons that toggle `.hidden` class on cards by `data-status` attribute |
| NAV-03 | Sort options (most recently deployed, autonomy level) | Re-order card DOM elements using `appendChild` after sorting backing array |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Vanilla JS | ES2020+ | All logic, DOM manipulation, filtering, sorting | Zero dependencies per DEPLOY-01; single HTML file |
| CSS Custom Properties | CSS3 | Brand tokens already defined in Phase 1 | Already in `:root` block |
| Google Fonts | -- | Source Serif 4 + DM Sans already loaded | Already in `<head>` |

### Supporting
No additional libraries. This is a zero-dependency project by design decision.

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Manual DOM manipulation | lit-html or preact | Adds dependency; violates DEPLOY-01 zero-dependency constraint |
| CSS class toggling for filters | Re-render entire DOM | Re-render is simpler code but slower and loses scroll position |
| `<details>/<summary>` for expand | Custom JS accordion | Native HTML gives accessibility for free |

## Architecture Patterns

### Recommended Rendering Structure

The `renderPage()` function should be refactored into composable render functions:

```
renderPage(data)
  --> renderSummaryStats(projects)       // NAV-01
  --> renderFilterSortControls()         // NAV-02, NAV-03
  --> renderCards(projects)              // CARD-01..05
        --> renderCard(project)
              --> renderCardHeader(project)        // CARD-01
              --> renderHealthBars(project)         // CARD-02
              --> renderVersionHistory(project)     // CARD-03
              --> renderUpNext(project)             // CARD-04
              --> renderPriorityScores(project)     // CARD-05
```

### Pattern 1: Enum-to-Visual Mapping

The health fields use string enums, not numbers. Each enum maps to a percentage width and color:

```javascript
// Adoption: none(0%) -> josh_only(33%) -> team_uses(66%) -> client_facing(100%)
const ADOPTION_MAP = {
  none:          { pct: 0,   label: 'None',          color: 'var(--canyon)' },
  josh_only:     { pct: 33,  label: 'Josh Only',     color: 'var(--gold)' },
  team_uses:     { pct: 66,  label: 'Team Uses',     color: 'var(--gold)' },
  client_facing: { pct: 100, label: 'Client Facing',  color: 'var(--olive)' }
};

// Autonomy: josh_dependent(33%) -> needs_guidance(66%) -> fully_independent(100%)
const AUTONOMY_MAP = {
  josh_dependent:     { pct: 33,  label: 'Josh Dependent',     color: 'var(--canyon)' },
  needs_guidance:     { pct: 66,  label: 'Needs Guidance',      color: 'var(--gold)' },
  fully_independent:  { pct: 100, label: 'Fully Independent',   color: 'var(--olive)' }
};

// Revenue Proximity: internal_only(33%) -> client_touch(66%) -> revenue_driver(100%)
const REVENUE_MAP = {
  internal_only:  { pct: 33,  label: 'Internal Only',   color: 'var(--canyon)' },
  client_touch:   { pct: 66,  label: 'Client Touch',    color: 'var(--gold)' },
  revenue_driver: { pct: 100, label: 'Revenue Driver',  color: 'var(--olive)' }
};
```

Color logic: low values = canyon (red-ish), mid = gold, high = olive (green-ish). This matches the spec's "red/gold/olive" color coding.

### Pattern 2: Filter by CSS Class Toggle

```javascript
// Each card gets: data-status="shipped" etc.
// Filter function:
function filterCards(status) {
  const cards = document.querySelectorAll('.project-card');
  cards.forEach(card => {
    if (status === 'all' || card.dataset.status === status) {
      card.classList.remove('hidden');
    } else {
      card.classList.add('hidden');
    }
  });
  updateActiveTab(status);
}
```

This preserves DOM state (expanded sections stay expanded), avoids re-rendering, and is fast for 16 items.

### Pattern 3: Sort by DOM Reordering

```javascript
function sortCards(sortKey) {
  const container = document.querySelector('.project-grid');
  const cards = Array.from(container.querySelectorAll('.project-card'));

  cards.sort((a, b) => {
    // Sort functions access data-* attributes or lookup from window.__projects
  });

  // Re-append in new order (moves existing DOM nodes, does not clone)
  cards.forEach(card => container.appendChild(card));
}
```

### Pattern 4: Summary Stats Computation

```javascript
function computeStats(projects) {
  return {
    shipped: projects.filter(p => p.status === 'shipped').length,
    inProgress: projects.filter(p => p.status === 'in_progress').length,
    parkingLot: projects.filter(p => p.status === 'parking_lot').length,
    fullyIndependent: projects.filter(p => p.autonomy === 'fully_independent').length,
    joshDependent: projects.filter(p => p.autonomy === 'josh_dependent').length,
    clientFacing: projects.filter(p => p.adoption === 'client_facing').length
  };
}
```

### Anti-Patterns to Avoid
- **Re-rendering entire DOM on filter/sort:** Loses expand/collapse state, causes flicker, unnecessary for 16 items
- **Using numeric IDs for card lookup:** Use `data-slug` attributes from project slugs instead
- **Inline styles for health bar colors:** Use CSS classes or CSS custom properties set via `style.setProperty()`
- **Building HTML strings with template literals for user data:** Always use `escapeHtml()` (already exists in Phase 1) for any project field value

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Accordion/expand-collapse | Custom JS toggle with aria management | `<details>/<summary>` HTML elements | Native accessibility, keyboard support, no JS needed for basic behavior |
| Progress bars | Canvas or SVG rendering | CSS `<div>` with percentage width | Simple, performant, brand-color compatible |
| Tab component | Full ARIA tab pattern | Simple button group with active class | Only 4 tabs, simple show/hide, not a complex widget |

## Common Pitfalls

### Pitfall 1: Forgetting escapeHtml on Dynamic Fields
**What goes wrong:** XSS vulnerability if project names/descriptions contain special characters
**Why it happens:** Template literals make it easy to skip sanitization
**How to avoid:** Every dynamic value inserted into innerHTML MUST go through `escapeHtml()` -- already defined in Phase 1
**Warning signs:** Any `${project.someField}` without `escapeHtml()` wrapper

### Pitfall 2: Version History Sort Order
**What goes wrong:** Versions display oldest-first instead of newest-first
**Why it happens:** The JSON array is already newest-first in some entries but not guaranteed
**How to avoid:** Always sort versions by date descending before rendering: `versions.sort((a, b) => new Date(b.date) - new Date(a.date))`

### Pitfall 3: Null/Undefined Conditional Sections
**What goes wrong:** "Up Next" box renders empty, or priority scores show on shipped projects
**Why it happens:** Truthy check fails for edge cases (empty object, null fields)
**How to avoid:** Check `project.upNext != null && project.upNext.version` before rendering. Check `project.status !== 'shipped' && project.priority != null` for priority scores.

### Pitfall 4: deployedUrl Clickability
**What goes wrong:** Null deployed URLs render as broken links
**Why it happens:** Many projects have `"deployedUrl": null`
**How to avoid:** Only render the link element when `project.deployedUrl` is truthy. Show "Not deployed" text otherwise.

### Pitfall 5: Filter State vs Sort State Interaction
**What goes wrong:** Sorting resets filter, or filtering undoes sort order
**Why it happens:** Sort and filter operate independently on the same DOM
**How to avoid:** Track current filter and sort state. When sorting, only reorder visible (non-hidden) cards OR reorder all cards (hidden ones get correctly filtered on next filter action). Simplest: always sort all cards, filter is a CSS visibility concern only.

### Pitfall 6: deployedDate Display for Null Dates
**What goes wrong:** Card shows "null" or "Invalid Date" for undeployed projects
**Why it happens:** Several in_progress and parking_lot projects have `"deployedDate": null`
**How to avoid:** Check for null before formatting. Show nothing or "Not yet deployed" for null dates.

## Code Examples

### Health Bar HTML/CSS Pattern

```html
<!-- Health bar markup -->
<div class="health-bar">
  <span class="health-label">Adoption</span>
  <div class="health-track">
    <div class="health-fill" style="width: 66%; background: var(--gold);"></div>
  </div>
  <span class="health-text">Team Uses</span>
</div>
```

```css
.health-bar {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.4rem;
  font-size: 0.85rem;
}

.health-label {
  width: 7rem;
  font-weight: 600;
  color: var(--charcoal);
  flex-shrink: 0;
}

.health-track {
  flex: 1;
  height: 8px;
  background: #e0ddd8;
  border-radius: 4px;
  overflow: hidden;
}

.health-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.3s ease;
}

.health-text {
  width: 7rem;
  font-size: 0.8rem;
  color: #777;
  text-align: right;
  flex-shrink: 0;
}
```

### Filter Tab Markup Pattern

```html
<div class="filter-bar">
  <div class="filter-tabs">
    <button class="filter-tab active" data-filter="all">All</button>
    <button class="filter-tab" data-filter="shipped">Shipped</button>
    <button class="filter-tab" data-filter="in_progress">In Progress</button>
    <button class="filter-tab" data-filter="parking_lot">Parking Lot</button>
  </div>
  <div class="sort-controls">
    <label>Sort: </label>
    <select id="sort-select">
      <option value="recent">Most Recently Deployed</option>
      <option value="autonomy">Autonomy Level</option>
    </select>
  </div>
</div>
```

### Summary Stats Bar Pattern

```html
<div class="summary-stats">
  <div class="stat-item stat-olive">
    <span class="stat-count">5</span>
    <span class="stat-label">Shipped</span>
  </div>
  <div class="stat-item stat-gold">
    <span class="stat-count">6</span>
    <span class="stat-label">In Progress</span>
  </div>
  <!-- ... more stat items -->
</div>
```

### Expandable Version History Pattern

```html
<details class="version-history">
  <summary>Version History (3)</summary>
  <div class="version-list">
    <div class="version-entry">
      <strong>v2.1</strong> <span class="version-date">2026-03-20</span>
      <p>Public investor view with shareable slug URLs</p>
    </div>
    <!-- more entries -->
  </div>
</details>
```

### Priority Scores Pattern (in_progress/parking_lot only)

```html
<div class="priority-scores">
  <div class="priority-item">
    <span class="priority-label">Makes Money</span>
    <span class="priority-value">3/5</span>
  </div>
  <div class="priority-item">
    <span class="priority-label">Saves Time</span>
    <span class="priority-value">2/5</span>
  </div>
  <!-- savesTime, servesClients, speedToFinish -->
</div>
```

## State of the Art

No framework or library considerations -- this is vanilla HTML/CSS/JS by locked design decision. Modern CSS and JS features to leverage:

| Feature | Use For | Browser Support |
|---------|---------|-----------------|
| `<details>/<summary>` | Version history expand/collapse | All modern browsers |
| CSS Custom Properties | Brand colors already in `:root` | All modern browsers |
| `Array.prototype.sort()` | Card sorting | Universal |
| `dataset` API | `data-status`, `data-slug` on cards | All modern browsers |
| CSS Grid or Flexbox | Card layout, stats bar | All modern browsers |
| Template literals | HTML string building (with escapeHtml) | All modern browsers |

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Manual browser testing (no JS test framework -- single HTML file, no build) |
| Config file | none |
| Quick run command | Open `index.html` in browser, check console for errors |
| Full suite command | Open `index.html`, visually verify all requirements |

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| CARD-01 | Card headers show name, status badge, version, date, URL | manual | Visual inspection | n/a |
| CARD-02 | Three health bars with color coding and labels | manual | Visual inspection | n/a |
| CARD-03 | Version history expands, newest-first | manual | Click details element | n/a |
| CARD-04 | Up Next box shows only when data exists | manual | Compare cards with/without upNext | n/a |
| CARD-05 | Priority scores on non-shipped only | manual | Verify shipped cards lack priority section | n/a |
| NAV-01 | Summary stats counts match data | manual | Count cards vs stats numbers | n/a |
| NAV-02 | Filter tabs show/hide correct cards | manual | Click each tab, verify visible cards | n/a |
| NAV-03 | Sort reorders visible cards | manual | Change sort, verify order | n/a |

### Sampling Rate
- **Per task commit:** Open index.html in browser, verify no console errors, spot-check card rendering
- **Per wave merge:** Full visual walkthrough of all 8 requirements
- **Phase gate:** All 8 requirements visually verified before `/gsd:verify-work`

### Wave 0 Gaps
None -- no test infrastructure needed. This is a static HTML file tested by opening in a browser. The existing Phase 1 validation function (`validateProject()`) provides data-level sanity checks via console warnings.

## Data Schema Reference

Key fields from `projects.json` that Phase 2 must render:

```
project.name              -- string, always present
project.slug              -- string, unique identifier for data-slug attribute
project.description       -- string
project.status            -- "shipped" | "in_progress" | "parking_lot"
project.currentVersion    -- string or null
project.deployedUrl       -- string URL or null
project.deployedDate      -- "YYYY-MM-DD" string or null
project.adoption          -- "none" | "josh_only" | "team_uses" | "client_facing"
project.autonomy          -- "josh_dependent" | "needs_guidance" | "fully_independent"
project.revenueProximity  -- "internal_only" | "client_touch" | "revenue_driver"
project.versions          -- array of {version, date, notes} or empty array
project.upNext            -- {version, notes} object or null
project.priority          -- {makesMoney, savesTime, servesClients, speedToFinish} (1-5 each) or null
```

Current data counts (from projects.json):
- Shipped: 5 projects
- In Progress: 6 projects
- Parking Lot: 5 projects
- Total: 16 projects

## Open Questions

1. **Sort by "most recently deployed" for null dates**
   - What we know: Many in_progress and parking_lot projects have `deployedDate: null`
   - What's unclear: Should null-date projects sort to bottom or top?
   - Recommendation: Sort nulls to bottom (least recently deployed = no deploy yet)

2. **Autonomy sort order direction**
   - What we know: Requirement says "autonomy level" as a sort option
   - What's unclear: Ascending (josh_dependent first) or descending (fully_independent first)?
   - Recommendation: Descending -- show most independent first (the "best" projects rise to top). This mirrors what Jeff would want to see: what's healthy first.

## Sources

### Primary (HIGH confidence)
- Phase 1 `index.html` source code -- examined current rendering, CSS variables, escapeHtml function, window.__projects pattern
- `projects.json` -- full schema with 16 projects, all field types verified
- `.planning/REQUIREMENTS.md` -- exact requirement text for CARD-01..05, NAV-01..03
- `.planning/STATE.md` -- Phase 1 decisions (enum-based health scores, embedded CSS/JS, window.__projects)

### Secondary (MEDIUM confidence)
- MDN `<details>` element documentation -- native expand/collapse with accessibility built in
- CSS progress bar patterns -- well-established, no library needed

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- zero-dependency vanilla JS is a locked decision, no library research needed
- Architecture: HIGH -- rendering patterns are straightforward DOM manipulation with well-known CSS
- Pitfalls: HIGH -- enumerated from actual data inspection (null fields, enum mappings, conditional sections)

**Research date:** 2026-03-25
**Valid until:** Indefinite -- vanilla HTML/CSS/JS patterns are stable
