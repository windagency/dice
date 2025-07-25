# DICE – Refined User Stories (v1.0.0)

---

## Epic: Character Creation Wizard

### "Create a new character profile"

**As a** first-time player  
**I want** to start a new character with a multi-step form  
**So that** I can play and save my progress at each step

* Acceptance Criteria:
  * [ ] Given: I am logged in or in guest mode
  * [ ] When: I click “Create New Character”
  * [ ] Then: A step-by-step wizard opens
  * [ ] And: Each step has “Next” and “Back” buttons
  * [ ] And: I cannot skip required fields

---

### "Input personal attributes"

**As a** player  
**I want** to enter my character’s physical and identity traits  
**So that** my character is uniquely defined

* Acceptance Criteria:
  * [ ] Fields: name (required), gender, age, size, weight, skin color, eye color, hair color, distinctive signs, place of origin
  * [ ] Input validation: name required, age ≥ 0
  * [ ] Optional fields are clearly marked

---

### "Select alignment"

**As a** player  
**I want** to choose my character’s alignment  
**So that** it reflects their moral and ethical behavior

* Acceptance Criteria:
  * [ ] Options include 9 alignments from D&D 3.0 (e.g., Lawful Good)
  * [ ] Only one alignment can be selected
  * [ ] Description is displayed for each

---

### "Choose race"

**As a** player  
**I want** to select a character race  
**So that** racial traits and modifiers apply automatically

* Acceptance Criteria:
  * [ ] Options match D&D 3.0 core races (e.g., Human, Elf, Dwarf, Half-Orc, etc.)
  * [ ] Race selection updates racial abilities and size category
  * [ ] Selected race is locked after creation unless re-rolled

---

### "Choose class"

**As a** player  
**I want** to assign a class to my character  
**So that** the system calculates class-based values

* Acceptance Criteria:
  * [ ] Classes include those from D&D 3.0 core (e.g., Fighter, Rogue, Wizard)
  * [ ] Each class shows its hit die, base attack bonus, save progressions
  * [ ] Only one class is selectable for level 1
  * [ ] Multiclassing is out of scope for v1.0

---

### "Choose deity or religion"

**As a** lore-driven player  
**I want** to optionally select a deity from the D&D pantheon  
**So that** it aligns with my alignment and roleplay goals

* Acceptance Criteria:
  * [ ] List uses D&D 3.0 deities, grouped by alignment
  * [ ] Field is optional
  * [ ] Tooltip explains deity domains and alignment requirements

---

## Epic: Ability Scores

### "Assign ability scores manually"

**As a** player  
**I want** to manually input my six ability scores  
**So that** my character’s foundation is defined

* Acceptance Criteria:
  * [ ] Fields: STR, DEX, CON, INT, WIS, CHA
  * [ ] Allowed values: 3–18
  * [ ] Modifier auto-calculates and displays next to each score
  * [ ] Modifier uses: floor((score - 10) / 2)

---

## Epic: Hit Points Calculation

### "Calculate starting hit points"

**As a** player  
**I want** to roll or set my HP based on my class  
**So that** my health is valid according to D&D 3.0 rules

* Acceptance Criteria:
  * [ ] Class determines hit die (e.g., d6, d8, d10)
  * [ ] Default: maximum HP at level 1 (e.g., d8 → 8)
  * [ ] Constitution modifier is added
  * [ ] Total = max hit die + CON mod
  * [ ] Input is validated and restricted to class-legal range

---

## Epic: Auto-Calculated Derived Stats

### "Auto-calculate saving throws"

**As a** player  
**I want** my Fortitude, Reflex, and Will saves to be calculated  
**So that** I don’t have to reference rulebooks

* Acceptance Criteria:
  * [ ] Each save = base save (class table) + relevant ability modifier
  * [ ] Fortitude uses CON, Reflex uses DEX, Will uses WIS
  * [ ] Values update if ability scores or class change

---

### "Calculate initiative and armor class"

**As a** player  
**I want** to see initiative and AC auto-filled  
**So that** I can act in combat with correct stats

* Acceptance Criteria:
  * [ ] Initiative = DEX modifier
  * [ ] Armor Class = 10 + DEX mod + size mod + race bonus (if any)
  * [ ] Size modifier adjusts AC and attack bonuses

---

### "Determine carrying capacity and movement speed"

**As a** player  
**I want** to know how much I can carry and how fast I move  
**So that** I can manage my gear and positioning

* Acceptance Criteria:
  * [ ] Strength score determines light/medium/heavy load thresholds
  * [ ] Racial base speed is displayed (e.g., Dwarf = 20 ft.)
  * [ ] Sprint = 4x base speed (unencumbered)
  * [ ] Load affects speed according to SRD rules

---

### "Calculate base attack and ranged bonus"

**As a** player  
**I want** to see my character’s attack bonuses  
**So that** I can resolve attacks correctly in-game

* Acceptance Criteria:
  * [ ] Base Attack Bonus from class table (level 1 only)
  * [ ] Melee = BAB + STR mod
  * [ ] Ranged = BAB + DEX mod
  * [ ] Size modifier applied to both

---

### "Auto-fill known languages and traits"

**As a** player  
**I want** my known languages and racial features filled in  
**So that** I can reference them easily during play

* Acceptance Criteria:
  * [ ] Race defines known language(s)
  * [ ] INT mod gives extra languages (if positive)
  * [ ] Racial abilities listed with full descriptions

---

## Epic: Character Sheet & Persistence

### "View complete character sheet"

**As a** player  
**I want** to see all my character details on one screen  
**So that** I can use it during a session

* Acceptance Criteria:
  * [ ] Sheet shows all basic info, stats, modifiers, and abilities
  * [ ] Read-only by default
  * [ ] Mobile and foldable-compatible layout

---

### "Edit character sheet post-creation"

**As a** returning player  
**I want** to edit any part of my character  
**So that** I can reflect in-game progress or corrections

* Acceptance Criteria:
  * [ ] Any field is editable unless locked by rule (e.g., race/class at level 1)
  * [ ] Changes are autosaved or explicitly saved
  * [ ] Sheet recalculates affected derived stats

---

### "Access character offline"

**As a** player  
**I want** my character sheet to work without internet  
**So that** I can play anywhere

* Acceptance Criteria:
  * [ ] All data stored locally (IndexedDB or SQLite)
  * [ ] Auto-syncs when reconnecting
  * [ ] Offline banner shown in UI

---

### "Sync character across devices"

**As a** multi-device user  
**I want** my character to sync between mobile and web  
**So that** I don’t lose progress

* Acceptance Criteria:
  * [ ] Cloud sync uses user ID or token
  * [ ] Syncs on open or manually
  * [ ] Conflict resolution uses last-write-wins

---

## Epic: Rules Guidance and Validation

### "Prevent invalid character builds"

**As a** player  
**I want** errors for illegal class/race/score combos  
**So that** my character is always rules-legal

* Acceptance Criteria:
  * [ ] Race/class restrictions enforced (e.g., Paladin must be Lawful Good)
  * [ ] Ability score caps validated (e.g., 20 max at level 1)
  * [ ] Error messages explain the fix

---

### "Explain derived stat formulas"

**As a** curious player  
**I want** to view the formula behind my stats  
**So that** I trust the app’s calculations

* Acceptance Criteria:
  * [ ] Tooltips available for derived stats (e.g., AC, attack bonus)
  * [ ] Shows base + modifiers
  * [ ] Updated live on stat/class change
