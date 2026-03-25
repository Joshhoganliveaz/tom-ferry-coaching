# Phase 1: Data Foundation + Scaffold - Research

**Researched:** 2026-03-25
**Domain:** Static HTML + external JSON data loading, vanilla CSS branding, client-side validation
**Confidence:** HIGH

## Summary

Phase 1 establishes the foundation that every subsequent phase builds on: a JSON schema with seed data for ~16 projects, an HTML page with Live AZ Co branding, and a fetch-parse pipeline with cache-busting and validation. This is a well-understood domain -- Josh already ships the Tenet Commission Calculator with identical architecture (single HTML file, CSS custom properties, no build step). The Tenet Calculator serves as a proven reference implementation for the CSS structure, font loading, and layout patterns.

The primary technical work is straightforward: define a JSON schema matching the design spec's data model, populate it with accurate seed data from CLAUDE.md and project memory, build an HTML skeleton with CSS custom properties for the brand palette, load Google Fonts, fetch the JSON with cache-busting, validate it on load, and display a timestamp. The primary risk is not technical but operational -- getting the seed data accurate for all ~16 projects requires mining version histories, deploy URLs, and health scores from multiple sources.

**Primary recommendation:** Follow the Tenet Calculator's proven single-file pattern. Use CSS custom properties for brand tokens, `fetch()` with `?v=Date.now()` for cache-busting, a `validateProject()` function that logs console warnings, and defensive rendering with null-safe accessors throughout. Start with the JSON schema and seed data since everything else depends on it.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| DATA-01 | projects.json schema supports all project fields | JSON schema pattern from ARCHITECTURE.md; design spec data model with enum-based health scores |
| DATA-02 | Seed data pre-populated for all ~16 projects | Project list from design spec; data sourced from CLAUDE.md project inventory |
| DATA-03 | HTML fetches projects.json with cache-busting | `fetch("projects.json?v=" + Date.now())` pattern from PITFALLS.md; prevents stale data on coaching calls |
| DATA-04 | Schema validation function logs warnings | Defensive validation function checking required fields, enum values, and type correctness |
| DATA-05 | Footer displays data load timestamp | Render `lastUpdated` from JSON + fetch timestamp in footer element |
| VIS-01 | Live AZ Co branding (Olive/Canyon/Gold/Cream/Charcoal) | CSS custom properties pattern proven in Tenet Calculator; brand tokens defined in CLAUDE.md shared conventions |
| VIS-02 | Source Serif 4 + DM Sans via Google Fonts | Single combined Google Fonts `<link>` with `display=swap`; matches STR Analyzer and shared conventions |
| DEPLOY-01 | Single HTML file + separate projects.json, no build process | Exact pattern from Tenet Calculator; two files at repo root, open in browser or serve locally |
</phase_requirements>

## Standard Stack

### Core

| Technology | Version | Purpose | Why Standard |
|------------|---------|---------|--------------|
| Vanilla HTML5 | Current | Document structure, semantic markup | Zero-dependency constraint; proven by Tenet Calculator |
| Vanilla CSS3 | Current | Layout (CSS Grid/Flexbox), branding, custom properties | No utility framework needed for ~200 lines of styles |
| Vanilla JavaScript ES2020+ | Current | fetch(), template literals, Array methods, optional chaining | All features baseline in every modern browser |
| CSS Custom Properties | Current | Brand color tokens, spacing, font stacks | Single source of truth for Olive/Canyon/Gold/Cream/Charcoal |

### Supporting

