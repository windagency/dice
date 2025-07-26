
# Dungeons & Dragons 3.0 Character Manager – Functional Specification

Dungeons & Dragons is a tabletop roleplaying game. It is commonly abbreviated to D&D

## 1. Overview

**Name:** Dungeons & Dragons Character Manager  
**Platforms:** Web, iOS, Android (cross-platform)  
**Purpose:** Create, manage, and sync multiple Dungeons & Dragons 3.0 character sheets with auto-calculated stats and rule-based data population.

### Core Mechanic

D&D 3e centralises most rolls around a core mechanic using the twenty sided die. In most cases, success or failure at a task is determined by rolling a d20, adding a modifier, and comparing the result to a required target number.

Bonuses may be granted from various sources, and are generally pre-calculated on the player's character sheet. Sources of bonuses may include ability scores, class bonuses, magic items, spells, innate abilities from race, circumstance bonuses, and so on. Most bonuses have a named type, with the effect that two bonuses of the same type do not stack.

Other dice are still used for things such as weapon damage, spell damage, spell effects, character generation, and turn undead.

### Ability Scores

Ability scores are officially ordered as such: **Strength**, **Dexterity**, **Constitution**, **Intelligence**, **Wisdom**, **Charisma**. This places the physical stats first and the mental stats second. All ability scores have an associated modifier, equal to the ability score minus ten, divided by two. This modifier is applied to all relevant rolls; e.g. Strength modifier to melee attack rolls.

The modifier calculation makes high starting statistics very valuable, especially as ability scores can more readily increase above 18, such as by gaining one point to any ability score every four levels, and by the use of magic items like the belt of giant's strength.

### Race and class

The [Player's Handbook](./core-rulebooks/player-handbook.md) features seven races: **humans**, **dwarves**, **elves**, **gnomes**, **half-elves**, **half-orcs**, and **halflings**.

The book features ten classes: **barbarian**, **bard**, **cleric**, **druid**, **fighter**, **monk**, **paladin**, **ranger**, **rogue**, **sorcerer**, and **wizard**.

All classes raise at the same number of experience points. Multiclassing is possible for all characters simply by taking levels in different classes. Each race has a favored class, which can be taken without incurring a penalty for raising class levels unevenly.

Prestige classes are special character classes which have prerequisites that are normally met by first taking levels in one or more existing character classes.

### Skills and feats

All characters gain a variety of useful skills. A character's skill points per level depend on character class, with a maximum of 3 plus level in any skill that is on their class list, and half that for cross-class skills. Skills are rolled using the d20 mechanic, aiming to hit a DC.

Characters also gain feats, starting with one at first level and gaining one more at every third character level. Feats grant a variety of benefits such as bonuses to certain rolls, unlocking new combat abilities, magic item creation feats, or metamagic feats which modify spells.

### Combat and magic

Combat is turn-based. A combat round is canonically six seconds long. Rolling for initiative uses a d20 which adds the character's Dexterity modifier, and individual initiative is used for each combatant. Small and Medium-size creatures, such as halflings and humans respectively, take up a full five-foot square in combat, an adaption which aids the optional use of miniatures at a scale of five feet to one inch. Characters may take both a standard action (such as an attack or spell) and a move or move-equivalent action (moving their base speed) in any order.

Combats do not use facing, initiative rerolling, combat phases, or weapon speed modifiers. Weapons deal the same damage regardless of monster size. A death's door rule allows downed characters to survive until they reach -10 hit points, at which point they are dead. Poison tends to deal ability score damage, rather than instant death.

There are only three saving throw types: **Fortitude**, **Reflex**, and **Will**, which add the modifiers for **Constitution**, **Dexterity**, and **Wisdom**, respectively.

Spells of up to 9th level are available for all primary spellcaster classes, including cleric, druid, sorcerer, and wizard. Spellcasters also have access to 0th-level spells, although these are generally weak and still have a limited number of uses per day.

Nearly all magic items have a listed purchase price and item crafting prerequisites. Characters with the requisite item crafting feats can craft them for half the price in gold and 1/25 the price in XP. Items are standardly sold for half the buy price.

---

## 2. Core Functionalities

### 2.1. Character Creation

- Multi-step wizard with 4 steps:
  - **Profile:** name, race, alignment, age, gender, etc.
  - **Class & Abilities:** select class(es), level, ability scores
  - **Combat Stats:** HP, initiative, AC, attacks, movement, etc.
  - **Traits:** racial abilities, class abilities, known languages
- Ability scores range from 1–20
- Class, alignment, race, and religion are from fixed D&D 3.0 lists
- Support multi-class characters with individual level inputs

### 2.2. Derived Calculations

- **Modifiers:** `(score − 10) / 2`, rounded down
- **Saving Throws:** base + ability modifier
- **Base Attack Bonus:** per class level chart
- **Hit Points:** based on class hit dice
- **Carrying Capacity & Bulk:** strength-based
- **Movement Speed:** by race and class

### 2.3. Auto-Fill Features

- Automatically assign:
  - **Racial Traits**
  - **Class Abilities**
  - **Known Languages**
- Data sourced from a built-in D&D 3.0 reference database
- Fields are read-only and update automatically on selection changes

### 2.4. Character Sheet View

- Tabbed or scrollable layout:
  - Overview
  - Stats
  - Combat
  - Abilities
  - Notes
- Read-only display with a clear **Edit** toggle
- Auto-recalculate all dependent stats on change

### 2.5. Sync & Offline Support

- **User account required**
- Syncs data across web, iOS, and Android
- Local storage when offline (e.g., SQLite)
- Auto-sync once connection is restored
- Conflict handling: last-write-wins or versioned resolution

### 2.6. Multi-Character Management

- Unlimited characters per user
- Dashboard view:
  - Name, class(es), race, level, etc.
  - Edit/Delete/Clone options
- “Create New Character” flow accessible anytime

---

## 3. Technical Requirements

### 3.1. Framework

- **Flutter** (or **React Native + Expo** as alternative)
- Shared logic across platforms
- Web: Astro (+ React when needed) using same UI component library

### 3.2. Data Storage

- **Local:** SQLite or SecureStorage for offline-first behaviour
- **Cloud:** Firebase, Supabase, or AWS Amplify for:
  - Auth
  - Database (Firestore/PostgreSQL)
  - Realtime sync

### 3.3. Rule Data

- D&D 3.0 rules, classes, races, dice, and ability data stored in:
  - Local JSON for fast access
  - Remote DB (optional, for updates)

---

## 4. Non-Functional Requirements

- Responsive design for web and mobile
- Low-latency UI interactions
- Sync robustness in flaky network conditions
- Accessibility (screen readers, color contrast)
- Modular architecture for future expansion

---

## 5. Out of Scope (for MVP)

- Spellbook/spell tracking  
- Inventory and equipment system  
- In-app dice rolling  
- Rule enforcement for level-up or XP gates  
- Custom or homebrew rule support  
- Avatar generation with AI  
