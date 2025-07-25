# UX Wireframe Specifications – D&D 3.0 Character Manager (Foldable Adaptation)

## Overview

This document outlines the UX wireframes and flow for DICE — DnD Integrated Character Engine, with **explicit support for folding phones** (e.g., Samsung Galaxy Fold, Pixel Fold, Surface Duo). UX patterns are designed for:

- Small, compact, folded phones (single-pane, vertical)  
- Expanded, tablet-like, unfolded phones (dual-pane or horizontal layout)  
- Dynamic transitions between folded ↔ unfolded

---

## 1. Character Dashboard (Home Screen)

### Folded View (Compact Phone Mode)

- Single-column card layout
- Tappable FAB or top-right button: “Create New Character”
- Character cards stack vertically, each containing:
  - Name, class, level, race, portrait (optional)
  - Edit / Delete buttons in a bottom-aligned row

### Unfolded View (Wide or Dual-Screen Mode)

- Two-pane layout:
  - **Left pane**: Character list in scrollable sidebar
  - **Right pane**: Preview of selected character or quick actions
- FAB replaced by persistent “+ New Character” button in header
- Use adaptive layout components (Flutter `LayoutBuilder` / Web CSS Grid)

> UX Tip: Detect hinge and avoid placing interactive elements directly underneath it (Surface Duo / Z Fold)

---

## 2. Character Creation – Multi-Step Wizard

### Folded View

- Single step per screen
- “Next” and “Back” buttons bottom-aligned
- Sticky step indicator (e.g., “Step 2 of 4”) at the top
- Pages slide or fade between steps

### Unfolded View

- Two-panel or split layout:
  - **Left panel**: Navigation sidebar or step overview
  - **Right panel**: Current form fields
- Optionally allow form field groups to be shown side-by-side

#### Step Breakdown

- **Step 1: Profile**
  - Inputs: Name, gender, age, race, alignment, religion
  - Dropdowns use D&D 3.0 list
- **Step 2: Class & Abilities**
  - Multi-class selector with level inputs
  - Ability scores: numeric fields or sliders
  - Modifiers shown beside inputs
- **Step 3: Combat Stats**
  - Derived stats read-only but clear
  - Attack bonus, initiative, saves, AC, movement
- **Step 4: Traits & Abilities**
  - Racial traits, class abilities, languages
  - Grouped by source (race/class), collapsible sections

> UX Tip: Use bottom drawers or right panels (Flutter `DraggableScrollableSheet`, web `position: fixed`) for tips or rules on fold-out view

---

## 3. Character Sheet View

### Folded View

- Tabbed or scrollable long-form layout:
  - Overview  
  - Stats  
  - Combat  
  - Features  
  - Notes
- Sticky navigation bar (bottom or top)
- Clear “Edit” button to toggle write mode

### Unfolded View

- Dual-pane layout:
  - **Left pane**: Tab list or quick navigation
  - **Right pane**: Full content of selected section
- Allow drag-to-expand gestures (or pinch zoom) in wide mode
- “Edit” button floats or pins to upper-right of right panel

---

## 4. Sync, Settings, and Offline Status

- Responsive design for all screens
- Show sync banner only in one panel in unfolded mode
- Login, logout, and sync now controls accessible from both layouts
- Use icon + label pairings for accessibility and foldable clarity

---

## 5. Device and Layout Considerations

| Mode                      | UX Strategy                                                                                 |
| ------------------------- | ------------------------------------------------------------------------------------------- |
| Folded (portrait)         | Single-column stacked content, vertical scrolling                                           |
| Unfolded (landscape/wide) | Split layout with persistent sidebar or nav panel                                           |
| Hinge-aware layout        | Avoid placing content or buttons on hinge line                                              |
| Dynamic reflow            | Preserve user progress during fold transitions                                              |
| Dual-screen APIs          | Use `DisplayFeature` in Flutter or CSS `env(safe-area-inset-*)` for hinge/padding awareness |

> Platform Note:
>
> - **Flutter**: Use `MediaQuery.size`, `OrientationBuilder`, and `TwoPane` from `dual_screen` plugin
> - **Web**: Use CSS media queries and `@supports (display: grid)` for progressive enhancement

---

## 6. Accessibility Notes for Foldables

- Ensure all panels are reachable via keyboard navigation  
- Ensure `focus` is preserved when fold state changes  
- Maintain visible focus outlines regardless of screen mode  
- Reannounce context for screen readers after layout shift  

---

## 7. Testing Matrix for Foldables

| Device                       | Mode              | Test                                          |
| ---------------------------- | ----------------- | --------------------------------------------- |
| Galaxy Z Fold 5              | Folded, Unfolded  | ✅ Character creation wizard adapts layout     |
| Pixel Fold                   | Split + wide mode | ✅ Character sheet preview respects fold       |
| Surface Duo 2                | Dual-pane         | ✅ Sync/status messages show in left pane only |
| Web (Responsive Emulator)    | ≥ 720px width     | ✅ Two-column layout is shown                  |
| Flutter `dual_screen` plugin | Emulator          | ✅ Dynamic layout transitions verified         |

---

## 8. Design Principles

- Prioritise **continuity**: no jarring layout resets  
- Leverage **additional space** on unfold, not just scale  
- Use **responsive design** techniques with graceful fallbacks  
- Avoid content-hiding on hinge areas  
- Keep **performance smooth** during transitions
