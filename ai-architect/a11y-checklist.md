# Accessibility QA Checklist – DICE (DnD Integrated Character Engine)

**Version:** 1.0  
**Applies To:** Web (Astro.js + React), Mobile (Flutter)  
**Standard:** WCAG 2.1 AA  
**Owner:** QA Lead / Accessibility Engineer  
**Last Updated:** 2025-07-25

---

## ✅ General Accessibility Requirements

| Requirement                                                      | Platform     | Status | Notes                          |
| ---------------------------------------------------------------- | ------------ | ------ | ------------------------------ |
| Language is declared (e.g., `lang="en"`)                         | Web          | [ ]    | In `<html>` tag                |
| All pages/apps are navigable via keyboard only                   | Web + Mobile | [ ]    | Tab, arrow keys, Enter, Escape |
| All interactive elements are reachable and operable via keyboard | Web + Mobile | [ ]    | No mouse-only dependencies     |
| No keyboard traps (user can always move focus away)              | Web + Mobile | [ ]    | Modal dialogs, dropdowns       |
| Skip to main content link present                                | Web          | [ ]    | Hidden link at top of page     |
| Focus order is logical and intuitive                             | Web + Mobile | [ ]    | Matches visual layout          |
| Focus is visibly styled and clearly visible                      | Web + Mobile | [ ]    | No reliance on color only      |

---

## 🎨 Visual Design & Contrast

| Requirement                                                           | Platform     | Status | Notes                                           |
| --------------------------------------------------------------------- | ------------ | ------ | ----------------------------------------------- |
| Text contrast ratio is at least 4.5:1                                 | Web + Mobile | [ ]    | Check all text states (normal, hover, disabled) |
| Large text (18pt+ or 14pt bold) has at least 3:1 contrast             | Web + Mobile | [ ]    | For headers, banners                            |
| UI components (buttons, cards) have ≥ 3:1 contrast against background | Web + Mobile | [ ]    | Especially in light/dark modes                  |
| UI does not rely solely on color to convey meaning                    | Web + Mobile | [ ]    | Add icons, text, shapes if needed               |

---

## 🏷️ Semantic Structure

| Requirement                                                          | Platform     | Status | Notes                                |
| -------------------------------------------------------------------- | ------------ | ------ | ------------------------------------ |
| Landmarks used correctly (`<main>`, `<nav>`, `<header>`, `<footer>`) | Web          | [ ]    | For screen readers                   |
| All headings follow logical order (h1 → h2 → h3)                     | Web          | [ ]    | No skipped levels                    |
| Labels are associated with inputs (`<label for="">` or `aria-label`) | Web + Mobile | [ ]    | Use `InputDecorator` in Flutter      |
| Components use semantic HTML elements (buttons, lists, forms)        | Web          | [ ]    | Avoid `div`/`span` abuse             |
| Flutter widgets use semantic roles via `Semantics` widget            | Mobile       | [ ]    | Custom components must declare roles |

---

## 📢 Screen Reader Compatibility

| Requirement                                                 | Platform     | Status | Notes                                |
| ----------------------------------------------------------- | ------------ | ------ | ------------------------------------ |
| All inputs and controls are labeled                         | Web + Mobile | [ ]    | Text inputs, checkboxes, sliders     |
| ARIA roles and `aria-*` attributes used appropriately       | Web          | [ ]    | `aria-expanded`, `aria-hidden`, etc. |
| Dialogs use appropriate ARIA (`role="dialog"`, focus trap)  | Web          | [ ]    | Use modal patterns                   |
| Tab names are announced clearly by screen readers           | Web + Mobile | [ ]    | Wizard steps, tabs                   |
| Dynamic updates announce changes via `aria-live` or similar | Web          | [ ]    | Stats auto-updating                  |
| Screen reader testing completed (NVDA, VoiceOver)           | Web + Mobile | [ ]    | Manual walkthrough of key flows      |

---

## 🖱️ Touch & Pointer Inputs

| Requirement                                         | Platform | Status | Notes                         |
| --------------------------------------------------- | -------- | ------ | ----------------------------- |
| Touch targets are ≥ 44x44px                         | Mobile   | [ ]    | Buttons, cards, dropdowns     |
| Drag and swipe actions have accessible alternatives | Mobile   | [ ]    | Avoid gesture-only navigation |
| Hover-only content also appears on focus            | Web      | [ ]    | Tooltips, menus, popovers     |

---

## 🔄 Responsive Layout & Zoom

| Requirement                                    | Platform     | Status | Notes                                   |
| ---------------------------------------------- | ------------ | ------ | --------------------------------------- |
| App works at 200% zoom without loss of content | Web          | [ ]    | No fixed pixel layouts                  |
| Layout adapts to small and large screens       | Web + Mobile | [ ]    | Tablets, foldables                      |
| UI supports dynamic font scaling               | Mobile       | [ ]    | OS-level text scaling options           |
| No horizontal scroll at any width              | Web          | [ ]    | Except where intentional (e.g., tables) |

---

## 🔧 Testing Tools & Automation

| Tool                            | Use                                | Status |
| ------------------------------- | ---------------------------------- | ------ |
| **axe-core**                    | Automated rule-based audits in dev | [ ]    |
| **Lighthouse CI**               | PWA + a11y + contrast checks       | [ ]    |
| **Playwright a11y checks**      | Headless regression tests          | [ ]    |
| **NVDA / VoiceOver / TalkBack** | Manual screen reader QA            | [ ]    |
| **Flutter a11y widget testing** | Semantic roles + focus states      | [ ]    |

---

## 🧪 Manual Testing Checklist (Recommended Scenarios)

- [ ] Character creation wizard is fully navigable by keyboard  
- [ ] All stats are announced correctly via screen reader  
- [ ] Tab order follows visual layout  
- [ ] Modal dialogs trap focus correctly  
- [ ] Screen reader reads updated stat values on change  
- [ ] Ability to operate offline does not break focus or a11y  

---

## 📝 Notes

- WCAG 2.1 AA compliance is a launch blocker for GA  
- Accessibility should be included in every sprint QA  
- Design reviews must verify contrast and label placement from Figma  

---

## 📎 References

- [W3C WCAG 2.1 AA Guidelines](https://www.w3.org/TR/WCAG21/)  
- [axe-core Rules Reference](https://deque.com/axe/core-documentation/api-documentation/)  
- [Flutter Accessibility Guide](https://flutter.dev/docs/development/accessibility-and-localization/accessibility)  
- [Google Lighthouse Accessibility Guide](https://web.dev/accessibility/)
