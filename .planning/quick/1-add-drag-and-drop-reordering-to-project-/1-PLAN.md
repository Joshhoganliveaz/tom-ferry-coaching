---
phase: quick
plan: 01
type: execute
wave: 1
depends_on: []
files_modified: [index.html]
autonomous: true
requirements: [QUICK-01]

must_haves:
  truths:
    - "User can drag a project card and drop it at a new position in the grid"
    - "Custom card order persists across page reloads via localStorage"
    - "Existing filter and sort controls still work correctly"
    - "Drag provides visual feedback (opacity change, drop indicator)"
  artifacts:
    - path: "index.html"
      provides: "Drag-and-drop reordering with localStorage persistence"
      contains: "draggable"
  key_links:
    - from: "drag event handlers"
      to: "localStorage"
      via: "saves slug order array on drop"
      pattern: "localStorage.*projectOrder"
    - from: "init function"
      to: "saved order"
      via: "reorders cards on page load from localStorage"
      pattern: "applyCustomOrder"
---

<objective>
Add drag-and-drop reordering to the project tracker so project cards can be manually repositioned. Persist the custom order to localStorage so it survives page reloads.

Purpose: Let Josh arrange project cards in whatever order makes sense for coaching calls rather than being locked to filter/sort defaults.
Output: Updated index.html with drag-and-drop + localStorage persistence.
</objective>

<execution_context>
@/Users/joshuahogan/.claude/get-shit-done/workflows/execute-plan.md
@/Users/joshuahogan/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@index.html

Key architecture notes:
- Single HTML file with all CSS/JS inline, zero dependencies
- 16 project cards rendered in `.project-grid` div
- Each card has `data-slug` attribute (unique identifier per project)
- Existing `sortCards()` function reorders DOM nodes via `container.appendChild(card)`
- Existing `filterCards()` toggles `.hidden` class on cards
- `currentSort` tracks active sort mode ('recent' or 'autonomy')
- Sort dropdown triggers `sortCards()` on change event
</context>

<tasks>

<task type="auto">
  <name>Task 1: Add drag-and-drop CSS and event handlers</name>
  <files>index.html</files>
  <action>
Add the following to index.html (all inline, no external dependencies):

**CSS additions** (inside existing style block):
- `.project-card[draggable="true"]` cursor: grab
- `.project-card.dragging` with opacity: 0.4 and a dashed border
- `.project-card.drag-over` with a top border highlight (2px solid var(--gold)) to show drop position
- On mobile (max-width: 480px), keep the same drag styles

**JS additions** (inside existing script block):

1. Add a `currentOrder` variable (null or array of slugs) and a `STORAGE_KEY = 'projectCardOrder'` constant.

2. Create `enableDragAndDrop()` function called after `renderPage()`:
   - Query all `.project-card` elements, set `draggable="true"` on each
   - Add `dragstart` handler: set `dataTransfer.effectAllowed = 'move'`, store the dragged card reference, add `.dragging` class
   - Add `dragend` handler: remove `.dragging` class from the dragged card, remove `.drag-over` from all cards
   - Add `dragover` handler (on each card): `e.preventDefault()`, `e.dataTransfer.dropEffect = 'move'`, add `.drag-over` class to target card, remove `.drag-over` from all other cards
   - Add `dragleave` handler: remove `.drag-over` class
   - Add `drop` handler: `e.preventDefault()`, remove `.drag-over`, determine if drop target is before or after the dragged card using `getBoundingClientRect()` vertical midpoint, insert dragged card before or after the target using `insertBefore` or `insertAdjacentElement('afterend')`, then call `saveCustomOrder()`

3. Create `saveCustomOrder()` function:
   - Query all `.project-card` elements in current DOM order
   - Extract `data-slug` from each into an array
   - Save to `localStorage.setItem(STORAGE_KEY, JSON.stringify(slugArray))`
   - Set `currentOrder = slugArray`
   - Update the sort dropdown: add a "Custom" option if not present, set its value to 'custom' and select it

4. Create `applyCustomOrder()` function:
   - Read from `localStorage.getItem(STORAGE_KEY)`
   - If null/empty, return false (no custom order)
   - Parse the slug array
   - Get the `.project-grid` container
   - For each slug in the saved array, find the card with `[data-slug="..."]` and `appendChild` it to reorder
   - Any cards not in the saved array (new projects added after save) get appended at the end
   - Return true

5. Modify `sortCards()`: when sortKey is 'custom', call `applyCustomOrder()`. When sortKey is anything else (recent, autonomy), proceed with existing sort logic (this clears custom ordering visually but does NOT delete the localStorage entry).

6. Add "Custom" option to the sort dropdown: In `renderPage()`, add `<option value="custom">Custom Order</option>` to the sort select element.

7. In `renderPage()`, after existing event listeners are attached, call `enableDragAndDrop()`. Then check if a custom order exists in localStorage -- if so, call `applyCustomOrder()` and set the sort dropdown to 'custom'.

**Important:** Use the HTML5 Drag and Drop API only (no libraries). Keep all code inside the existing script tag. Use `escapeHtml()` for any dynamic content per project conventions.
  </action>
  <verify>
    <automated>cd "/Users/joshuahogan/Projects/Tom Ferry Coaching" && grep -c "draggable" index.html && grep -c "projectCardOrder" index.html && grep -c "dragstart" index.html && grep -c "applyCustomOrder" index.html</automated>
  </verify>
  <done>
    - All project cards have draggable="true" attribute set via JS
    - Dragging a card shows visual feedback (opacity, border)
    - Dropping a card repositions it in the grid
    - Custom order saved to localStorage under 'projectCardOrder' key
    - On page load, if custom order exists, cards render in saved order and sort dropdown shows "Custom Order"
    - Selecting "Most Recently Deployed" or "Autonomy Level" sort overrides custom order visually
    - Filter tabs continue to work (hiding/showing cards by status)
    - No external dependencies added
  </done>
</task>

</tasks>

<verification>
1. Open index.html in browser
2. Drag a card from bottom to top -- card should move to new position
3. Refresh page -- cards should remain in custom order
4. Sort dropdown should show "Custom Order" selected
5. Switch sort to "Most Recently Deployed" -- cards reorder by date
6. Switch sort back to "Custom Order" -- cards return to saved order
7. Filter by "Shipped" -- only shipped cards visible, drag still works among visible cards
8. Open DevTools > Application > Local Storage -- 'projectCardOrder' key exists with slug array
</verification>

<success_criteria>
- Drag-and-drop works on desktop browsers using HTML5 DnD API
- Custom order persists in localStorage and survives page reload
- Sort dropdown includes "Custom Order" option
- Existing filter and sort functionality unbroken
- Zero external dependencies (stays vanilla HTML/CSS/JS)
</success_criteria>

<output>
After completion, create `.planning/quick/1-add-drag-and-drop-reordering-to-project-/1-SUMMARY.md`
</output>
