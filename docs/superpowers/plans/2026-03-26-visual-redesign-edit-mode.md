# Project Tracker v2: Visual Redesign + Edit Mode Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign project cards to use score circles with stack tags, and replace raw drag-and-drop with a dedicated edit/reorder mode using compact rows.

**Architecture:** Single-file modification of `index.html`. CSS changes first (remove old styles, add new), then JS changes (score calculation, new card renderer, edit mode system with pointer-event drag). No external dependencies, no new files.

**Tech Stack:** Vanilla HTML/CSS/JS, localStorage API, Pointer Events API

**Spec:** `docs/superpowers/specs/2026-03-26-visual-redesign-edit-mode-design.md`

---

## Chunk 1: CSS Overhaul + Score Calculation + Card Redesign

### Task 1: Replace health bar CSS with new card styles

**Files:**
- Modify: `index.html` (CSS section, lines 10-475)

This task removes old health bar CSS and adds all new styles needed for the redesigned cards, edit mode, and visual refinements.

- [ ] **Step 1: Remove old health bar and drag-and-drop CSS**

Remove these CSS blocks from the `<style>` section:

```css
/* REMOVE: Health Bars (lines ~173-213) */
.health-bars { ... }
.health-bar { ... }
.health-label { ... }
.health-track { ... }
.health-fill { ... }
.health-text { ... }

/* REMOVE: Drag-and-drop styles - find and remove these wherever they appear */
.project-card[draggable="true"] { ... }
.project-card[draggable="true"]:active { ... }
.project-card.dragging { ... }
.project-card.drag-over { ... }
```

Also remove the mobile health bar overrides in the `@media (max-width: 480px)` block:

```css
/* REMOVE from mobile block */
.health-label { width: 5rem; font-size: 0.78rem; }
.health-text { width: 5.5rem; font-size: 0.75rem; }
```

- [ ] **Step 2: Add new CSS for score circle, stack tags, bottom bar, card hover, and edit mode**

Add these new styles after the existing `.priority-value` block and before the `@media` query:

```css
/* --- Score Circle --- */
.score-circle {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  border: 3px solid var(--canyon);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.score-circle .score-value {
  font-weight: 700;
  font-size: 0.85rem;
}

.score-tier-olive { border-color: var(--olive); color: var(--olive); }
.score-tier-gold { border-color: var(--gold); color: var(--gold); }
.score-tier-canyon { border-color: var(--canyon); color: var(--canyon); }

/* --- Card Header (redesigned for score circle) --- */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
}

.card-header-left {
  flex: 1;
  min-width: 0;
}

/* --- Stack Tags --- */
.stack-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.3rem;
  margin-top: 0.5rem;
}

.stack-tag {
  background: #f0ede8;
  color: #666;
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 0.6rem;
}

/* --- Health Dot Indicators (bottom bar) --- */
.health-dots {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
  padding-top: 0.5rem;
  margin-top: 0.5rem;
  border-top: 1px solid #eee;
}

.health-dot {
  font-size: 0.65rem;
  font-weight: 600;
}

/* --- Card Hover --- */
.project-card {
  transition: transform 0.15s ease, box-shadow 0.15s ease;
}

@media (hover: hover) {
  .project-card:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }
}

/* --- Edit/Reorder Mode --- */
.reorder-btn {
  border: 1px solid #ddd;
  background: white;
  padding: 0.3rem 0.75rem;
  border-radius: 4px;
  cursor: pointer;
  font-family: var(--font-body);
  font-size: 0.85rem;
  margin-left: 0.5rem;
}

.reorder-btn:hover {
  border-color: var(--olive);
}

.reorder-btn.active {
  background: var(--olive);
  color: white;
  border-color: var(--olive);
}

.controls-disabled {
  opacity: 0.5;
  pointer-events: none;
}

/* --- Compact Row (edit mode) --- */
.compact-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: white;
  padding: 0.6rem 0.75rem;
  border-radius: 6px;
  border: 1px solid #e8e5e0;
}

.compact-row.drag-source {
  opacity: 0.4;
  border: 2px dashed var(--gold);
}

.drag-handle {
  color: #bbb;
  font-size: 1rem;
  cursor: grab;
  touch-action: none;
  user-select: none;
  flex-shrink: 0;
}

.drag-handle:active {
  cursor: grabbing;
}

.compact-info {
  flex: 1;
  min-width: 0;
}

.compact-name-row {
  display: flex;
  align-items: center;
  gap: 0.4rem;
}

.compact-name {
  font-weight: 600;
  font-size: 0.85rem;
  color: var(--charcoal);
}

.compact-desc {
  color: #999;
  font-size: 0.7rem;
  margin-top: 0.1rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.arrow-buttons {
  display: flex;
  gap: 0.25rem;
  flex-shrink: 0;
}

.arrow-btn {
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f3ef;
  border: none;
  border-radius: 4px;
  font-size: 0.7rem;
  color: #888;
  cursor: pointer;
  font-family: var(--font-body);
}

.arrow-btn:hover {
  background: #e8e5e0;
}

.arrow-btn.disabled {
  opacity: 0.3;
  pointer-events: none;
}

/* --- Drag insertion indicator --- */
.drop-indicator {
  height: 2px;
  background: var(--gold);
  border-radius: 1px;
  margin: -1px 0;
  pointer-events: none;
}

/* --- Floating drag clone --- */
.drag-clone {
  position: fixed;
  pointer-events: none;
  z-index: 1000;
  opacity: 0.9;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
  max-width: 90vw;
}
```

