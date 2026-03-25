# Feature Landscape

**Domain:** Single-page project portfolio tracker / coaching accountability dashboard
**Researched:** 2026-03-25
**Context:** Static HTML+JSON site for Live AZ Co, deployed on GitHub Pages. Primary audience is Josh + his Tom Ferry coach Jeff Bannan on weekly calls. Secondary audience is team members (Jacqui, Suzie) as a tool catalog.

## Table Stakes

Features the audience (Jeff on coaching calls, team members) expects. Missing = page feels broken or useless.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Project cards with status badges | Core purpose -- show what exists and its state. The atomic unit of the entire page. | Low | Shipped/In Progress/Parking Lot with color-coded badges (Olive=shipped, Gold=in progress, Canyon=parking lot) |
| Summary stats bar | Jeff needs a 2-second read on portfolio health. Every dashboard has an aggregation row at top. | Low | Counts by status + overall health indicator. Position at top of page per dashboard design best practices. |
| Health bars (Adoption, Autonomy, Revenue Proximity) | Maps directly to Jeff's core coaching questions: "Is it deployed? Is it Jacqui-ready? Is it serving clients?" | Medium | Three horizontal bars per card, 0-10 scale, color-graded (0-3 red, 4-6 yellow, 7-10 green) |
| Filter by status | With ~16 projects, unfiltered is noise. Standard dashboard pattern. | Low | 4 buttons: All / Shipped / In Progress / Parking Lot |
| Deployed URL link | Proof of shipping -- Jeff clicks to verify a project is live | Low | Conditional display -- only show link if project has a deployedUrl |
| Version + deployed date | Shows recency and iteration velocity | Low | Prominent on each card |
| Responsive layout | Josh pulls this up on phone during walks with Jeff. Jeff may view on his phone. | Low | CSS Grid/Flexbox, cards stack on mobile, summary bar wraps. Breakpoint at ~768px. |
| Live AZ Co branding | Professional presentation for coaching context. Generic styling undermines credibility. | Low | Olive/Canyon/Gold/Cream/Charcoal + Source Serif 4 headings, DM Sans body |
| External data file (projects.json) | Separation of data from presentation. Critical for Claude Code maintenance workflow (update JSON, commit, auto-deploy). | Low | fetch() on page load, single JSON array |

## Differentiators

Not expected in a basic tracker, but create the "wow" on a coaching call. These turn a status page into a decision tool.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Priority scores for unshipped | Jeff can coach on WHAT to build next using structured criteria. Shows intentional prioritization, not just a backlog. | Medium | 4 dimensions: makesMoney, savesTime, servesClients, speedToFinish. Composite score as ranked badge. Only for In Progress / Parking Lot items. |
| Expandable version history | Shows shipping cadence and momentum. Jeff sees "4 versions in 2 months" vs "stuck at v0.1". Proves accountability over time. | Low | Native `<details>/<summary>`. Newest first. Each entry: version, date, one-line note. |
| "Up Next" roadmap box | Forward-looking coaching conversation starter. Jeff asks "what's next?" and the answer is right there. | Low | Single text field per project, 1-3 bullet points |
| Sort options | Let Jeff explore the portfolio from different angles -- "show me by autonomy level" or "recently deployed" | Low | Dropdown or buttons for sort dimension |
| Coaching-call-ready layout | Optimized for screen-sharing: large text, high contrast, minimal scrolling for summary view. Not a dense enterprise dashboard. | Low | Font sizes, spacing, and card sizing tuned for readability at screen-share resolution |
| Pre-populated seed data | v1.0 launches with real data from ~16 projects, not empty states. Immediate value on first coaching call. | Medium | Mine from CLAUDE.md, project memory, existing repos for versions, dates, health scores |
| Last-updated timestamp | Trust signal -- "this data is current as of today." Shows the page is alive and maintained. | Low | Global timestamp from JSON metadata or git commit date |

## Anti-Features

