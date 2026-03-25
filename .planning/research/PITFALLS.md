# Domain Pitfalls

**Domain:** Single-page static project portfolio tracker (HTML + JSON, GitHub Pages)
**Researched:** 2026-03-25

## Critical Pitfalls

Mistakes that cause rewrites, broken deployments, or abandoned maintenance.

### Pitfall 1: Browser Caching Serves Stale JSON

**What goes wrong:** After updating `projects.json` and deploying, users (especially Jeff on a coaching call) see the old data. GitHub Pages sets aggressive cache headers on static assets. The browser serves the cached version of `projects.json` and the page looks unchanged.

**Why it happens:** `fetch("projects.json")` without cache-busting parameters hits the browser cache. GitHub Pages default caching is 10 minutes for static files, but browsers can cache longer. There is no build step to generate a hash-based filename.

**Consequences:** Josh updates project data, pushes, tells Jeff to refresh -- Jeff still sees last week's data. Destroys trust in the tool during the exact moment it matters (live coaching call).

**Prevention:**
- Fetch with cache-busting query param: `fetch("projects.json?v=" + Date.now())` or use `fetch("projects.json", { cache: "no-store" })`.
- Add a `<meta>` cache-control header as a belt-and-suspenders measure.
- Include a visible "last updated" timestamp rendered from the JSON so staleness is immediately obvious.

**Detection:** If the "last updated" timestamp on the page does not match the latest commit, the cache is stale.

**Phase:** Must be addressed in Phase 1 (initial build). This is not a nice-to-have -- it will bite on the first coaching call after an update.

---

### Pitfall 2: JSON Schema Drift Makes Claude Code Updates Fragile

**What goes wrong:** The `projects.json` structure evolves informally -- a field gets added here, a naming convention changes there. Claude Code starts producing updates that break rendering because the HTML template expects one shape and the data has another.

**Why it happens:** No schema validation. No TypeScript. No tests. The "contract" between the JSON and the HTML lives only in the developer's (or Claude's) memory. With 15+ projects and multiple fields per project (health scores, versions, priority scores, roadmap notes), inconsistency creeps in fast.

**Consequences:** A project card renders with "undefined" for a field, or a health bar breaks because a score is a string instead of a number, or a new project is missing a required field entirely.

**Prevention:**
- Define the schema explicitly in a comment block at the top of `projects.json` or in a separate `SCHEMA.md`.
- Write a validation function in the HTML that checks each project object on load and logs warnings to console for missing/malformed fields.
- Provide Claude Code with a template object when adding new projects (a "blank project" shape in the JSON or docs).
- Use defensive rendering: `project.version || "unreleased"`, `project.health?.adoption ?? 0`.

**Detection:** Console warnings on page load. Visual: any card showing "undefined", "NaN", or missing badges.

**Phase:** Phase 1. Bake validation and defensive rendering into the initial build. Adding it later means every existing project entry is a potential landmine.

---

### Pitfall 3: Card Layout Breaks on Mobile Mid-Call

**What goes wrong:** The dashboard looks great on Josh's laptop during development. On Jeff's phone or tablet during a coaching call, cards overflow, text truncates badly, health bars collapse, or the summary stats bar wraps into an unreadable mess.

**Why it happens:** CSS Grid/Flexbox card layouts that work at desktop widths often have subtle overflow issues on narrow viewports. Long project names, version strings, or URL text break layouts. Expandable sections (version history) push cards off-screen.

**Consequences:** Jeff can't read the dashboard on his device. Josh has to screen-share instead of sending a link, defeating the "pull up one URL" value proposition.

**Prevention:**
- Design mobile-first. Start with single-column card stack, add grid columns via `min-width` media queries.
- Set `overflow-wrap: break-word` and `min-width: 0` on card text containers.
- Cap version history to 3 visible entries with "show more" toggle rather than rendering all entries.
- Test on actual phone viewport (375px width) during development, not just browser resize.
- Add `max-width` constraints on URL text with `text-overflow: ellipsis`.

**Detection:** Open the deployed URL on a phone before every coaching call.

**Phase:** Phase 1. Responsive layout must be part of the initial CSS, not retrofitted.

---

## Moderate Pitfalls

### Pitfall 4: Expandable Sections Create Scroll Confusion

**What goes wrong:** Clicking to expand version history or roadmap notes on one card pushes all cards below it down the page. On mobile, the user loses their scroll position. With 15+ project cards, expanding multiple sections makes the page feel endless and disorienting.

**Why it happens:** Expanding content in a flow layout shifts everything below. No scroll anchoring. No visual indication of how much content will appear.

**Prevention:**
- Use CSS `scroll-margin-top` on cards so they anchor correctly when expanded.
- Limit expandable content height with `max-height` + `overflow-y: auto` to prevent unbounded growth.
- Consider showing expanded details in a fixed-position overlay/modal on mobile rather than inline expansion.
- Add smooth scroll-to-card behavior when expanding.

**Phase:** Phase 1, but refinement can happen in a polish pass.

---

### Pitfall 5: Health Score Numbers Without Context Are Meaningless

**What goes wrong:** Jeff sees "Adoption: 3, Autonomy: 2, Revenue Proximity: 4" and has no idea what that means. Is 3 good? Out of 5? Out of 10? The numbers become decoration rather than insight.

**Why it happens:** Developer builds the scoring system with internal logic but forgets the audience has no mental model for the scale. Dashboards commonly overload with metrics that lack framing.

**Consequences:** Jeff asks "what does a 3 mean?" every call. The health scores add visual noise without aiding the conversation. Eventually they get ignored.