- [ ] **Step 3: Update mobile responsive styles**

In the `@media (max-width: 480px)` block, replace the removed health bar overrides with edit mode mobile styles:

```css
/* Reorder button: own row on mobile */
.reorder-btn {
  display: block;
  width: 100%;
  text-align: center;
  margin-left: 0;
  margin-top: 0.5rem;
}

/* Compact rows */
.compact-name {
  font-size: 0.8rem;
}

.compact-desc {
  font-size: 0.65rem;
}
```

- [ ] **Step 4: Commit CSS changes**

```bash
git add index.html
git commit -m "style: replace health bars with score circle, stack tags, and edit mode CSS"
```

---

### Task 2: Add score calculation and update enum maps

**Files:**
- Modify: `index.html` (JS section)

- [ ] **Step 1: Add score value maps and calculation function**

After the existing `REVENUE_MAP` constant (line ~524), add:

```javascript
// --- Score Calculation ---

const ADOPTION_SCORE = {
  none: 0, josh_only: 3.3, team_uses: 6.6, client_facing: 10
};

const AUTONOMY_SCORE = {
  josh_dependent: 3.3, needs_guidance: 6.6, fully_independent: 10
};

const REVENUE_SCORE = {
  internal_only: 3.3, client_touch: 6.6, revenue_driver: 10
};

/**
 * Calculate composite health score for a project.
 * Formula: (Adoption + Autonomy * 2 + Revenue) / 4
 * Autonomy is weighted double per spec.
 * @param {Object} project - The project object
 * @returns {number} Score from 0.0 to 10.0
 */
function computeScore(project) {
  const adoption = ADOPTION_SCORE[project?.adoption] ?? 0;
  const autonomy = AUTONOMY_SCORE[project?.autonomy] ?? 0;
  const revenue = REVENUE_SCORE[project?.revenueProximity] ?? 0;
  // Autonomy weighted 2x: (adoption + autonomy*2 + revenue) / 4
  return (adoption + autonomy * 2 + revenue) / 4;
}

/**
 * Get the CSS tier class for a score value.
 * @param {number} score - Composite score 0-10
 * @returns {string} CSS class name
 */
function scoreTierClass(score) {
  if (score >= 7.0) return 'score-tier-olive';
  if (score >= 4.0) return 'score-tier-gold';
  return 'score-tier-canyon';
}
```

- [ ] **Step 2: Commit**

```bash
git add index.html
git commit -m "feat: add autonomy-weighted composite health score calculation"
```

---

### Task 3: Rewrite renderCard with new layout

**Files:**
- Modify: `index.html` (JS section - `renderCard`, `renderHealthBar`, `renderHealthBars` functions)

