# Architecture Patterns

**Domain:** Single-page static project portfolio tracker
**Researched:** 2026-03-25

## Recommended Architecture

**Pattern:** Static HTML + External JSON data file, no framework, no build step.

This mirrors Josh's existing Tenet Commission Calculator architecture (single HTML file with embedded CSS/JS, localStorage persistence) but replaces localStorage with a separate `projects.json` file as the data source. The HTML file fetches the JSON on load and renders everything client-side.

```
GitHub Repository
  |
  +-- index.html          (structure + styles + all JS logic)
  +-- projects.json        (data source, edited by Claude Code)
  +-- README.md            (optional, for repo description)
  |
  GitHub Pages serves both files from main branch
```

### Why This Architecture

1. **Zero dependencies** -- nothing to install, nothing to break, nothing to update
2. **Separation of data from presentation** -- Claude Code edits JSON only, never touches HTML/CSS/JS
3. **GitHub Pages native** -- push to main, site updates in ~60 seconds
4. **Proven pattern** -- Josh already maintains the Tenet calculator this way

### Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| **projects.json** | Single source of truth for all project data, versions, health scores, roadmap notes | Read by Render Engine via fetch() |
| **Summary Stats Bar** | Aggregates project data into counts by status and health level | Reads from parsed project data |
| **Filter/Sort Controls** | UI for filtering by status (All/Shipped/In Progress/Parking Lot) and sorting | Triggers re-render of Project Cards |
| **Project Card Grid** | Renders filtered/sorted list of project cards | Reads filtered data, delegates to individual Card components |
| **Project Card** | Displays one project: name, status badge, version, deploy URL, health bars, priority scores | Reads single project object |
| **Health Bars** | Three visual bars per card (Adoption, Autonomy, Revenue Proximity) | Reads health scores from project data |
| **Version History Panel** | Expandable accordion showing version changelog per project | Reads versions array from project data |
| **Roadmap Box** | "Up Next" section per project card | Reads roadmap field from project data |
| **Priority Score Display** | Shows makesMoney/savesTime/servesClients/speedToFinish for unshipped projects | Reads priority object, only renders when status != "shipped" |

### Data Flow

```
                    [GitHub Push]
                         |
                    [GitHub Pages CDN]
                         |
              +----------+----------+
              |                     |
         index.html           projects.json
              |                     |
              +--- fetch() ---------+
              |
         Parse JSON into array
              |
         Compute summary stats
              |
         Apply active filter + sort
              |
         Render cards to DOM
              |
    [User clicks filter/sort/expand]
              |
         Re-filter/sort in memory
              |
         Re-render cards to DOM
```

**Key architectural decision:** All data transformation happens in-memory after the initial fetch. There is no persistent client-side state beyond the current filter/sort selection. Refreshing the page re-fetches the JSON and resets to defaults.

## Data Schema (projects.json)

```json
{
  "lastUpdated": "2026-03-25",
  "projects": [
    {
      "id": "str-analyzer",
      "name": "STR Analyzer",
      "status": "shipped",
      "version": "2.1.0",
      "description": "Short-term rental investment underwriting tool",
      "deployedUrl": "https://stranalyzer.vercel.app",
      "repoUrl": "https://github.com/Joshhoganliveaz/stranalyzer",
      "lastDeployed": "2026-03-20",
      "stack": ["Next.js", "TypeScript", "Supabase"],
      "health": {
        "adoption": 7,
        "autonomy": 5,
        "revenueProximity": 8
      },
      "priority": null,
      "versions": [
        {
          "version": "2.1.0",
          "date": "2026-03-20",
          "changes": "Added public investor view with shareable slug URLs"
        },
        {
          "version": "2.0.0",
          "date": "2026-03-01",
          "changes": "Supabase integration, PDF export, cost segregation module"
        }
      ],
      "roadmap": "Hospitable API integration for live revenue data"
    }
  ]
}
```

**Schema notes:**
- `health` scores are 1-10 integers (maps to percentage-width bars)
- `priority` is `null` for shipped projects; object with four 1-5 scores for unshipped
- `versions` array is newest-first (no client-side sorting needed)
- `status` is an enum: `"shipped"` | `"in-progress"` | `"parking-lot"`

## Patterns to Follow

### Pattern 1: Fetch-Parse-Render Pipeline

**What:** Single async function loads JSON, computes derived data, renders DOM.
**When:** On page load (DOMContentLoaded).

```javascript
let allProjects = [];

async function init() {
  const res = await fetch('./projects.json');
  allProjects = (await res.json()).projects;
  renderSummary(allProjects);
  renderCards(filterAndSort(allProjects));
}

document.addEventListener('DOMContentLoaded', init);
```

### Pattern 2: Functional Rendering with Template Literals

**What:** Pure functions that take data and return HTML strings. No virtual DOM, no state tracking.
**When:** Every render cycle.

```javascript
function renderCard(project) {
  return `
    <div class="project-card" data-status="${project.status}">
      <div class="card-header">
        <h3>${escapeHtml(project.name)}</h3>
        <span class="badge badge--${project.status}">${formatStatus(project.status)}</span>
      </div>
      ${renderHealthBars(project.health)}
      ${project.priority ? renderPriority(project.priority) : ''}
      ${renderVersionHistory(project.versions)}
      ${project.roadmap ? renderRoadmap(project.roadmap) : ''}
    </div>
  `;
}
```

### Pattern 3: Event Delegation for Filter/Sort

**What:** Single event listener on parent container, not individual buttons.
**When:** Filter tabs and sort dropdown interactions.

