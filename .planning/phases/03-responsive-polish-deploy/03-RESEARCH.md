# Phase 3: Responsive Polish + Deploy - Research

**Researched:** 2026-03-25
**Domain:** CSS responsive design, GitHub Pages deployment, CLI automation
**Confidence:** HIGH

## Summary

Phase 3 covers three distinct tasks: (1) making the existing single-file HTML tracker responsive at 375px mobile viewports, (2) deploying it to GitHub Pages from the main branch, and (3) ensuring Claude Code can update projects.json, commit, push, and see changes live within 60 seconds.

The current `index.html` already has a solid CSS foundation with `flex-wrap` on the summary stats bar and a single-column grid layout. The responsive work is primarily about ensuring nothing overflows on narrow screens -- adjusting padding, font sizes, health bar label widths, and filter tab layout at 375px. GitHub Pages deployment is straightforward: create a public repo, push to main, enable Pages via the GitHub API, and add a `.nojekyll` file to skip Jekyll processing.

**Primary recommendation:** Use CSS media queries at `max-width: 480px` for mobile polish, deploy via `gh repo create` + `gh api` for Pages enablement, and inline the project data (already done) so the deploy is a simple static file serve with zero build step.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| VIS-03 | Responsive layout -- cards stack vertically on mobile (375px+), summary stats bar wraps gracefully | CSS media query patterns for the existing layout; health bar label width reduction; filter tab wrapping |
| DEPLOY-02 | GitHub Pages deployment from main branch, auto-deploys on push | `gh repo create --public --source=.` + `gh api POST /repos/{owner}/{repo}/pages` with source branch main, path / |
| DEPLOY-03 | Claude Code can update projects.json, commit, and push to trigger deploy in under 60 seconds | Inline data update workflow: edit projects.json, run build-inline script or sed replacement, commit, push; Pages deploys in ~30s for small static sites |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Vanilla CSS | N/A | Responsive media queries | Zero dependencies per DEPLOY-01 decision |
| GitHub Pages | N/A | Static hosting | Free, auto-deploy on push, decision already locked |
| gh CLI | 2.x | Repo creation + Pages API | Already authenticated on this machine |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `.nojekyll` | N/A | Skip Jekyll build | Required -- without it GitHub Pages tries to process through Jekyll which can break things or add latency |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| GitHub Pages | Cloudflare Pages | More features but more complex; GH Pages is the locked decision |
| CSS media queries | Container queries | Modern but unnecessary for this simple layout |

## Architecture Patterns

### Current Project Structure
```
Tom Ferry Coaching/
  index.html          # Single HTML file with embedded CSS + JS + inline data
  projects.json       # Source of truth for project data (also inlined in HTML)
  .nojekyll           # NEW: prevents Jekyll processing on GitHub Pages
  .planning/          # GSD planning docs
```

### Pattern 1: Mobile-First Media Query Approach
**What:** Add a single `@media (max-width: 480px)` block to handle 375px-480px viewport adjustments
**When to use:** When the desktop layout is already simple and mostly works on mobile
**Example:**
```css
@media (max-width: 480px) {
  header { padding: 1.25rem 0.75rem; }
  header h1 { font-size: 1.35rem; }

  .summary-stats { gap: 0.5rem; }
  .stat-item { min-width: 100px; padding: 0.5rem 0.75rem; flex: 1 1 calc(50% - 0.5rem); }

  .filter-bar { flex-direction: column; align-items: stretch; }
  .filter-tabs { flex-wrap: wrap; justify-content: center; }
  .sort-controls { justify-content: center; }

  .project-card { padding: 1rem; }

  .health-label { width: 5rem; font-size: 0.78rem; }
  .health-text { width: 5.5rem; font-size: 0.75rem; }

  .card-header h3 { font-size: 1rem; }

  .priority-scores { gap: 0.75rem; }
}
```

### Pattern 2: Data Update Workflow for DEPLOY-03
**What:** Claude Code edits `projects.json`, then updates the inline copy in `index.html`, commits both, and pushes
**When to use:** Every time project data needs updating
**Example workflow:**
```bash
# 1. Edit projects.json (source of truth)
# 2. Update inline data in index.html
#    The inline data is on a single line: const PROJECT_DATA = {...};
#    Replace it with the new JSON content
# 3. Commit and push
git add projects.json index.html
git commit -m "data: update project tracker"
git push origin main
# GitHub Pages auto-deploys within ~30-60 seconds
```

### Pattern 3: GitHub Pages Setup via CLI
**What:** Create repo, push code, enable Pages -- all from command line
**When to use:** Initial deployment setup
**Example:**
```bash
# Create public repo (name determines URL)
gh repo create Joshhoganliveaz/tom-ferry-coaching --public --source=. --push

# Enable GitHub Pages on main branch, root folder
gh api --method POST /repos/Joshhoganliveaz/tom-ferry-coaching/pages \
  -f "source[branch]=main" -f "source[path]=/"

# Add .nojekyll to prevent Jekyll processing
touch .nojekyll
git add .nojekyll && git commit -m "deploy: add .nojekyll" && git push
```