- [ ] **Step 1: Remove renderHealthBar and renderHealthBars functions**

Delete the `renderHealthBar()` function (lines ~659-668) and `renderHealthBars()` function (lines ~676-683) entirely.

- [ ] **Step 2: Add new rendering helpers**

Add these functions where the health bar functions were:

```javascript
/**
 * Render the score circle for a project card.
 * @param {Object} project - The project object
 * @returns {string} HTML string for the score circle
 */
function renderScoreCircle(project) {
  const score = computeScore(project);
  const tier = scoreTierClass(score);
  return `
    <div class="score-circle ${tier}">
      <span class="score-value">${score.toFixed(1)}</span>
    </div>`;
}

/**
 * Render stack technology tags for a project.
 * Returns empty string if no stack entries.
 * @param {Object} project - The project object
 * @returns {string} HTML string
 */
function renderStackTags(project) {
  if (!Array.isArray(project?.stack) || project.stack.length === 0) {
    return '';
  }
  const tags = project.stack.map(t =>
    `<span class="stack-tag">${escapeHtml(t)}</span>`
  ).join('');
  return `<div class="stack-tags card-section">${tags}</div>`;
}

/**
 * Render colored dot indicators for health dimensions.
 * @param {Object} project - The project object
 * @returns {string} HTML string for the bottom bar
 */
function renderHealthDots(project) {
  const adoption = ADOPTION_MAP[project?.adoption] || { label: 'Unknown', color: '#ccc' };
  const autonomy = AUTONOMY_MAP[project?.autonomy] || { label: 'Unknown', color: '#ccc' };
  const revenue = REVENUE_MAP[project?.revenueProximity] || { label: 'Unknown', color: '#ccc' };
  return `
    <div class="health-dots card-section">
      <span class="health-dot" style="color: ${adoption.color};">● ${escapeHtml(adoption.label)}</span>
      <span class="health-dot" style="color: ${autonomy.color};">● ${escapeHtml(autonomy.label)}</span>
      <span class="health-dot" style="color: ${revenue.color};">● ${escapeHtml(revenue.label)}</span>
    </div>`;
}
```

- [ ] **Step 3: Rewrite renderCard function**

Replace the entire `renderCard` function with:

```javascript
/**
 * Render a single project card with score circle layout.
 * @param {Object} project - The project object
 * @returns {string} HTML string for the card
 */
function renderCard(project) {
  const statusClass = VALID_STATUSES.includes(project?.status)
    ? `status-${project.status}`
    : '';

  const versionText = project?.currentVersion ?? 'unreleased';
  const score = computeScore(project);

  // Deployed date display
  const deployedDateText = project?.deployedDate
    ? escapeHtml(project.deployedDate)
    : 'Not yet deployed';

  // Deploy URL link or access URL for non-web tools
  const deployLink = project?.deployedUrl
    ? ` | <a class="deploy-link" href="${escapeHtml(project.deployedUrl)}" target="_blank" rel="noopener">${escapeHtml(project.deployedUrl)}</a>`
    : project?.accessUrl
      ? ` | <a class="deploy-link" href="${escapeHtml(project.accessUrl)}" target="_blank" rel="noopener">Open Tool ↗</a>`
      : '';

  return `
    <div class="project-card"
         data-status="${escapeHtml(project?.status || '')}"
         data-slug="${escapeHtml(project?.slug || '')}"
         data-deployed="${escapeHtml(project?.deployedDate || '')}"
         data-autonomy="${escapeHtml(project?.autonomy || '')}"
         data-score="${score.toFixed(1)}">
      <div class="card-header">
        <div class="card-header-left">
          <h3>
            ${escapeHtml(project?.name ?? 'Untitled')}
            <span class="status-badge ${escapeHtml(statusClass)}">${escapeHtml(formatStatus(project?.status))}</span>
            <span class="version-label">v${escapeHtml(versionText)}</span>
          </h3>
          <div class="card-meta">${deployedDateText}${deployLink}</div>
        </div>
        ${renderScoreCircle(project)}
      </div>
      <p class="card-description">${escapeHtml(project?.description ?? '')}</p>
      ${renderStackTags(project)}
      ${renderHealthDots(project)}
      ${renderVersionHistory(project)}
      ${renderUpNext(project)}
      ${renderPriorityScores(project)}
    </div>`;
}
```

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "feat: redesign project cards with score circle, stack tags, and health dots"
```

---

## Chunk 2: Edit Mode + Pointer-Event Drag System

### Task 4: Remove old drag-and-drop system and add edit mode state

**Files:**
- Modify: `index.html` (JS section)

- [ ] **Step 1: Remove old drag-and-drop code**

Delete the entire `enableDragAndDrop()` function (lines ~954-1005) and the variables at the top:

```javascript
// REMOVE these two lines from the drag-and-drop state section:
let draggedCard = null;
// Keep: const STORAGE_KEY = 'projectCardOrder';
// Keep: let currentOrder = null;
```

- [ ] **Step 2: Add edit mode state variables**

Replace the removed `draggedCard` variable with edit mode state. The state section at the top of the script should now look like:

```javascript
// --- Filter/Sort State ---
let currentFilter = 'all';
let currentSort = 'recent';