```javascript
document.querySelector('.filter-bar').addEventListener('click', (e) => {
  const filter = e.target.dataset.filter;
  if (!filter) return;
  setActiveFilter(filter);
  renderCards(filterAndSort(allProjects));
});
```

### Pattern 4: CSS-Driven Health Bars

**What:** Health bars use CSS custom properties set via inline styles, not JavaScript animation.
**When:** Rendering health scores.

```javascript
function renderHealthBars(health) {
  return `
    <div class="health-bar">
      <span class="health-label">Adoption</span>
      <div class="health-track">
        <div class="health-fill" style="--score: ${health.adoption * 10}%"></div>
      </div>
    </div>
  `;
}
```

```css
.health-fill {
  width: var(--score);
  transition: width 0.3s ease;
}
```

## Anti-Patterns to Avoid

### Anti-Pattern 1: Embedding Data in HTML

**What:** Hardcoding project data inside the HTML file.
**Why bad:** Claude Code would need to edit HTML to update data, risking template breakage. Defeats the entire maintenance model.
**Instead:** Always fetch from `projects.json`. The HTML file should never contain project-specific data.

### Anti-Pattern 2: Client-Side Routing / Hash Navigation

**What:** Adding `#shipped` or `#in-progress` URL fragments for filter states.
**Why bad:** Overengineering for a single-page dashboard. Adds complexity (popstate listeners, deep linking logic) with no benefit -- Jeff bookmarks one URL.
**Instead:** Filters are ephemeral UI state. Page always loads showing "All" projects.

### Anti-Pattern 3: Over-Componentizing with ES6 Classes

**What:** Creating a class hierarchy (BaseComponent, Card extends BaseComponent, etc.).
**Why bad:** For a static read-only dashboard with ~16 projects, class-based components add boilerplate without benefit. No state mutation, no lifecycle hooks needed.
**Instead:** Plain functions that return HTML strings. `renderCard(project)` not `new CardComponent(project).mount()`.

### Anti-Pattern 4: localStorage Caching of JSON

**What:** Caching `projects.json` in localStorage to avoid re-fetching.
**Why bad:** The whole point is that refreshing shows the latest data after Claude Code pushes an update. Caching defeats freshness.
**Instead:** Always fetch fresh. The JSON is tiny (< 50KB for 16 projects), GitHub Pages CDN is fast.

## Suggested Build Order

Based on component dependencies:

```
Phase 1: Foundation
  1. projects.json schema + seed data (everything depends on this)
  2. HTML skeleton with CSS variables (branding, layout grid)
  3. fetch() + parse pipeline

Phase 2: Core Rendering
  4. Summary stats bar (simplest render, validates data flow)
  5. Project card rendering (main visual, most complex)
  6. Health bars (sub-component of card)
  7. Version history accordion (sub-component of card)
  8. Roadmap box (sub-component of card)

Phase 3: Interactivity
  9. Filter by status
  10. Sort controls
  11. Priority score display (conditional on unshipped)

Phase 4: Polish + Deploy
  12. Responsive layout (mobile stacking)
  13. GitHub Pages deployment
  14. Seed data validation against real projects
```

**Dependency chain:** JSON schema (1) must come first -- everything renders from it. CSS variables (2) must precede card rendering. Summary stats (4) and cards (5) can be built in parallel. Filters (9-10) require cards to exist. Deploy (13) can happen as early as after step 5 for iterative feedback.

## Scalability Considerations

| Concern | At 16 projects (now) | At 50 projects | At 200+ projects |
|---------|---------------------|----------------|------------------|
| **JSON size** | ~10KB, instant load | ~30KB, still instant | Consider pagination or categories |
| **DOM nodes** | ~500, no performance concern | ~1,500, fine | Virtualize or collapse by default |
| **Render time** | Imperceptible | Imperceptible | May need requestAnimationFrame batching |
| **Maintenance** | Claude edits JSON directly | Still fine | Consider splitting into multiple JSON files by status |

**Realistic assessment:** This project will likely never exceed 30 projects. The architecture handles that trivially. Do not pre-optimize.

## GitHub Pages Deployment Details

- **Configuration:** Repository Settings > Pages > Source: Deploy from branch `main`, root `/`
- **Custom domain:** Optional. Default URL: `https://joshhoganliveaz.github.io/liveaz-project-tracker/`
- **Deploy trigger:** Any push to `main` triggers a GitHub Actions build (automatic, no config needed)
- **Latency:** Typically 30-90 seconds from push to live
- **Cache:** GitHub Pages uses aggressive caching. For JSON freshness, the fetch should include a cache-busting query param or rely on GitHub's cache headers (typically 10 min TTL for Pages).

**Cache-busting pattern for JSON:**
```javascript
const res = await fetch(`./projects.json?v=${Date.now()}`);
```

This ensures every page load gets the latest JSON without browser caching stale data.

## Sources

- Josh's existing Tenet Commission Calculator (`~/tenet-commission-calculator/index.html`) -- proven single-file HTML architecture
- Josh's existing CLAUDE.md -- project inventory for seed data
- [GitHub Pages JSON hosting pattern](https://victorscholz.medium.com/hosting-a-json-api-on-github-pages-47b402f72603) -- confirms fetch-from-same-origin works on Pages
- [Vanilla JS Component Pattern](https://dev.to/megazear7/the-vanilla-javascript-component-pattern-37la) -- functional rendering approach
- [Dashboard Design Patterns](https://dashboarddesignpatterns.github.io/patterns.html) -- layout and interaction patterns