### Anti-Patterns to Avoid
- **Over-engineering responsive CSS:** The layout is already single-column with flex-wrap. Do NOT add a CSS framework or complex grid system. A single media query block is sufficient.
- **Separate gh-pages branch:** Deploy from main directly. No need for a separate branch or GitHub Actions workflow for a static site.
- **Removing inline data in favor of fetch:** The project already inlined data (Phase 2 decision). Keep it. The separate `projects.json` stays as the source-of-truth for editing, and the inline copy in HTML is what runs.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Static hosting | Custom server or CI/CD | GitHub Pages from main | Zero config, auto-deploy on push |
| Pages enablement | Manual GitHub UI settings | `gh api POST .../pages` | Scriptable, reproducible |
| Mobile testing | Guessing at breakpoints | Chrome DevTools device mode at 375px | Exact iPhone SE viewport |

## Common Pitfalls

### Pitfall 1: Horizontal Scroll on Mobile
**What goes wrong:** Elements with fixed widths or min-widths cause horizontal overflow at 375px
**Why it happens:** The health bar labels (`width: 7rem` = 112px) + track + text labels can exceed 375px minus padding
**How to avoid:** Reduce `.health-label` to ~5rem and `.health-text` to ~5.5rem at mobile breakpoint. Also ensure `.stat-item` min-width is reduced.
**Warning signs:** Horizontal scrollbar appears; content extends past viewport edge

### Pitfall 2: Jekyll Processing on GitHub Pages
**What goes wrong:** GitHub Pages runs Jekyll by default, which can ignore files starting with underscores and add processing time
**Why it happens:** Jekyll is the default build engine for GitHub Pages
**How to avoid:** Add an empty `.nojekyll` file to the repository root
**Warning signs:** Deploy takes longer than expected; files with underscores in names are missing

### Pitfall 3: GitHub Pages Cache / 404 After Enable
**What goes wrong:** After enabling Pages, the site shows 404 for several minutes
**Why it happens:** First deploy takes longer; GitHub CDN needs time to propagate
**How to avoid:** Wait 2-3 minutes after initial setup. Subsequent pushes deploy in ~30 seconds.
**Warning signs:** 404 immediately after enabling -- this is normal, just wait

### Pitfall 4: Inline Data Sync
**What goes wrong:** `projects.json` gets updated but `index.html` inline data does not, causing stale display
**Why it happens:** Two copies of the data exist (file + inline)
**How to avoid:** Always update BOTH in the same commit. The update workflow must be: edit JSON file -> update inline copy in HTML -> commit both
**Warning signs:** Data on live site doesn't match projects.json file

### Pitfall 5: Repo Visibility for GitHub Pages
**What goes wrong:** GitHub Pages requires a public repo (on free GitHub plans) for Pages to work
**Why it happens:** Free GitHub accounts cannot use Pages with private repos
**How to avoid:** Create the repo as `--public`. Note: project names will be visible. This was already flagged as a blocker/concern in STATE.md.
**Warning signs:** Pages settings greyed out or unavailable

## Code Examples

### Responsive Media Query Block (verified against current CSS)
```css
/* Mobile responsive - 375px+ viewport */
@media (max-width: 480px) {
  header {
    padding: 1.25rem 0.75rem;
  }

  header h1 {
    font-size: 1.35rem;
  }

  main {
    padding: 1.25rem 0.5rem;
  }

  /* Stats bar: 2 per row on small screens */
  .summary-stats {
    gap: 0.5rem;
    padding: 0 0.5rem;
  }

  .stat-item {
    min-width: 0;
    flex: 1 1 calc(50% - 0.5rem);
    padding: 0.5rem 0.75rem;
  }

  .stat-count {
    font-size: 1.25rem;
  }

  /* Filter bar: stack vertically */
  .filter-bar {
    flex-direction: column;
    align-items: stretch;
    padding: 0 0.5rem;
  }

  .filter-tabs {
    flex-wrap: wrap;
    justify-content: center;
  }

  .filter-tab {
    padding: 0.35rem 0.75rem;
    font-size: 0.8rem;
  }

  .sort-controls {
    justify-content: center;
  }

  /* Cards: tighter padding */
  .project-grid {
    padding: 0 0.5rem;
  }

  .project-card {
    padding: 1rem;
  }

  .card-header h3 {
    font-size: 1rem;
  }

  /* Health bars: narrower labels to fit */
  .health-label {
    width: 5rem;
    font-size: 0.78rem;
  }

  .health-text {
    width: 5.5rem;
    font-size: 0.75rem;
  }

  /* Priority scores: tighter */
  .priority-scores {
    gap: 0.5rem 0.75rem;
  }
}
```