Features to explicitly NOT build. These are tempting but wrong for this project's constraints and audience.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Edit UI / Admin panel | Claude Code IS the editor. Building CRUD adds 10x complexity for zero value -- Josh already has the fastest possible update path. | Josh says "update STR Analyzer to v2.2" and Claude edits JSON, commits, auto-deploys. Under 60 seconds. |
| Database backend | JSON file is the entire "backend." Adding Supabase/Firebase adds auth, hosting costs, and complexity for ~16 records updated weekly. | `projects.json` in the repo, loaded via fetch() |
| Authentication / login | Audience is 3-5 people. Auth adds friction to the coaching call flow. | Obscure URL is sufficient. If paranoia grows, add a simple URL token query param. |
| Real-time updates / WebSocket | Static deploy. Updated weekly via git push. Real-time adds infrastructure for no user value. | Refresh to see changes. Last-updated timestamp shows freshness. |
| Charts / data visualization (D3, Chart.js) | Health bars ARE the visualization. A bar chart of 3 statuses adds library weight and visual noise without insight for ~16 items. | CSS-only percentage bars + summary stats cover all visual encoding needs |
| Gantt timelines / dependencies | Enterprise PPM feature. Josh's projects are independent tools, not a program with cross-dependencies. | Version history shows temporal progress. "Up Next" shows forward plans. |
| Team assignment / resource tracking | Solo developer portfolio. "Assigned to" is always Josh. Resource allocation is not a coaching conversation topic. | Omit entirely. If team grows, revisit. |
| Budget / cost tracking | Internal tools with zero direct cost (free hosting, Josh's time). Budget fields would be empty. | Revenue Proximity health score captures the business-value dimension. |
| Search / full-text search | 15-20 projects max. Visual scanning + filter tabs is faster than typing. | Filter buttons + sort cover all navigation needs |
| Notification system | 3-5 viewers, weekly updates. Email/push notifications are absurd for this scale. | Last-updated timestamp. Jeff checks it on their call. |
| Dark mode toggle | One theme, branded. Toggle adds JS/CSS complexity for a page viewed on coaching calls in normal lighting. | Ship the Cream/Olive branded theme only |
| Print / export to PDF | Jeff sees it live on the call. No one is printing this. | The live URL IS the deliverable |

## Feature Dependencies

```
projects.json schema definition (MUST be designed first)
  -> Summary stats bar (aggregates from JSON)
  -> Project cards (renders from JSON)
    -> Health bars (reads health scores from card data)
    -> Version history (reads versions array from card data)
    -> "Up Next" roadmap (reads roadmap field from card data)
    -> Priority scores (reads scoring fields from card data)
  -> Filter by status (operates on rendered cards)
  -> Sort options (reorders rendered cards)

Live AZ Co branding (independent, CSS-only)
Responsive layout (independent, CSS-only)
Last updated timestamp (reads from JSON metadata)
```

No circular dependencies. All rendering features depend on the JSON data load completing first. The **projects.json schema is the critical path** -- it must accommodate all card-level features (health scores, version history, roadmap notes, priority scores) from the start.

## MVP Recommendation

**Ship all table stakes + all differentiators in v1.0.** Total scope is small enough (single HTML file, ~400-500 lines of JS) that phasing adds overhead without reducing risk. This is not an enterprise app -- it is one page.

Build order (reflects dependency chain):
1. **projects.json schema + seed data** -- foundation for everything, critical path
2. **Project cards with all fields** -- core rendering
3. **Health bars** -- CSS-only percentage bars inside cards
4. **Summary stats bar** -- computed from rendered data
5. **Filter buttons** -- show/hide cards by status
6. **Sort options** -- reorder cards by dimension
7. **Expandable version history** -- native `<details>`, low effort
8. **Priority scores** -- conditional render for non-shipped items
9. **"Up Next" roadmap boxes** -- simple text per card
10. **Responsive layout + branding** -- CSS polish pass
11. **Last-updated timestamp** -- final touch

Total estimated effort: One focused build session. No phasing needed.

## Sources

- PROJECT.md requirements (validated against coaching call context)
- Josh's existing single-file projects (Tenet Calculator pattern)
- [Smartsheet: Project Portfolio Dashboards](https://www.smartsheet.com/content/project-portfolio-dashboards)
- [Teamhood: Project Portfolio Dashboard Guide](https://teamhood.com/project-management/project-portfolio-dashboard/)
- [Mastt: Dashboard Design Tips](https://www.mastt.com/blogs/project-status-dashboard-design-tips)
- [ITONICS: Living Project Portfolio Dashboard](https://www.itonics-innovation.com/blog/project-portfolio-dashboard)
- [Sciforma: What to Include in Portfolio Dashboard](https://www.sciforma.com/blog/what-should-be-included-in-a-project-portfolio-dashboard/)
- [Sisu: Real Estate Performance Platform](https://sisu.co/)
- [Coach Simple: Real Estate Coaching Software](https://realestate.coachsimple.net/)
