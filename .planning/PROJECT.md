# Live AZ Co Project Tracker

## What This Is

A single-page deployed site that serves as Josh's project portfolio tracker for Live AZ Co. Shows every tool and system built, its current version, deployment status, health scores, version history, and roadmap notes. Built for coaching call accountability with Jeff Bannan (Tom Ferry) and as a read-only catalog for the team.

## Core Value

Josh can pull up one URL on a coaching call and Jeff instantly sees what's shipped, what's in progress, and the health of each project.

## Requirements

### Validated

(None yet -- ship to validate)

### Active

- [ ] Summary stats bar showing counts by status and health level
- [ ] Project cards with name, status badge, version, deployed date/URL
- [ ] Three health bars per project (Adoption, Autonomy, Revenue Proximity)
- [ ] Expandable version history per project (newest first)
- [ ] "Up Next" roadmap box per project
- [ ] Priority scores (makesMoney, savesTime, servesClients, speedToFinish) for unshipped projects
- [ ] Filter by status: All / Shipped / In Progress / Parking Lot
- [ ] Sort options (recently deployed, autonomy level)
- [ ] Separate projects.json data file loaded by HTML
- [ ] Pre-populated seed data from existing projects (versions, dates, health scores from CLAUDE.md/memory)
- [ ] Responsive layout (cards stack on mobile, summary bar wraps)
- [ ] Live AZ Co branding (Olive, Canyon, Gold, Cream, Charcoal; Source Serif 4 + DM Sans)
- [ ] GitHub Pages deployment (auto-deploy on push to main)
- [ ] Claude Code maintenance workflow (update JSON, commit, auto-deploy)

### Out of Scope

- Admin panel or UI-based editing -- Claude Code is the editor
- Database or backend -- JSON file is the source of truth
- Authentication -- obscure URL is sufficient for the audience
- Real-time updates -- static deploy, refresh to see changes

## Context

- **Origin:** Tom Ferry coaching call with Jeff Bannan, March 25 2026. Jeff's "completed and deployed" list, but alive.
- **Audiences:** Josh (accountability, roadmap planning), Jacqui & Suzie (tool catalog), Jeff (weekly progress)
- **Existing projects:** ~5 shipped, ~6 in progress, ~5 parking lot. Data pulled from CLAUDE.md and project memory.
- **Health scoring:** Three dimensions map to Jeff's core questions: "Is it deployed? Is it Jackie-ready? Is it serving clients?"
- **Maintenance model:** Josh tells Claude Code what changed, Claude updates projects.json, commit triggers deploy. Under 60 seconds.
- **Repo:** Will live in its own GitHub repo (e.g., liveaz-project-tracker) for clean GitHub Pages deployment.

## Constraints

- **Tech stack**: Single HTML file + separate projects.json -- no build process, no dependencies
- **Deployment**: GitHub Pages auto-deploy on push to main
- **Branding**: Live AZ Co colors and fonts (Olive #5C6B4F, Canyon #8B6F5C, Gold #C9953E, Cream #FAF7F2, Charcoal #2C2C2C, Source Serif 4/DM Sans)
- **Timeline**: Ship as v1.0 this week (week of March 25, 2026)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Single HTML + JSON, no framework | Zero dependencies, instant load, trivial to maintain | -- Pending |
| GitHub Pages over Cloudflare | Simplest deploy for a static page, team can bookmark | -- Pending |
| Own repo, not subfolder | Clean GitHub Pages deploy, separate concerns from coaching project | -- Pending |
| Claude Code as sole editor | No admin panel needed, Josh maintains via natural language | -- Pending |
| Include priority scores in v1 | Jeff uses these rankings in coaching calls | -- Pending |
| Pre-populate seed data | Faster to validate than stubbing out and filling later | -- Pending |

---
*Last updated: 2026-03-25 after initialization*