### GitHub Pages Setup Commands
```bash
# Step 1: Create public repo from current directory
gh repo create Joshhoganliveaz/tom-ferry-coaching \
  --public \
  --source=. \
  --push \
  --description "Live AZ Co Project Tracker for coaching calls"

# Step 2: Add .nojekyll file
touch .nojekyll
git add .nojekyll
git commit -m "deploy: add .nojekyll to skip Jekyll processing"
git push origin main

# Step 3: Enable GitHub Pages via API
gh api --method POST /repos/Joshhoganliveaz/tom-ferry-coaching/pages \
  -f "source[branch]=main" \
  -f "source[path]=/"

# Site will be available at:
# https://joshhoganliveaz.github.io/tom-ferry-coaching/
```

### Data Update Script (for DEPLOY-03)
```bash
# After editing projects.json, update the inline copy:
# The inline data line looks like: const PROJECT_DATA = {...};
# Use node to safely generate the replacement

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('projects.json', 'utf8'));
const html = fs.readFileSync('index.html', 'utf8');
const updated = html.replace(
  /const PROJECT_DATA = .*?;/,
  'const PROJECT_DATA = ' + JSON.stringify(data) + ';'
);
fs.writeFileSync('index.html', updated);
console.log('Inline data updated.');
"

git add projects.json index.html
git commit -m "data: update project tracker"
git push origin main
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| gh-pages branch | Deploy from main branch directly | GitHub Pages settings update ~2022 | No need for separate branch; simpler workflow |
| Jekyll default | `.nojekyll` bypass | Long-standing | Faster deploys, no processing issues |
| Manual Pages setup | `gh api POST .../pages` | gh CLI 2.x | Fully scriptable from command line |

## Open Questions

1. **Repository name**
   - What we know: The project directory is "Tom Ferry Coaching" but GitHub repo names use hyphens
   - What's unclear: Josh may want a different repo name; also whether he's comfortable with public visibility (flagged in STATE.md blockers)
   - Recommendation: Use `tom-ferry-coaching` as repo name. The planner should note that Josh needs to confirm public repo is OK since project names become visible at the GitHub Pages URL.

2. **Inline data sync automation**
   - What we know: Data exists in both `projects.json` and inline in `index.html`
   - What's unclear: Whether to keep the dual-copy approach or switch to fetch-based loading for production
   - Recommendation: Keep inline (matches Phase 2 decision). The node script above handles sync reliably. Claude Code should always run the sync script before committing.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Manual browser testing (no JS test framework - vanilla HTML project) |
| Config file | none |
| Quick run command | Open index.html in Chrome DevTools responsive mode at 375px |
| Full suite command | Manual checklist verification |

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| VIS-03 | Cards stack vertically, stats wrap, no horizontal scroll at 375px | manual | Chrome DevTools > Toggle device toolbar > iPhone SE (375px) | N/A |
| DEPLOY-02 | Site live on GitHub Pages, auto-deploys on push | smoke | `curl -s -o /dev/null -w "%{http_code}" https://joshhoganliveaz.github.io/tom-ferry-coaching/` | N/A |
| DEPLOY-03 | Push triggers deploy visible within 60s | smoke | Edit projects.json, commit, push, then curl the URL after 60s | N/A |

### Sampling Rate
- **Per task commit:** Visual inspection in browser at 375px width
- **Per wave merge:** Full smoke test of deployed site
- **Phase gate:** All three requirements verified before `/gsd:verify-work`

### Wave 0 Gaps
None -- no test framework needed for this vanilla HTML project. All verification is manual/smoke testing.

## Sources

### Primary (HIGH confidence)
- [GitHub Pages Docs - Configuring publishing source](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site) - Branch deploy setup, folder options
- [GitHub REST API - Pages endpoints](https://docs.github.com/en/rest/pages/pages) - POST /repos/{owner}/{repo}/pages API for enabling Pages
- [GitHub CLI Manual - repo create](https://cli.github.com/manual/gh_repo_create) - `gh repo create` flags and options
- Direct inspection of current `index.html` (884 lines) - CSS layout analysis, inline data pattern

### Secondary (MEDIUM confidence)
- [GitHub Community Discussion #51268](https://github.com/orgs/community/discussions/51268) - Enabling Pages via `gh api` workaround
- [GitHub Community Discussion #35595](https://github.com/orgs/community/discussions/35595) - API permissions for Pages enablement

### Tertiary (LOW confidence)
- Deploy timing (~30-60 seconds for small sites) - based on general experience, not officially documented with precision

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - vanilla CSS + GitHub Pages, well-documented, no ambiguity
- Architecture: HIGH - current codebase inspected directly, patterns clear
- Pitfalls: HIGH - common issues well-documented in GitHub community discussions
- Deploy timing: MEDIUM - 60-second target is tight but achievable for small static sites

**Research date:** 2026-03-25
**Valid until:** 2026-04-25 (stable technologies, no fast-moving dependencies)