// --- Reorder State ---
const STORAGE_KEY = 'projectCardOrder';
let currentOrder = null;
let isEditMode = false;
let savedFilter = 'all';
```

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "refactor: remove HTML5 drag-and-drop, add edit mode state"
```

---

### Task 5: Add edit mode toggle and compact row rendering

**Files:**
- Modify: `index.html` (JS section)

- [ ] **Step 1: Add compact row renderer**

Add this function after `renderCard`:

```javascript
/**
 * Render a compact row for edit/reorder mode.
 * @param {Object} project - The project object
 * @param {number} index - Current position index
 * @param {number} total - Total number of projects
 * @returns {string} HTML string for the compact row
 */
function renderCompactRow(project, index, total) {
  const statusClass = VALID_STATUSES.includes(project?.status)
    ? `status-${project.status}`
    : '';

  const upDisabled = index === 0 ? ' disabled' : '';
  const downDisabled = index === total - 1 ? ' disabled' : '';

  return `
    <div class="compact-row" data-slug="${escapeHtml(project?.slug || '')}">
      <span class="drag-handle">⠿</span>
      <div class="compact-info">
        <div class="compact-name-row">
          <span class="compact-name">${escapeHtml(project?.name ?? 'Untitled')}</span>
          <span class="status-badge ${escapeHtml(statusClass)}" style="font-size: 0.6rem; padding: 1px 6px;">${escapeHtml(formatStatus(project?.status))}</span>
        </div>
        <div class="compact-desc">${escapeHtml(project?.description ?? '')}</div>
      </div>
      <div class="arrow-buttons">
        <button class="arrow-btn${upDisabled}" data-dir="up" title="Move up">▲</button>
        <button class="arrow-btn${downDisabled}" data-dir="down" title="Move down">▼</button>
      </div>
    </div>`;
}
```

- [ ] **Step 2: Add enterEditMode and exitEditMode functions**

Add these after `renderCompactRow`:

```javascript
/**
 * Enter edit/reorder mode. Swaps full cards to compact rows.
 */
function enterEditMode() {
  isEditMode = true;
  savedFilter = currentFilter;

  const grid = document.querySelector('.project-grid');
  if (!grid) return;

  // Disable filter tabs and sort dropdown
  const filterTabs = document.querySelector('.filter-tabs');
  const sortControls = document.querySelector('.sort-controls');
  if (filterTabs) filterTabs.classList.add('controls-disabled');
  if (sortControls) {
    // Disable just the select, not the reorder button
    const sel = sortControls.querySelector('#sort-select');
    const label = sortControls.querySelector('label');
    if (sel) sel.classList.add('controls-disabled');
    if (label) label.classList.add('controls-disabled');
  }

  // Show all projects (clear filter)
  document.querySelectorAll('.project-card').forEach(c => c.classList.remove('hidden'));

  // Get current card order by slug
  const cards = Array.from(grid.querySelectorAll('.project-card'));
  const slugOrder = cards.map(c => c.dataset.slug);

  // Build compact rows from project data in current order
  const projects = window.__projects || [];
  const projectMap = {};
  projects.forEach(p => { projectMap[p.slug] = p; });

  const orderedProjects = [];
  slugOrder.forEach(slug => {
    if (projectMap[slug]) orderedProjects.push(projectMap[slug]);
  });
  // Add any projects not currently in the grid
  projects.forEach(p => {
    if (!slugOrder.includes(p.slug)) orderedProjects.push(p);
  });

  const rows = orderedProjects.map((p, i) =>
    renderCompactRow(p, i, orderedProjects.length)
  ).join('');

  grid.innerHTML = rows;

  // Update reorder button
  const btn = document.querySelector('.reorder-btn');
  if (btn) {
    btn.textContent = 'Done Reordering';
    btn.classList.add('active');
  }

  // Attach arrow button listeners
  attachArrowListeners();

  // Attach pointer-event drag listeners
  attachDragListeners();
}

/**
 * Exit edit/reorder mode. Saves order and re-renders full cards.
 */
function exitEditMode() {
  isEditMode = false;

  const grid = document.querySelector('.project-grid');
  if (!grid) return;

  // Read final order from compact rows
  const rows = Array.from(grid.querySelectorAll('.compact-row'));
  const slugOrder = rows.map(r => r.dataset.slug);

  // Save to localStorage
  localStorage.setItem(STORAGE_KEY, JSON.stringify(slugOrder));
  currentOrder = slugOrder;

  // Re-render full cards in saved order
  const projects = window.__projects || [];
  const projectMap = {};
  projects.forEach(p => { projectMap[p.slug] = p; });

  const orderedCards = [];
  slugOrder.forEach(slug => {
    if (projectMap[slug]) orderedCards.push(renderCard(projectMap[slug]));
  });
  // Append any new projects not in order
  projects.forEach(p => {
    if (!slugOrder.includes(p.slug)) orderedCards.push(renderCard(p));
  });

  grid.innerHTML = orderedCards.join('');

  // Re-enable controls
  const filterTabs = document.querySelector('.filter-tabs');
  const sortControls = document.querySelector('.sort-controls');
  if (filterTabs) filterTabs.classList.remove('controls-disabled');
  if (sortControls) {
    const sel = sortControls.querySelector('#sort-select');
    const label = sortControls.querySelector('label');
    if (sel) sel.classList.remove('controls-disabled');
    if (label) label.classList.remove('controls-disabled');
  }

  // Update reorder button
  const btn = document.querySelector('.reorder-btn');
  if (btn) {
    btn.textContent = 'Reorder';
    btn.classList.remove('active');
  }

  // Set sort to custom and restore filter
  const sortSelect = document.querySelector('#sort-select');
  if (sortSelect) {
    sortSelect.value = 'custom';
    currentSort = 'custom';
  }

  // Restore previous filter
  filterCards(savedFilter);
}

/**
 * Toggle edit mode on/off.
 */
function toggleEditMode() {
  if (isEditMode) {
    exitEditMode();
  } else {
    enterEditMode();
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "feat: add edit mode toggle with compact row rendering"
```

---

### Task 6: Add arrow button and pointer-event drag handlers

**Files:**
- Modify: `index.html` (JS section)

- [ ] **Step 1: Add arrow button listener function**

Add after the `toggleEditMode` function:

```javascript
/**
 * Attach click listeners to arrow buttons in compact rows.
 * Moves rows up/down and updates disabled states.
 */
function attachArrowListeners() {
  const grid = document.querySelector('.project-grid');
  if (!grid) return;

  grid.addEventListener('click', (e) => {
    const btn = e.target.closest('.arrow-btn');
    if (!btn || btn.classList.contains('disabled')) return;

    const row = btn.closest('.compact-row');
    if (!row) return;

    const dir = btn.dataset.dir;
    if (dir === 'up' && row.previousElementSibling) {
      row.parentNode.insertBefore(row, row.previousElementSibling);
    } else if (dir === 'down' && row.nextElementSibling) {
      row.nextElementSibling.insertAdjacentElement('afterend', row);
    }

    updateArrowStates();
  });
}

/**
 * Update disabled state on all arrow buttons based on position.
 */
function updateArrowStates() {
  const rows = document.querySelectorAll('.compact-row');
  const last = rows.length - 1;
  rows.forEach((row, i) => {
    const upBtn = row.querySelector('[data-dir="up"]');
    const downBtn = row.querySelector('[data-dir="down"]');
    if (upBtn) {
      if (i === 0) upBtn.classList.add('disabled');
      else upBtn.classList.remove('disabled');
    }
    if (downBtn) {
      if (i === last) downBtn.classList.add('disabled');
      else downBtn.classList.remove('disabled');
    }
  });
}
```

