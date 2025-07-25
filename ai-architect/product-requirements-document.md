# Product Requirements Document (PRD)

## Project Title: DICE — DnD Integrated Character Engine

**Version**: v1.0  
**Author**: Damien TIVELET  
**Created**: 2025-07-25  
**Last Updated**: 2025-07-25  
**Stakeholders**: Product, Engineering, Design, QA, Founders  
**Approvers**: CTO, Head of Product

---

## 1. Executive Summary

DICE is a powerful, modern character management platform for **Dungeons & Dragons 3.0e**, built for mobile and web. The app automates stat calculations, supports multi-class characters, and syncs across devices with offline functionality and full accessibility compliance. It also includes guided onboarding for new players and is architected for expansion into inventory, spells, and later editions (3.5e, 5e).

---

## 2. Problem Statement

Despite an active 3.0e player base, most tools are outdated or unsupported. Players are forced to manually track stats, modifiers, and features that are error-prone and time-consuming. DICE offers a comprehensive, rules-compliant solution for efficient, enjoyable, and cross-platform character management. DICE fills this gap with a mobile-first, PWA-ready, accessibility-compliant character management app using up-to-date technology and UX standards.

---

## 3. Goals & Objectives

| Goal                                             | Metric/KPI        | Target               |
| ------------------------------------------------ | ----------------- | -------------------- |
| Validate UX + flow using mocked server PWA       | Internal QA + NPS | Aug 20               |
| Replicate full PWA UX in Flutter                 | Functional parity | Sep 5                |
| Develop and deploy real backend APIs             | Availability      | Sep 20               |
| Replace mocks with real API calls (web & mobile) | Full integration  | Oct 5                |
| Launch MVP for D&D 3.0e                          | GA Release        | Oct 25, 2025         |
| Excellent UX across platforms                    | NPS, App Rating   | NPS > 40, 4.5+ stars |
| Full WCAG AA accessibility                       | Audit Results     | 100% AA pass         |
| PWA ready web app                                | Lighthouse score  | 100%                 |
| Smart, risk-weighted testing                     | Coverage          | 100% core logic      |

---

## 4. Success Metrics

- ≥ 1,000 characters created in 3 months  
- Median session length ≥ 8 minutes  
- Crash-free session rate ≥ 99% (Flutter)  
- 80%+ user satisfaction rating (beta survey)  
- WCAG 2.1 AA certification passed  
- All UI components covered by Storybook  
- PWA installable on all major browsers/devices  

---

## 5. Scope

### In Scope (MVP)

- Mocked server-driven UI: PWA → Flutter  
- Step-by-step character creation wizard
- Full character sheet (view/edit)
- Automatic stat and bonus calculation
- Multiclass and racial features
- Guided onboarding tutorial
- Device sync via user login
- Offline access and deferred sync
- Storybook component library
- WCAG AA accessibility
- Web (PWA) + Flutter (iOS/Android) parity
- PWA install support  
- API integration post-mocks  

### Out of Scope (MVP)

- Spellbook management  
- Inventory system  
- Avatar generation  
- Combat/dice engine  
- Custom or homebrew rules

---

## 6. User Stories (Highlights)

Prioritised highlights from [User Stories](./user-stories.md):

- ✅ Create full D&D 3.0e character profiles (US1, US2, US5)  
- ✅ Auto-calculate modifiers and combat stats (US4, US3)  
- ✅ Support multi-class characters (US5)  
- ✅ Auto-fill race/class features and languages (US6)  
- ✅ Edit all editable fields, recalculate stats (US7)  
- ✅ Work fully offline, sync when online (US8, US9)  
- ✅ Manage multiple characters from dashboard (US10)  
- ✅ Provide onboarding tutorial (US11)  

---

## 7. Functional Requirements

| ID    | Requirement                                        | Priority |
| ----- | -------------------------------------------------- | -------- |
| FR001 | Multi-step character creation wizard               | High     |
| FR002 | Ability scores input + modifier calculation        | High     |
| FR003 | Class selection with hit dice & level tracking     | High     |
| FR004 | Derived stat engine: HP, AC, initiative, etc.      | High     |
| FR005 | Auto-populate class/racial features                | High     |
| FR006 | View/edit full character sheet                     | High     |
| FR007 | Persistent user account + OAuth login              | High     |
| FR008 | Offline mode with auto-sync queue on reconnect     | High     |
| FR009 | PWA: installable + offline (web)                   | High     |
| FR010 | Storybook with all production UI components        | Medium   |
| FR011 | First-time user tutorial during character creation | Medium   |

---

## 8. Non-Functional Requirements

| ID     | Requirement                                        | Priority |
| ------ | -------------------------------------------------- | -------- |
| NFR001 | P95 API latency < 300ms                            | High     |
| NFR002 | Mobile + web UX parity                             | High     |
| NFR003 | Full WCAG 2.1 AA compliance                        | High     |
| NFR004 | 4.5:1 contrast ratio minimum for all text          | High     |
| NFR005 | Semantic HTML and ARIA labels (web)                | High     |
| NFR006 | Keyboard navigation with visible focus             | High     |
| NFR007 | PWA installable + Lighthouse score = 100           | High     |
| NFR008 | Authentication & session security                  | High     |
| NFR009 | All images and controls labeled for screen readers | High     |
| NFR010 | Sync resilient to flaky connections                | High     |
| NFR011 | Wise test coverage (unit, integration)             | High     |
| NFR012 | 100% rules engine logic test coverage              | High     |
| NFR013 | Mock data layer identical to API schema            | High     |
| NFR014 | Seamless switch from mocks to live backend         | High     |

---

## 9. UX & Wireframes Overview

