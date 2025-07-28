// D&D 3.0 Character Type Definitions
// Based on DICE functional specifications and D&D 3.0 rules

export interface Character {
  id: string;
  profile: CharacterProfile;
  abilities: AbilityScores;
  classes: CharacterClass[];
  combat: CombatStats;
  traits: CharacterTraits;
  equipment: Equipment[];
  spells?: Spell[];
  notes: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CharacterProfile {
  name: string;
  race: Race;
  alignment: Alignment;
  level: number;
  experience: number;
  age?: number;
  gender?: string;
  height?: string;
  weight?: string;
  background?: string;
}

export interface AbilityScores {
  strength: number;
  dexterity: number;
  constitution: number;
  intelligence: number;
  wisdom: number;
  charisma: number;
}

export interface CharacterClass {
  id: string;
  name: string;
  level: number;
  hitDie: string;
  primaryAbility: string[];
  savingThrowProficiencies: string[];
  skillProficiencies: number;
  armorProficiencies: string[];
  weaponProficiencies: string[];
  spellcastingAbility?: string;
}

export interface CombatStats {
  hitPoints: {
    current: number;
    maximum: number;
    temporary: number;
  };
  armorClass: number;
  initiative: number;
  speed: number;
  baseAttackBonus: number;
  savingThrows: {
    fortitude: number;
    reflex: number;
    will: number;
  };
}

export interface CharacterTraits {
  racialTraits: string[];
  classAbilities: string[];
  languages: string[];
  feats: string[];
}

export interface Race {
  id: string;
  name: string;
  abilityScoreIncrease: Record<string, number>;
  size: 'Small' | 'Medium' | 'Large';
  speed: number;
  languages: string[];
  traits: string[];
  description: string;
}

export interface Alignment {
  id: string;
  name: string;
  shortName: string;
  description: string;
}

export interface Equipment {
  id: string;
  name: string;
  type: 'Weapon' | 'Armor' | 'Shield' | 'Item';
  category: string;
  damage?: string;
  ac?: string;
  weight: number;
  cost: string;
  properties: string[];
  equipped: boolean;
  quantity: number;
}

export interface Spell {
  id: string;
  name: string;
  level: number;
  school: string;
  castingTime: string;
  range: string;
  components: string[];
  duration: string;
  description: string;
  prepared?: boolean;
}

export interface Skill {
  name: string;
  ability: keyof AbilityScores;
  trained: boolean;
  ranks: number;
  modifier: number;
}

export interface CreateCharacterRequest {
  profile: Omit<CharacterProfile, 'level' | 'experience'>;
  abilities: AbilityScores;
  classes: Omit<CharacterClass, 'id'>[];
  notes?: string;
}

export interface UpdateCharacterRequest {
  profile?: Partial<CharacterProfile>;
  abilities?: Partial<AbilityScores>;
  classes?: CharacterClass[];
  combat?: Partial<CombatStats>;
  traits?: Partial<CharacterTraits>;
  equipment?: Equipment[];
  spells?: Spell[];
  notes?: string;
}

// Utility types for calculations
export interface DerivedStats {
  abilityModifiers: Record<keyof AbilityScores, number>;
  hitPoints: number;
  armorClass: number;
  initiative: number;
  savingThrows: {
    fortitude: number;
    reflex: number;
    will: number;
  };
  baseAttackBonus: number;
  skillModifiers: Record<string, number>;
}

export interface ValidationResult {
  isValid: boolean;
  errors: string[];
  warnings: string[];
}

// Form-related types
export interface CharacterFormStep {
  step: number;
  title: string;
  description: string;
  completed: boolean;
  data: any;
}

export interface CharacterCreationWizardState {
  currentStep: number;
  steps: CharacterFormStep[];
  character: Partial<Character>;
  isDraft: boolean;
  lastSaved: Date | null;
} 