# Project Tracker v2: Visual Redesign + Edit Mode Reordering

**Date:** 2026-03-26
**Status:** Approved
**Project:** Tom Ferry Coaching Project Tracker

## Summary

Redesign project cards to use a composite health score circle with stack tags and colored dot indicators, replacing the horizontal health bars. Add a dedicated edit/reorder mode with compact rows, drag handles, and arrow buttons - replacing the current raw HTML5 drag-and-drop on full cards.

## Card Redesign: Score Circle + Stack Tags

### Layout

Each project card follows this structure top-to-bottom:

1. **Header row**: Project name (Source Serif 4, bold) + status badge + version label on left. Composite health score circle (48px) on right. Uses `display: flex; justify-content: space-between; align-items: flex-start`.
2. **Card meta**: Deployed date + URL link (same as current `.card-meta` div). Kept between header and description.
3. **Description**: One line, same as current.
4. **Stack tags**: Small neutral pills (background: #f0ede8, color: #666, border-radius: 3px, font-size: 0.6rem) showing tech stack entries. Only rendered if `project.stack` array has entries. Wrapped in a flex container with 0.3rem gap.
5. **Bottom bar**: Separated by a 1px top border (#eee), padding-top: 0.5rem. Colored dot indicators for each health dimension. Dot color uses the existing color from each enum map (ADOPTION_MAP, AUTONOMY_MAP, REVENUE_MAP). Format: "● Label" with font-size: 0.65rem, font-weight: 600. Flex row with 0.75rem gap.
6. **Conditional sections** (unchanged): Version History (collapsible details), Up Next box, Priority Scores.

When stack tags are absent (empty stack array), the bottom bar sits directly below the description with no extra gap.

### Score Circle

- 48px diameter, implemented as a div with `border: 3px solid [color]; border-radius: 50%;` centered flex content
- Number displayed centered inside as X.X (one decimal)
- Color tiers (evaluated in order):
  - `>= 7.0`: olive (#5C6B4F)
  - `>= 4.0`: gold (#C9953E)
  - `< 4.0`: canyon (#8B6F5C)

### Composite Health Score Formula

Autonomy-weighted calculation:

```
Adoption mapping:
  none = 0, josh_only = 3.3, team_uses = 6.6, client_facing = 10

Autonomy mapping:
  josh_dependent = 3.3, needs_guidance = 6.6, fully_independent = 10

Revenue Proximity mapping:
  internal_only = 3.3, client_touch = 6.6, revenue_driver = 10

Composite = (Adoption + Autonomy * 2 + Revenue) / 4
```

The `none = 0` for adoption is intentional - a project with zero adoption is meaningfully behind a project at any other level. This creates a wider scoring range that differentiates projects more clearly.

Display as single decimal (e.g., 7.3). Circle border color follows tier thresholds above.

### Removed Elements

- Three horizontal health progress bars (Adoption, Autonomy, Revenue) and all related CSS/JS (`renderHealthBar`, `renderHealthBars`, `.health-bars`, `.health-bar`, `.health-track`, `.health-fill`, `.health-label`, `.health-text`)
- The existing HTML5 drag-and-drop system is fully removed (all `dragstart/dragover/dragleave/drop/dragend` handlers, `enableDragAndDrop()`, `.dragging`/`.drag-over` CSS classes, `draggable="true"` attribute). Replaced entirely by the edit mode system.
- Cards in normal (non-edit) mode are NOT draggable

## Edit/Reorder Mode

### Entry Point

A "Reorder" button in the filter bar. On desktop, it sits to the right of the sort dropdown inside `.sort-controls`. On mobile (480px and below), it gets its own centered row below the sort controls (consistent with the stacked filter-bar layout).

### Entering Edit Mode

- "Reorder" button text changes to "Done Reordering" (background: olive, color: white)
- Sort dropdown and filter tabs become disabled (opacity: 0.5, pointer-events: none)
- Any active filter is temporarily cleared - all projects show in compact rows regardless of filter state. The previous filter selection is remembered and restored on exit.
- Cards swap to compact row markup (no animation on the transition - instant class toggle is cleaner than trying to animate between two different DOM structures)

### Compact Row Layout

Each row contains:

- **Left**: Drag handle (⠿ character), color: #bbb, font-size: 1rem, cursor: grab
- **Center**: Project name (font-weight: 600, 0.85rem) + status badge (same styling as full card but smaller) on first line. Description truncated to one line (white-space: nowrap, overflow: hidden, text-overflow: ellipsis, color: #999, font-size: 0.7rem) below.
- **Right**: ▲ and ▼ buttons (24px square, background: #f5f3ef, border-radius: 4px, centered arrow character, color: #888)

Row styling: white background, 0.6rem 0.75rem padding, 6px border-radius, 1px solid #e8e5e0 border, 0.4rem gap between rows.

### Reordering Interactions

**Drag handle:**
- Uses pointer events (pointerdown/pointermove/pointerup) for mouse + touch compatibility. This is a complete rewrite of the drag system - the HTML5 DnD API is removed entirely.
- On drag start: set `touch-action: none` on the handle to prevent scroll interference. Clone the row as a floating element positioned absolutely following the pointer.
- Original row gets opacity: 0.4, dashed gold border
- Insertion indicator: 2px solid gold line between rows showing where the card will land
- On drop: card moves to new position in DOM, floating clone removed
- Auto-scroll: when dragging within 50px of viewport top/bottom edge, scroll the page at 5px per frame to allow reordering beyond the visible area

**Arrow buttons:**
- ▲ moves card up one position, ▼ moves down one
- First visible card: ▲ button gets opacity: 0.3, pointer-events: none. Last visible card: same for ▼.
- Movement is instant (no animation needed for single-position moves)

Both interactions update the same internal order array.

### Exiting Edit Mode

- Click "Done Reordering"
- Cards re-render as full Score Circle layout (full `renderCard()` output replaces compact rows)
- Custom order saves to localStorage under key `projectCardOrder` (array of slugs)
- Sort dropdown auto-selects "Custom Order"
- Filter tabs and sort dropdown re-enable (opacity: 1, pointer-events: auto)
- Previous filter selection is restored (cards re-filtered)

### localStorage Persistence

Same key and format as current implementation: `projectCardOrder` stores an array of slug strings. Backwards-compatible with any existing saved orders. New projects not in the saved array append to the end.

## Sort by Score

Add "Health Score" as a fourth option in the sort dropdown. Sorts cards by composite score descending (highest score first). This complements the existing "Most Recently Deployed", "Autonomy Level", and "Custom Order" options.

## Other Visual Refinements

### Card Hover

Desktop only (`@media (hover: hover)`): translateY(-1px) with box-shadow: 0 4px 12px rgba(0,0,0,0.1) on hover. Transition: transform 0.15s ease, box-shadow 0.15s ease.

### No Changes

- Summary stats bar: unchanged
- Filter tabs behavior: unchanged
- Sort dropdown behavior: unchanged (existing "Custom Order" option stays, new "Health Score" option added)
- projects.json schema: no new fields (score calculated client-side)
- Version History, Up Next, Priority Scores sections: same markup and behavior
- Header, footer: unchanged
- Deploy process: single HTML file, GitHub Pages

## Technical Constraints

- Zero external dependencies (vanilla HTML/CSS/JS)
- Single index.html file with embedded CSS and JS
- All dynamic text sanitized via escapeHtml() pattern per CLAUDE.md
- Mobile responsive at 480px breakpoint (existing media queries extended)
- Score computed at render time from existing enum values, not stored in JSON