- [ ] **Step 2: Add pointer-event drag system**

Add after `updateArrowStates`:

```javascript
/**
 * Attach pointer-event drag listeners to drag handles in compact rows.
 */
function attachDragListeners() {
  const grid = document.querySelector('.project-grid');
  if (!grid) return;

  let dragRow = null;
  let clone = null;
  let indicator = null;
  let offsetY = 0;
  let scrollInterval = null;

  function getRowAtPoint(y) {
    const rows = Array.from(grid.querySelectorAll('.compact-row'));
    for (const row of rows) {
      if (row === dragRow) continue;
      const rect = row.getBoundingClientRect();
      if (y >= rect.top && y <= rect.bottom) {
        return { row, midY: rect.top + rect.height / 2 };
      }
    }
    return null;
  }

  function removeIndicator() {
    if (indicator && indicator.parentNode) {
      indicator.parentNode.removeChild(indicator);
    }
    indicator = null;
  }

  function autoScroll(clientY) {
    if (scrollInterval) {
      cancelAnimationFrame(scrollInterval);
      scrollInterval = null;
    }
    const threshold = 50;
    const speed = 5;
    const viewH = window.innerHeight;

    function step() {
      if (clientY < threshold) {
        window.scrollBy(0, -speed);
      } else if (clientY > viewH - threshold) {
        window.scrollBy(0, speed);
      }
      scrollInterval = requestAnimationFrame(step);
    }

    if (clientY < threshold || clientY > viewH - threshold) {
      scrollInterval = requestAnimationFrame(step);
    }
  }

  grid.addEventListener('pointerdown', (e) => {
    const handle = e.target.closest('.drag-handle');
    if (!handle) return;

    dragRow = handle.closest('.compact-row');
    if (!dragRow) return;

    e.preventDefault();
    handle.setPointerCapture(e.pointerId);

    const rect = dragRow.getBoundingClientRect();
    offsetY = e.clientY - rect.top;

    // Create floating clone
    clone = dragRow.cloneNode(true);
    clone.classList.add('drag-clone');
    clone.style.width = rect.width + 'px';
    clone.style.top = rect.top + 'px';
    clone.style.left = rect.left + 'px';
    document.body.appendChild(clone);

    dragRow.classList.add('drag-source');

    // Create indicator element
    indicator = document.createElement('div');
    indicator.classList.add('drop-indicator');
  });

  grid.addEventListener('pointermove', (e) => {
    if (!dragRow || !clone) return;

    clone.style.top = (e.clientY - offsetY) + 'px';

    autoScroll(e.clientY);

    // Find target row and show indicator
    removeIndicator();
    const target = getRowAtPoint(e.clientY);
    if (target) {
      if (e.clientY < target.midY) {
        target.row.parentNode.insertBefore(indicator, target.row);
      } else {
        target.row.insertAdjacentElement('afterend', indicator);
      }
    }
  });

  grid.addEventListener('pointerup', () => {
    if (!dragRow) return;

    // Move row to indicator position
    if (indicator && indicator.parentNode) {
      indicator.parentNode.insertBefore(dragRow, indicator);
    }

    // Cleanup
    removeIndicator();
    dragRow.classList.remove('drag-source');
    if (clone && clone.parentNode) {
      clone.parentNode.removeChild(clone);
    }
    if (scrollInterval) {
      cancelAnimationFrame(scrollInterval);
      scrollInterval = null;
    }
    dragRow = null;
    clone = null;

    updateArrowStates();
  });

  // Handle pointer leaving the window
  grid.addEventListener('pointercancel', () => {
    if (!dragRow) return;
    removeIndicator();
    dragRow.classList.remove('drag-source');
    if (clone && clone.parentNode) {
      clone.parentNode.removeChild(clone);
    }
    if (scrollInterval) {
      cancelAnimationFrame(scrollInterval);
      scrollInterval = null;
    }
    dragRow = null;
    clone = null;
  });
}
```

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "feat: add arrow buttons and pointer-event drag system for edit mode"
```

---

### Task 7: Update renderPage, sortCards, and add "Health Score" sort

**Files:**
- Modify: `index.html` (JS section - `renderPage`, `sortCards`)

- [ ] **Step 1: Add "Health Score" sort option and Reorder button to renderPage**

In the `renderPage` function, update the sort dropdown HTML to add the new option and the Reorder button. Replace the `<div class="sort-controls">` block:

```javascript
// Old:
<div class="sort-controls">
  <label for="sort-select">Sort:</label>
  <select id="sort-select">
    <option value="recent">Most Recently Deployed</option>
    <option value="autonomy">Autonomy Level</option>
    <option value="custom">Custom Order</option>
  </select>