Wireframes based on [UX Wireframes](./ux_wireframes.md):

- **Dashboard**: grid/list of characters, editable cards  
- **Wizard**: 4-step flow with progress tracker: Profile → Class & Abilities → Combat → Traits  
- **Sheet View**: Tabbed UI with read-only and edit mode  
- **Settings**: sync status, offline toggle, login/logout  
- **Component patterns**: dropdowns, numeric steppers, modifiers, editable blocks  
- **Mobile-first design**: Responsive, large tap targets, progress indicators, foldable phones support, dual-pane character sheet  
- **Accessibility-first**: clear focus, ARIA regions, high contrast palette  

---

## 10. Technical Architecture

| Layer           | Stack                                              |
| --------------- | -------------------------------------------------- |
| Web Frontend    | Astro.js + React.js + TailwindCSS                  |
| Mobile Frontend | Flutter (iOS & Android)                            |
| Mock Server     | MirageJS (web), JSON fixtures (Flutter)            |
| Backend         | Nest.js + GraphQL + tRPC                           |
| Database        | PostgreSQL (AWS RDS)                               |
| CMS             | PayloadCMS (D&D rules data)                        |
| Sync & Offline  | SQLite (Flutter), IndexedDB (Web)                  |
| Realtime        | Server-Sent Events                                 |
| PWA             | Web manifest, service workers                      |
| CI/CD           | GitHub Actions                                     |
| Package Manager | pnpm                                               |
| Node Manager    | Volta                                              |
| Testing         | Testcontainers, Vitest, Playwright, Flutter Driver |
| Accessibility   | axe-core, Lighthouse CI                            |
| Design System   | Storybook with full UI coverage                    |
| Infrastructure  | Docker, Kubernetes, Terraform                      |
| Cloud           | AWS EU region (EU-central)                         |
| Local Dev       | Devcontainers, Testcontainers, Localstack          |

---

## 11. Assumptions

- All D&D 3.0 rules and data are sourced from public SRD  
- Class, race, and feat lists are fixed for MVP  
- UI components are shared across platforms as design tokens  
- PayloadCMS can serve all glossary and ability text reliably  
- Offline users can defer sync without data loss  
- Flutter apps will meet iOS + Android app store requirements

---

## 12. Risks & Mitigations

| Risk                             | Likelihood | Impact | Mitigation                                    |
| -------------------------------- | ---------- | ------ | --------------------------------------------- |
| Complexity of 3.0 rules          | Medium     | High   | Separate rule engine with strict tests        |
| PWA not mirroring mobile UX      | Medium     | Medium | Prioritise shared components via Storybook    |
| Accessibility failing audit      | Medium     | High   | Include a11y in all sprints + manual QA       |
| PayloadCMS schema inflexibility  | Low        | Medium | Define flexible, typed JSON content models    |
| Mock data diverges from real API | Medium     | High   | Use OpenAPI contract + types from day 1       |
| Foldable UX not optimised        | Low        | Medium | UX designed around responsive/adaptive layout |

---

## 13. Timeline & Milestones

| Milestone                    | Target Date        |
| ---------------------------- | ------------------ |
| 🟢 Project Kickoff            | July 29, 2025      |
| 🎨 Final UX Approval          | August 12, 2025    |
| 🔹 Mocked PWA MVP Ready       | August 20, 2025    |
| 🔹 Flutter MVP w/ Mocked Data | September 5, 2025  |
| 🛠️ Rules Engine Alpha         | August 30, 2025    |
| 🧪 Storybook Component QA     | September 10, 2025 |
| 🌐 Web MVP Unmocked (PWA)     | September 15, 2025 |
| 📱 Flutter MVP Unmocked       | September 25, 2025 |
| 🔒 Closed Alpha               | September 27, 2025 |
| 🚀 Open Beta                  | October 10, 2025   |
| 🎉 General Availability (GA)  | October 25, 2025   |

---

## 14. Open Questions

- Should offline mode support character creation or just editing?
- Will portrait/avatar generation be scoped for v1.1?
- Should Storybook be public for community contribution?

---

## 15. Test Coverage Strategy

| Module                           | Type                      | Target Coverage     | Notes                                 |
| -------------------------------- | ------------------------- | ------------------- | ------------------------------------- |
| Rule Engine (Modifiers, HP, BAB) | Unit                      | 100%                | High complexity, must match SRD logic |
| Mocked Data Layer                | Unit + Schema Validations | 100%                | High complexity, must match SRD logic |
| Character Creation Wizard        | Unit + Integration        | 90%                 | Core UX flow                          |
| Sync & Offline Logic             | Integration + Storage     | 95%                 | Critical for reliability              |
| Auth & Sessions                  | Integration               | 85%                 | External dependency + session expiry  |
| Character Sheet UI               | Snapshot + Accessibility  | 90%                 | High visibility, editable state       |
| Storybook Components             | Unit + Interaction + a11y | 90%                 | Design source of truth                |
| API & GraphQL                    | Contract + Resolver Tests | 85%                 | Validate schemas & business logic     |
| PWA (Web)                        | Integration + Lighthouse  | 100%                | Service workers, manifest, offline    |
| Accessibility                    | Automated + Manual        | 100% critical flows | Screen reader, contrast, navigation   |
| Mobile UI (Flutter)              | Unit + Driver             | 85%                 | Validate layout logic and sync        |

> **Overall Goal:** ≥ 85% total coverage  
> Focus: 100% on derived stats, rule engine, accessibility, and sync

---

## 16. Appendices

- [Functional Specs](./functional-specs.md)  
- [User Stories](./user-stories.md)  
- [UX Wireframes](./ux_wireframes.md)  
- [Accessibility QA Checklist](./a11y-checklist.md)  