**Prevention:**
- Use a clear 1-5 scale with color coding (red/yellow/green gradient).
- Add tooltip or hover text explaining each dimension: "Adoption: Is the team actually using it? 1=Josh only, 3=Jacqui uses it, 5=whole team uses it daily."
- Show labels alongside numbers: "3/5 - Team Aware" not just "3".
- Include a legend or footer with the scale definitions.

**Detection:** If Jeff asks "what does this number mean?" even once, the labeling is insufficient.

**Phase:** Phase 1. The health scores are a core feature for coaching calls -- they must be self-explanatory from day one.

---

### Pitfall 6: Summary Stats Bar Becomes Stale Decoration

**What goes wrong:** The summary stats bar (counts by status, health levels) is hardcoded or manually maintained separately from the project data. It shows "5 Shipped" while the cards show 6 shipped projects.

**Why it happens:** If summary stats are static values in the JSON rather than computed from the project array, they drift immediately on the first update.

**Consequences:** Contradictory numbers on the same page. Looks sloppy.

**Prevention:**
- Compute ALL summary stats dynamically from the project array in JavaScript. Never store computed aggregates in the JSON.
- The JSON should contain only project-level data. Page-level stats are derived.

**Detection:** Compare summary bar numbers against manually counting the visible cards.

**Phase:** Phase 1. This is an architectural decision that must be correct from the start.

---

### Pitfall 7: GitHub Pages Deploy Delay Causes Confusion

**What goes wrong:** Josh pushes an update, tells Jeff to check the URL, but GitHub Pages hasn't rebuilt yet. The site shows old content for 1-3 minutes.

**Why it happens:** GitHub Pages builds are not instant. There's a queue, and deploys can take 30 seconds to several minutes. There's no webhook or notification when the deploy completes.

**Consequences:** Josh thinks something broke. Jeff sees old data. Scrambling during a coaching call.

**Prevention:**
- Include a visible build timestamp or git SHA in the page footer so it's obvious which version is live.
- After pushing, check the GitHub Actions tab or `gh api repos/{owner}/{repo}/pages/builds` to confirm deploy status before sharing.
- Document the "push and wait 60 seconds" workflow so it becomes habit.
- If timing is critical, use `gh pages` CLI to verify deployment status.

**Detection:** Footer timestamp does not match the latest commit timestamp.

**Phase:** Phase 1. The build timestamp should be part of the initial template.

---

## Minor Pitfalls

### Pitfall 8: Font Loading Delays Cause Layout Shift

**What goes wrong:** Source Serif 4 and DM Sans are loaded from Google Fonts. On slow connections, the page renders with system fonts first, then shifts when custom fonts load. Cards resize, text reflows, and the page jumps.

**Prevention:**
- Use `font-display: swap` (Google Fonts default) but also set explicit `line-height` and approximate `font-size` to minimize CLS.
- Preload the font files: `<link rel="preload" href="..." as="font" crossorigin>`.
- Consider self-hosting the two font files to eliminate the Google Fonts round-trip entirely (the fonts are open source).

**Phase:** Phase 1 (font link setup) with optional self-hosting optimization later.

---

### Pitfall 9: Filter/Sort State Lost on Page Refresh

**What goes wrong:** Jeff filters to "In Progress" projects during a call, then refreshes the page and loses the filter. Minor, but friction during a live conversation.

**Prevention:**
- Persist filter/sort state in the URL hash: `#status=in-progress&sort=deployed`.
- On page load, read the hash and apply filters before rendering.
- This also makes filtered views shareable ("here's my shipped projects" as a direct link).

**Phase:** Phase 1 if simple hash-based routing is used. Otherwise Phase 2 polish.

---

### Pitfall 10: Priority Score Formula Is Opaque

**What goes wrong:** The priority scores (makesMoney, savesTime, servesClients, speedToFinish) are shown but the weighting or composite score calculation is invisible. Jeff can't tell why Project A ranks above Project B.

**Prevention:**
- Show the individual dimension scores, not just a composite.
- If there's a composite, show the formula: "Priority = (Money x2 + Time + Clients) / Speed".
- Use visual indicators (filled dots or bar segments) rather than raw numbers.

**Phase:** Phase 1. Priority scores are explicitly called out as a coaching call feature.

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Initial HTML + JSON build | Schema drift (#2), stale cache (#1) | Define schema upfront, add cache-busting from day one |
| Responsive layout | Mobile overflow (#3), expand/collapse scroll issues (#4) | Mobile-first CSS, test on 375px viewport |
| Health score rendering | Meaningless numbers (#5), stale summary (#6) | Labels + color coding, compute stats dynamically |
| GitHub Pages deployment | Deploy delay (#7), caching (#1) | Build timestamp in footer, cache-bust fetch |
| Coaching call readiness | All of the above converging | Pre-call checklist: push, wait 60s, verify on phone |
| Ongoing maintenance via Claude Code | Schema drift (#2) | Schema docs, validation function, template object for new projects |

## Sources

- [GitHub Community Discussion: Pages Caching](https://github.com/orgs/community/discussions/11884)
- [GitHub Community Discussion: CORS on Pages](https://github.com/orgs/community/discussions/22399)
- [MDN: Request cache property](https://developer.mozilla.org/en-US/docs/Web/API/Request/cache)
- [CSS Overflow Pitfalls - PixelFree Studio](https://blog.pixelfreestudio.com/breaking-out-of-the-box-dealing-with-overflow-pitfalls-in-css/)
- [JSON Best Practices for Clean Data Structures](https://jsonconsole.com/blog/json-best-practices-writing-clean-maintainable-data-structures)
- [Dashboard Design Principles 2026 - DesignRush](https://www.designrush.com/agency/ui-ux-design/dashboard/trends/dashboard-design-principles)
- [Prevent Caching on Fetch Requests - Brian Hough](https://brianhhough.com/howto/prevent-caching-on-fetch-requests-to-an-api)