</div>

// New:
<div class="sort-controls">
  <label for="sort-select">Sort:</label>
  <select id="sort-select">
    <option value="recent">Most Recently Deployed</option>
    <option value="autonomy">Autonomy Level</option>
    <option value="score">Health Score</option>
    <option value="custom">Custom Order</option>
  </select>
  <button class="reorder-btn" onclick="toggleEditMode()">Reorder</button>
</div>
```

- [ ] **Step 2: Add score sort to sortCards function**

In the `sortCards` function, add a `score` sort branch. Inside the `cards.sort()` callback, after the `autonomy` branch:

```javascript
} else if (sortKey === 'score') {
  const scoreA = parseFloat(a.dataset.score) || 0;
  const scoreB = parseFloat(b.dataset.score) || 0;
  // Descending: highest score first
  return scoreB - scoreA;
}
```

- [ ] **Step 3: Remove enableDragAndDrop() call from renderPage**

In `renderPage`, delete this line:

```javascript
// REMOVE:
enableDragAndDrop();
```

The `enableDragAndDrop()` function was already deleted in Task 4. This removes the call to it.

- [ ] **Step 4: Update localStorage restore logic in renderPage**

The existing code that restores custom order on load (lines ~1064-1071) stays as-is since it still uses `applyCustomOrder()` and `STORAGE_KEY`. No changes needed.

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "feat: add Health Score sort option and Reorder button to page"
```

---

### Task 8: Sync projects.json inline data and final verification

**Files:**
- Modify: `index.html` (inline PROJECT_DATA)

- [ ] **Step 1: Regenerate inline PROJECT_DATA**

The inline `PROJECT_DATA` object in `index.html` must stay in sync with `projects.json`. Read `projects.json` and update the inline constant. The data itself hasn't changed - this step ensures the embedded copy matches after all the code changes around it.

Read `projects.json`, then replace the `const PROJECT_DATA = {...};` line in `index.html` with the current contents.

- [ ] **Step 2: Open in browser and verify**

Open `index.html` in a browser and verify:
- Cards show score circles with correct colors (check a few: STR Analyzer should be gold ~5.8, Contract Summary should be olive ~7.5)
- Stack tags appear on projects with stacks, absent on parking lot projects
- Health dots show correct colors matching the enum maps
- Filter tabs work (All, Shipped, In Progress, Parking Lot)
- Sort dropdown has 4 options including "Health Score" which sorts by score descending
- "Reorder" button enters edit mode with compact rows
- Arrow buttons move rows up/down
- Drag handles work with mouse and touch
- "Done Reordering" exits edit mode, restores full cards in new order
- Custom order persists after page reload
- Mobile responsive at 480px

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "feat: complete v2 visual redesign with score circles and edit mode reordering"
```

- [ ] **Step 4: Deploy**

```bash
git push origin main
```

This triggers GitHub Pages deploy to https://joshhoganliveaz.github.io/tom-ferry-coaching/