| Resource | Source | Purpose | When to Use |
|----------|--------|---------|-------------|
| Google Fonts CDN | `fonts.googleapis.com` | Source Serif 4 (headings) + DM Sans (body) | Single `<link>` tag in `<head>` |
| `python3 -m http.server` | macOS built-in | Local dev server (fetch requires HTTP, not file://) | During development |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| CSS Custom Properties | Tailwind CSS | Tailwind requires build step or 115KB+ Play CDN -- violates zero-dependency constraint |
| `innerHTML` with template literals | Alpine.js / Lit | Adds a dependency for what amounts to 3 render functions in Phase 1 |
| `fetch()` with query param cache-bust | `fetch()` with `cache: "no-store"` | Both work; query param is more portable and debuggable in network tab |

**No installation needed.** Zero dependencies. Two files: `index.html` and `projects.json`.

## Architecture Patterns

### Recommended Project Structure

```
/ (repo root)
  index.html          # All HTML + CSS + JS in one file
  projects.json       # External data source, edited by Claude Code
```

### Pattern 1: CSS Custom Properties for Brand Tokens

**What:** Define all brand colors as CSS custom properties on `:root`, reference throughout styles.
**When to use:** Every style rule that uses a brand color.
**Example:**
```css
/* Source: Tenet Calculator proven pattern + CLAUDE.md shared conventions */
:root {
  --olive: #5C6B4F;
  --canyon: #8B6F5C;
  --gold: #C9953E;
  --cream: #FAF7F2;
  --charcoal: #2C2C2C;
  --font-heading: 'Source Serif 4', Georgia, serif;
  --font-body: 'DM Sans', system-ui, sans-serif;
}
```

### Pattern 2: Google Fonts Loading

**What:** Single combined request for both font families with display=swap.
**When to use:** In the `<head>` element.
**Example:**
```html
<!-- Source: Google Fonts API, matching STR Analyzer convention -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Source+Serif+4:wght@400;600;700&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
```

### Pattern 3: Fetch-Parse Pipeline with Cache-Busting

**What:** Async init function fetches JSON with cache-busting timestamp, parses, validates, renders.
**When to use:** On DOMContentLoaded.
**Example:**
```javascript
// Source: ARCHITECTURE.md + PITFALLS.md Pitfall 1
async function init() {
  try {
    const res = await fetch(`./projects.json?v=${Date.now()}`);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();

    // Validate each project
    data.projects.forEach((p, i) => validateProject(p, i));

    // Store for later phases (filter/sort)
    window.__projects = data.projects;

    // Render minimal scaffold (Phase 1: just show data loaded)
    renderPage(data);
    renderFooterTimestamp(data.lastUpdated);
  } catch (err) {
    document.getElementById('app').innerHTML =
      `<p class="error">Failed to load project data: ${err.message}</p>`;
  }
}

document.addEventListener('DOMContentLoaded', init);
```

### Pattern 4: Schema Validation Function

**What:** Checks each project object for required fields, correct types, valid enum values. Logs warnings to console.
**When to use:** Immediately after JSON parse, before rendering.
**Example:**
```javascript
// Source: PITFALLS.md Pitfall 2 -- prevent schema drift
const VALID_STATUSES = ['shipped', 'in_progress', 'parking_lot'];
const VALID_ADOPTION = ['none', 'josh_only', 'team_uses', 'client_facing'];
const VALID_AUTONOMY = ['josh_dependent', 'needs_guidance', 'fully_independent'];
const VALID_REVENUE = ['internal_only', 'client_touch', 'revenue_driver'];

function validateProject(project, index) {
  const warn = (msg) => console.warn(`[Validation] Project ${index} (${project.name || 'unnamed'}): ${msg}`);

  // Required string fields
  ['name', 'description', 'status'].forEach(field => {
    if (!project[field] || typeof project[field] !== 'string') warn(`missing or invalid '${field}'`);
  });

  // Enum validation
  if (project.status && !VALID_STATUSES.includes(project.status)) warn(`invalid status '${project.status}'`);
  if (project.adoption && !VALID_ADOPTION.includes(project.adoption)) warn(`invalid adoption '${project.adoption}'`);
  if (project.autonomy && !VALID_AUTONOMY.includes(project.autonomy)) warn(`invalid autonomy '${project.autonomy}'`);
  if (project.revenueProximity && !VALID_REVENUE.includes(project.revenueProximity)) warn(`invalid revenueProximity '${project.revenueProximity}'`);

  // Version history array
  if (project.versions && !Array.isArray(project.versions)) warn(`'versions' should be an array`);

  // Priority: should exist only for non-shipped
  if (project.status === 'shipped' && project.priority) warn(`shipped project has priority scores (expected null)`);
}
```

### Pattern 5: Defensive Rendering with escapeHtml

**What:** Sanitize all dynamic text before inserting into DOM via innerHTML.
**When to use:** Every template literal that renders project data.
**Example:**
```javascript
// Source: CLAUDE.md Code Patterns -- always sanitize for special characters
function escapeHtml(str) {
  if (!str) return '';
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}
```

### Anti-Patterns to Avoid

- **Embedding data in HTML:** Never hardcode project data in index.html. Always fetch from projects.json. Claude Code should only ever edit the JSON file.
- **Caching JSON in localStorage:** The whole point is fresh data on refresh. The JSON is tiny (< 50KB).
- **Using numeric health scores (1-10):** The design spec uses enum-based health scoring (e.g., "josh_only", "team_uses"). Follow the spec, not the earlier research drafts that used numeric 1-10 scales.
- **Storing computed aggregates in JSON:** Summary stats (count of shipped, count of independent, etc.) must be computed dynamically from the project array, never stored in the JSON.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Font loading | Custom font-face declarations | Google Fonts CDN link | Handles subsetting, WOFF2 delivery, browser compat |
| HTML escaping | Regex-based sanitizer | `textContent`/`createElement` approach | Covers all edge cases including nested HTML entities |
| Local dev server | Custom Node script | `python3 -m http.server 8000` | Already on macOS, zero setup |
| Cache-busting | Service worker or ETag logic | `?v=${Date.now()}` query param | Simple, debuggable, works on all CDNs including GitHub Pages |

**Key insight:** This entire phase is standard web fundamentals. There is nothing novel enough to warrant any library or custom infrastructure.

## Common Pitfalls

### Pitfall 1: Browser Caching Serves Stale JSON on Coaching Calls
**What goes wrong:** Josh updates projects.json, pushes, Jeff refreshes but sees old data because the browser cached the JSON.
**Why it happens:** `fetch("projects.json")` without cache-busting hits browser cache. GitHub Pages has ~10 min default TTL.
**How to avoid:** Always fetch with `?v=${Date.now()}`. Display the `lastUpdated` field from JSON in the footer so staleness is immediately visible.
**Warning signs:** Footer timestamp does not match the latest push.

### Pitfall 2: JSON Schema Drift Breaks Rendering
**What goes wrong:** A project entry is missing a field, or uses a wrong type (string instead of enum). Card renders "undefined" or breaks.
**Why it happens:** No TypeScript, no tests. The contract between JSON and HTML is implicit.
**How to avoid:** Validate on load with `validateProject()`. Use defensive rendering: `project.currentVersion || "unreleased"`, `project.adoption || "none"`. Log console warnings.
**Warning signs:** Console warnings on page load; any card showing "undefined" or "NaN".

### Pitfall 3: fetch() Fails on file:// Protocol
**What goes wrong:** Opening index.html directly from Finder (double-click) fails because `fetch('./projects.json')` requires HTTP origin.
**Why it happens:** Browsers block fetch() from `file://` due to CORS/security policies.
**How to avoid:** Document that local development requires `python3 -m http.server 8000`. Works fine once deployed to GitHub Pages.
**Warning signs:** Console error: "Failed to fetch" or "CORS policy" when opening from Finder.

### Pitfall 4: Health Score Enum Mismatch Between Spec and Implementation
**What goes wrong:** The design spec uses enum-based health scores ("josh_only", "team_uses") while earlier research docs used numeric 1-10 scales. If the implementation follows the wrong one, rendering breaks.
**Why it happens:** Multiple documents in the planning directory describe health scores differently.
**How to avoid:** Follow the DESIGN SPEC (2026-03-25-project-tracker-design.md) as the authoritative source. Health scores are enums, not numbers. The validation function must check enum values.
**Warning signs:** Health bar rendering logic expecting numbers when data contains strings, or vice versa.

### Pitfall 5: Seed Data Inaccuracy
**What goes wrong:** Project versions, dates, or URLs are wrong. Jeff notices during a coaching call.
**Why it happens:** Data must be mined from CLAUDE.md, project memory, and actual repos. Easy to get versions or dates wrong.
**How to avoid:** Cross-reference each project against its actual repo/deploy URL. Mark uncertain data with a TODO comment in the JSON. Better to show "TBD" than a wrong date.
**Warning signs:** A deploy URL returns 404, or a version does not match the actual deployed version.

## Code Examples

### Minimal HTML Skeleton with Branding

```html
<!-- Source: Tenet Calculator pattern + CLAUDE.md shared conventions -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Live AZ Co | Project Tracker</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Source+Serif+4:wght@400;600;700&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --olive: #5C6B4F;
      --canyon: #8B6F5C;
      --gold: #C9953E;
      --cream: #FAF7F2;
      --charcoal: #2C2C2C;
      --font-heading: 'Source Serif 4', Georgia, serif;
      --font-body: 'DM Sans', system-ui, sans-serif;
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: var(--font-body);
      background: var(--cream);
      color: var(--charcoal);
      min-height: 100vh;
      line-height: 1.6;
    }
    h1, h2, h3 { font-family: var(--font-heading); }
    /* ... rest of styles */
  </style>
</head>
<body>
  <header class="header">
    <h1>Live AZ Co Project Tracker</h1>
  </header>
  <main id="app">
    <p class="loading">Loading projects...</p>
  </main>
  <footer class="footer">
    <span id="timestamp"></span>
  </footer>
  <script>
    // Fetch-parse-render pipeline goes here
  </script>
</body>
</html>
```

### projects.json Schema (Single Project Entry)

```json
{
  "lastUpdated": "2026-03-25",
  "projects": [
    {
      "name": "STR Analyzer",
      "slug": "str-analyzer",
      "description": "Short-term rental investment underwriting calculator",
      "status": "shipped",
      "currentVersion": "2.1",
      "deployedUrl": "https://stranalyzer.vercel.app",
      "deployedDate": "2026-03-20",
      "stack": ["Next.js", "TypeScript", "Supabase"],
      "adoption": "client_facing",
      "autonomy": "needs_guidance",
      "revenueProximity": "client_touch",
      "versions": [
        { "version": "2.1", "date": "2026-03-20", "notes": "Public investor view with shareable slug URLs" },
        { "version": "2.0", "date": "2026-03-01", "notes": "Supabase integration, PDF export, cost segregation" }
      ],
      "upNext": null,
      "priority": null
    }
  ]
}
```

**Schema notes:**
- `status`: `"shipped"` | `"in_progress"` | `"parking_lot"` (underscore-separated, not hyphenated -- matches design spec)
- `adoption`: `"none"` | `"josh_only"` | `"team_uses"` | `"client_facing"` (enum per design spec)
- `autonomy`: `"josh_dependent"` | `"needs_guidance"` | `"fully_independent"` (enum per design spec)
- `revenueProximity`: `"internal_only"` | `"client_touch"` | `"revenue_driver"` (enum per design spec)
- `priority`: `null` for shipped projects; `{ makesMoney, savesTime, servesClients, speedToFinish }` with 1-5 ranks for unshipped
- `upNext`: `null` or `{ version?: string, notes: string }`
- `versions`: Array ordered newest-first (no client-side sorting needed)

### Footer Timestamp Rendering

```javascript
function renderFooterTimestamp(lastUpdated) {
  const el = document.getElementById('timestamp');
  const loadTime = new Date().toLocaleString();
  el.textContent = `Data from: ${lastUpdated} | Loaded: ${loadTime}`;
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| @import for Google Fonts | `<link>` with preconnect hints | 2020+ | Faster font loading, less render-blocking |
| jQuery for DOM manipulation | Vanilla JS template literals + innerHTML | 2018+ | No dependency needed for this scope |
| `var` declarations | `const`/`let` with optional chaining (`?.`) | ES2020 | Cleaner code, null-safe accessors for defensive rendering |
| XMLHttpRequest | `fetch()` with async/await | ES2017 | Simpler API, native promise support |

**Nothing deprecated or outdated in this stack.** Vanilla web standards are stable and well-supported.

## Open Questions

1. **Health score enum vs. numeric**
   - What we know: The design spec (authoritative) uses enum strings. Earlier research docs used numeric 1-10.
   - What's unclear: Whether Josh prefers the enum approach for JSON maintainability.
   - Recommendation: Follow the design spec (enums). Map enums to bar fill percentages in the rendering code. Enums are easier for Claude Code to set correctly ("josh_only" is self-documenting; "3" is not).

2. **Seed data completeness**
   - What we know: ~16 projects listed in the design spec. CLAUDE.md has details for 4-5 projects.
   - What's unclear: Exact health scores, version histories, and deploy URLs for all projects.
   - Recommendation: Populate what is known with HIGH confidence, use placeholder values (marked with comments) for uncertain data. Ship with accurate structure even if some health scores need calibration.

3. **Project name: "Tom Ferry Coaching" vs. "liveaz-project-tracker"**
   - What we know: The repo is currently named "Tom Ferry Coaching" locally. STATE.md mentions "liveaz-project-tracker" as a candidate.
   - What's unclear: Final GitHub repo name affecting the Pages URL.
   - Recommendation: Build the code. Repo naming is a deployment concern (Phase 3). The HTML/JSON work is name-independent.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Manual browser verification (no test framework -- zero-dependency single HTML file) |
| Config file | None -- this is a static HTML project |
| Quick run command | `python3 -m http.server 8000` then open `http://localhost:8000` |
| Full suite command | Open in browser + check console for validation warnings |

### Phase Requirements to Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DATA-01 | JSON schema has all required fields | manual | Open browser console, check no validation warnings | N/A -- manual |
| DATA-02 | Seed data for ~16 projects present | manual | `python3 -c "import json; d=json.load(open('projects.json')); print(len(d['projects']), 'projects')"` | N/A |
| DATA-03 | Fetch uses cache-busting | manual | Open Network tab, verify `?v=` param on projects.json request | N/A |
| DATA-04 | Validation logs console warnings for bad data | manual | Temporarily corrupt a field in projects.json, reload, check console | N/A |
| DATA-05 | Footer shows load timestamp | manual | Visual check -- footer displays date/time | N/A |
| VIS-01 | Brand colors applied | manual | Visual check -- Olive/Canyon/Gold/Cream/Charcoal visible | N/A |
| VIS-02 | Correct fonts loaded | manual | DevTools > Elements > Computed > font-family shows Source Serif 4 / DM Sans | N/A |
| DEPLOY-01 | Two files, no build process | manual | `ls` shows only index.html + projects.json (+ README) | N/A |

### Sampling Rate
- **Per task commit:** Open `http://localhost:8000` and visually verify + check console
- **Per wave merge:** Full visual check of all requirements + console validation
- **Phase gate:** All 8 requirements visually verified before proceeding to Phase 2

### Wave 0 Gaps
- [ ] `projects.json` -- must be created with full schema and seed data
- [ ] `index.html` -- must be created with HTML skeleton, CSS branding, and fetch pipeline
- [ ] Local server workflow -- developer must use `python3 -m http.server 8000` (not double-click)

## Sources

### Primary (HIGH confidence)
- Tenet Commission Calculator (`~/tenet-commission-calculator/index.html`) -- proven identical architecture, inspected CSS custom properties pattern and structure
- Design spec (`docs/superpowers/specs/2026-03-25-project-tracker-design.md`) -- authoritative data model with enum-based health scores
- CLAUDE.md shared conventions -- brand colors, fonts, project inventory

### Secondary (MEDIUM confidence)
- `.planning/research/ARCHITECTURE.md` -- fetch-parse-render pipeline pattern, anti-patterns
- `.planning/research/PITFALLS.md` -- cache-busting, schema drift, mobile layout pitfalls
- `.planning/research/STACK.md` -- technology selection rationale, Google Fonts loading pattern

### Tertiary (LOW confidence)
- None. This domain is fully covered by primary and secondary sources.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- zero ambiguity, proven by existing Tenet Calculator
- Architecture: HIGH -- single file + JSON fetch is the simplest possible architecture
- Pitfalls: HIGH -- all pitfalls are operational (caching, schema drift), not technical unknowns
- Seed data accuracy: MEDIUM -- project list is known, but exact health scores and version dates need verification

**Research date:** 2026-03-25
**Valid until:** 2026-04-25 (stable domain, no fast-moving dependencies)
