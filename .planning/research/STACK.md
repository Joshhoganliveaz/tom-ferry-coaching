# Technology Stack

**Project:** Live AZ Co Project Tracker
**Researched:** 2026-03-25

## Recommended Stack

### Core: Single HTML File + JSON Data

This is a zero-dependency project. No npm, no build step, no framework. The entire application is one `index.html` file that fetches a `projects.json` file at runtime.

This matches Josh's proven pattern from the Tenet Commission Calculator -- same architecture, different domain.

### Runtime Technologies

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Vanilla HTML5 | Current | Document structure | Zero dependencies is the constraint. No framework needed for a read-only card layout | HIGH |
| Vanilla CSS3 | Current | Styling, layout, responsiveness | CSS Grid + Flexbox handle every layout need. No utility framework needed for ~300 lines of styles | HIGH |
| Vanilla JavaScript (ES2020+) | Current | Data loading, filtering, sorting, expand/collapse | `fetch()` + `Array.filter/sort` + DOM manipulation is all that's needed. No state management complexity | HIGH |
| CSS Custom Properties | Current | Branding tokens (Olive, Canyon, Gold, Cream, Charcoal) | Single source of truth for brand colors, easy to update | HIGH |

### External Resources (CDN only)

| Resource | CDN | Purpose | Why |
|----------|-----|---------|-----|
| Google Fonts: Source Serif 4 | `fonts.googleapis.com` | Headings | Live AZ Co brand font per shared conventions |
| Google Fonts: DM Sans | `fonts.googleapis.com` | Body text | Live AZ Co brand font per shared conventions |

**Load both in one request:**
```html
<link href="https://fonts.googleapis.com/css2?family=Source+Serif+4:wght@400;600;700&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
```

### Data Layer

| Technology | Purpose | Why |
|------------|---------|-----|
| `projects.json` (separate file) | Project data source of truth | Claude Code edits JSON, commits, GitHub Pages auto-deploys. Clean separation of data from presentation |
| `fetch('./projects.json')` | Runtime data loading | Same-origin fetch from GitHub Pages -- no CORS issues. Works locally with any HTTP server |

### Deployment

| Technology | Purpose | Why | Confidence |
|------------|---------|-----|------------|
| GitHub Pages | Hosting | Free, auto-deploys on push to main, team can bookmark a stable URL. Josh already uses GitHub for all projects | HIGH |
| GitHub Pages (from `main` branch, root `/`) | Deploy config | Simplest config -- no `gh-pages` branch or Actions workflow needed. Push to main = live in ~60 seconds | HIGH |

## What NOT to Use

| Technology | Why Not |
|------------|---------|
| **Tailwind CSS** | Requires a build step (or the Play CDN adds 115KB+ runtime). CSS Custom Properties + a small stylesheet does the same job for this scope |
| **React / Vue / Svelte** | Massive overkill. This is a read-only page with filtering. Vanilla JS `innerHTML` or `createElement` handles it in ~100 lines |
| **Alpine.js** | Tempting for declarative behavior, but adds a dependency for what amounts to 3 event handlers (filter, sort, expand). Not worth the conceptual overhead |
| **Any CSS framework (Bootstrap, Bulma)** | Adds weight and fights custom branding. Josh's brand has specific colors/fonts that are easier to implement directly |
| **localStorage** | This is read-only. No user state to persist. Data lives in `projects.json` |
| **GitHub Actions for deploy** | Unnecessary for a static site served from `main` root. GitHub Pages auto-deploys without a workflow file |
| **Markdown / Static site generator (Jekyll, Hugo)** | Adds build complexity for a single page. The constraint is explicitly "single HTML file" |

## CSS Architecture Notes

Use modern CSS features that have full browser support in 2025/2026:

- **CSS Grid** for the summary stats bar and card layout (baseline support since 2017)
- **CSS Flexbox** for card internals, badges, header layout
- **CSS Custom Properties** (`--olive`, `--canyon`, etc.) for brand tokens
- **`details/summary`** HTML elements for expandable version history (native, no JS needed, styleable)
- **CSS `@media` queries** for responsive breakpoints (cards stack at ~768px)
- **`:has()` selector** -- available but not needed here. Stick with simpler selectors for maximum compatibility

**Skip:** Container queries (not needed -- page-level responsive is sufficient), CSS nesting (browser support still uneven for older Safari), `@layer` (unnecessary for this scope).

## Local Development

```bash
# Option 1: Python (already on macOS)
python3 -m http.server 8000

# Option 2: npx (if Node is available)
npx serve .
```

A local server is needed because `fetch('./projects.json')` requires HTTP, not `file://`.

## JSON Schema Pattern

```json
{
  "lastUpdated": "2026-03-25",
  "projects": [
    {
      "name": "STR Analyzer",
      "slug": "str-analyzer",
      "status": "shipped",
      "version": "2.1.0",
      "deployedDate": "2026-03-20",
      "url": "https://stranalyzer.com",
      "description": "Short-term rental underwriting calculator",
      "health": {
        "adoption": 8,
        "autonomy": 6,
        "revenueProximity": 7
      },
      "priority": {
        "makesMoney": 9,
        "savesTime": 7,
        "servesClients": 8,
        "speedToFinish": 10
      },
      "versionHistory": [
        { "version": "2.1.0", "date": "2026-03-20", "notes": "Added stress testing" },
        { "version": "2.0.0", "date": "2026-02-15", "notes": "Complete redesign" }
      ],
      "upNext": "Investor comparison mode"
    }
  ]
}
```

This schema covers every requirement from PROJECT.md: status badges, health bars, version history, priority scores, and roadmap notes.

## Sources

- Josh's existing Tenet Commission Calculator (`~/tenet-commission-calculator/index.html`) -- proven single-file HTML pattern
- [GitHub Pages documentation](https://pages.github.com/) -- static site deployment
- [Google Fonts](https://fonts.google.com/) -- Source Serif 4 and DM Sans availability
- [CSS Container Queries browser support](https://caniuse.com/css-container-queries) -- verified baseline support status
