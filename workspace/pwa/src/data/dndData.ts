// Static D&D 3.0 Game Data
// Based on DICE seed data and D&D 3.0 System Reference Document
// Provides races, classes, alignments, and other game references

import type { Race, Alignment } from '../types/character';

// D&D 3.0 Races
export const races: Race[] = [
  {
    id: 'human',
    name: 'Human',
    abilityScoreIncrease: { all: 1 }, // Extra skill point and feat
    size: 'Medium',
    speed: 30,
    languages: ['Common'],
    traits: ['Extra Skill', 'Extra Feat'],
    description: 'Versatile and ambitious, humans are known for their adaptability and drive to achieve greatness in their brief lives.'
  },
  {
    id: 'elf',
    name: 'Elf',
    abilityScoreIncrease: { dexterity: 2, constitution: -2 },
    size: 'Medium',
    speed: 30,
    languages: ['Common', 'Elvish'],
    traits: ['Low-Light Vision', 'Weapon Proficiency', 'Keen Senses', 'Immunity to Sleep'],
    description: 'Elves are magical people of otherworldly grace, living in places of ethereal beauty, in the midst of ancient forests or in silvery spires.'
  },
  {
    id: 'dwarf',
    name: 'Dwarf',
    abilityScoreIncrease: { constitution: 2, charisma: -2 },
    size: 'Medium',
    speed: 20, // Dwarfs have slower speed but it's not reduced by armor
    languages: ['Common', 'Dwarvish'],
    traits: ['Darkvision', 'Weapon Familiarity', 'Stability', 'Stonecunning', '+2 vs Poison'],
    description: 'Bold and hardy, dwarves are known as skilled warriors, miners, and workers of stone and metal.'
  },
  {
    id: 'halfling',
    name: 'Halfling',
    abilityScoreIncrease: { dexterity: 2, strength: -2 },
    size: 'Small',
    speed: 20,
    languages: ['Common', 'Halfling'],
    traits: ['+2 vs Fear', '+1 to thrown weapons and slings', 'Listen and Move Silently +2'],
    description: 'The diminutive halflings survive in a world full of larger creatures by avoiding notice or, barring that, avoiding offense.'
  },
  {
    id: 'gnome',
    name: 'Gnome',
    abilityScoreIncrease: { constitution: 2, strength: -2 },
    size: 'Small',
    speed: 20,
    languages: ['Common', 'Gnome'],
    traits: ['Low-Light Vision', 'Weapon Familiarity', 'Spell-Like Abilities', '+2 vs Illusions'],
    description: 'Gnomes are welcome everywhere as technicians, alchemists, and inventors.'
  },
  {
    id: 'half-elf',
    name: 'Half-Elf',
    abilityScoreIncrease: {}, // No ability modifiers
    size: 'Medium',
    speed: 30,
    languages: ['Common', 'Elvish'],
    traits: ['Low-Light Vision', 'Immunity to Sleep', 'Extra Skill Points'],
    description: 'Half-elves have no lands of their own, though they are welcome in human cities and elven forests.'
  },
  {
    id: 'half-orc',
    name: 'Half-Orc',
    abilityScoreIncrease: { strength: 2, intelligence: -2, charisma: -2 },
    size: 'Medium',
    speed: 30,
    languages: ['Common', 'Orc'],
    traits: ['Darkvision', 'Orc Blood'],
    description: 'Half-orcs are the short-tempered and sullen result of human and orc pairings.'
  }
];

// D&D 3.0 Alignments
export const alignments: Alignment[] = [
  {
    id: 'lawful-good',
    name: 'Lawful Good',
    shortName: 'LG',
    description: 'A lawful good character acts as a good person is expected or required to act. She combines a commitment to oppose evil with the discipline to fight relentlessly.'
  },
  {
    id: 'neutral-good',
    name: 'Neutral Good',
    shortName: 'NG', 
    description: 'A neutral good character does the best that a good person can do. He is devoted to helping others.'
  },
  {
    id: 'chaotic-good',
    name: 'Chaotic Good',
    shortName: 'CG',
    description: 'A chaotic good character acts as his conscience directs him with little regard for what others expect of him.'
  },
  {
    id: 'lawful-neutral',
    name: 'Lawful Neutral',
    shortName: 'LN',
    description: 'A lawful neutral character acts as law, tradition, or a personal code directs her.'
  },
  {
    id: 'true-neutral',
    name: 'True Neutral',
    shortName: 'N',
    description: 'A neutral character does what seems to be a good idea. She doesn\'t feel strongly one way or the other when it comes to good vs. evil or law vs. chaos.'
  },
  {
    id: 'chaotic-neutral',
    name: 'Chaotic Neutral',
    shortName: 'CN',
    description: 'A chaotic neutral character follows his whims. He is an individualist first and last.'
  },
  {
    id: 'lawful-evil',
    name: 'Lawful Evil',
    shortName: 'LE',
    description: 'A lawful evil villain methodically takes what he wants within the limits of his code of conduct.'
  },
  {
    id: 'neutral-evil',
    name: 'Neutral Evil',
    shortName: 'NE',
    description: 'A neutral evil villain does whatever she can get away with. She is out for herself, pure and simple.'
  },
  {
    id: 'chaotic-evil',
    name: 'Chaotic Evil',
    shortName: 'CE',
    description: 'A chaotic evil character does whatever his greed, hatred, and lust for destruction drive him to do.'
  }
];

// D&D 3.0 Base Classes
export const baseClasses = [
  {
    id: 'barbarian',
    name: 'Barbarian',
    hitDie: 'd12',
    primaryAbility: ['Strength'],
    savingThrowProficiencies: ['Fortitude', 'Reflex'],
    skillProficiencies: 4,
    armorProficiencies: ['Light', 'Medium', 'Shields (except tower shields)'],
    weaponProficiencies: ['Simple', 'Martial'],
    description: 'A ferocious warrior of primitive background who can enter a battle rage.'
  },
  {
    id: 'bard',
    name: 'Bard',
    hitDie: 'd6',
    primaryAbility: ['Charisma'],
    savingThrowProficiencies: ['Reflex', 'Will'],
    skillProficiencies: 6,
    armorProficiencies: ['Light', 'Shields (except tower shields)'],
    weaponProficiencies: ['Simple', 'Longsword', 'Rapier', 'Sap', 'Short sword', 'Shortbow', 'Whip'],
    spellcastingAbility: 'Charisma',
    description: 'A master of song, speech, and the magic they contain.'
  },
  {
    id: 'cleric',
    name: 'Cleric',
    hitDie: 'd8',
    primaryAbility: ['Wisdom'],
    savingThrowProficiencies: ['Fortitude', 'Will'],
    skillProficiencies: 2,
    armorProficiencies: ['All', 'Shields'],
    weaponProficiencies: ['Simple'],
    spellcastingAbility: 'Wisdom',
    description: 'A master of divine magic and a capable warrior as well.'
  },
  {
    id: 'druid',
    name: 'Druid',
    hitDie: 'd8',
    primaryAbility: ['Wisdom'],
    savingThrowProficiencies: ['Fortitude', 'Will'],
    skillProficiencies: 4,
    armorProficiencies: ['Light', 'Medium', 'Shields (non-metal only)'],
    weaponProficiencies: ['Club', 'Dagger', 'Dart', 'Quarterstaff', 'Scimitar', 'Sickle', 'Shortspear', 'Sling', 'Spear'],
    spellcastingAbility: 'Wisdom',
    description: 'One who draws power from nature itself or a nature deity.'
  },
  {
    id: 'fighter',
    name: 'Fighter',
    hitDie: 'd10',
    primaryAbility: ['Strength', 'Dexterity'],
    savingThrowProficiencies: ['Fortitude'],
    skillProficiencies: 2,
    armorProficiencies: ['All', 'Shields'],
    weaponProficiencies: ['Simple', 'Martial'],
    description: 'A master of martial combat, skilled with a variety of weapons and armor.'
  },
  {
    id: 'monk',
    name: 'Monk',
    hitDie: 'd8',
    primaryAbility: ['Dexterity', 'Wisdom'],
    savingThrowProficiencies: ['Fortitude', 'Reflex', 'Will'],
    skillProficiencies: 4,
    armorProficiencies: [],
    weaponProficiencies: ['Club', 'Crossbow (light or heavy)', 'Dagger', 'Handaxe', 'Javelin', 'Kama', 'Nunchaku', 'Quarterstaff', 'Sai', 'Shuriken', 'Siangham', 'Sling'],
    description: 'A martial artist whose inner power grants extraordinary abilities.'
  },
  {
    id: 'paladin',
    name: 'Paladin',
    hitDie: 'd10',
    primaryAbility: ['Strength', 'Charisma'],
    savingThrowProficiencies: ['Fortitude', 'Will'],
    skillProficiencies: 2,
    armorProficiencies: ['All', 'Shields'],
    weaponProficiencies: ['Simple', 'Martial'],
    spellcastingAbility: 'Wisdom',
    description: 'A champion of justice and destroyer of evil, protected and strengthened by an array of divine powers.'
  },
  {
    id: 'ranger',
    name: 'Ranger',
    hitDie: 'd8',
    primaryAbility: ['Dexterity', 'Wisdom'],
    savingThrowProficiencies: ['Fortitude', 'Reflex'],
    skillProficiencies: 6,
    armorProficiencies: ['Light', 'Medium', 'Shields'],
    weaponProficiencies: ['Simple', 'Martial'],
    spellcastingAbility: 'Wisdom',
    description: 'A skilled hunter and tracker who lives at the edge of civilization.'
  },
  {
    id: 'rogue',
    name: 'Rogue',
    hitDie: 'd6',
    primaryAbility: ['Dexterity'],
    savingThrowProficiencies: ['Reflex'],
    skillProficiencies: 8,
    armorProficiencies: ['Light'],
    weaponProficiencies: ['Simple', 'Hand crossbow', 'Rapier', 'Sap', 'Shortbow', 'Short sword'],
    description: 'A tricky, skillful scout and spy who wins the day by stealth rather than brute force.'
  },
  {
    id: 'sorcerer',
    name: 'Sorcerer',
    hitDie: 'd4',
    primaryAbility: ['Charisma'],
    savingThrowProficiencies: ['Will'],
    skillProficiencies: 2,
    armorProficiencies: [],
    weaponProficiencies: ['Simple'],
    spellcastingAbility: 'Charisma',
    description: 'A spellcaster who draws on inherent magic from a draconic or other exotic bloodline.'
  },
  {
    id: 'wizard',
    name: 'Wizard',
    hitDie: 'd4',
    primaryAbility: ['Intelligence'],
    savingThrowProficiencies: ['Will'],
    skillProficiencies: 2,
    armorProficiencies: [],
    weaponProficiencies: ['Simple'],
    spellcastingAbility: 'Intelligence',
    description: 'A potent spellcaster schooled in the arcane arts.'
  }
];

// D&D Skills
export const skills = [
  { name: 'Appraise', ability: 'Intelligence' },
  { name: 'Balance', ability: 'Dexterity' },
  { name: 'Bluff', ability: 'Charisma' },
  { name: 'Climb', ability: 'Strength' },
  { name: 'Concentration', ability: 'Constitution' },
  { name: 'Craft', ability: 'Intelligence' },
  { name: 'Decipher Script', ability: 'Intelligence' },
  { name: 'Diplomacy', ability: 'Charisma' },
  { name: 'Disable Device', ability: 'Intelligence' },
  { name: 'Disguise', ability: 'Charisma' },
  { name: 'Escape Artist', ability: 'Dexterity' },
  { name: 'Forgery', ability: 'Intelligence' },
  { name: 'Gather Information', ability: 'Charisma' },
  { name: 'Handle Animal', ability: 'Charisma' },
  { name: 'Heal', ability: 'Wisdom' },
  { name: 'Hide', ability: 'Dexterity' },
  { name: 'Intimidate', ability: 'Charisma' },
  { name: 'Jump', ability: 'Strength' },
  { name: 'Knowledge', ability: 'Intelligence' },
  { name: 'Listen', ability: 'Wisdom' },
  { name: 'Move Silently', ability: 'Dexterity' },
  { name: 'Open Lock', ability: 'Dexterity' },
  { name: 'Perform', ability: 'Charisma' },
  { name: 'Profession', ability: 'Wisdom' },
  { name: 'Ride', ability: 'Dexterity' },
  { name: 'Search', ability: 'Intelligence' },
  { name: 'Sense Motive', ability: 'Wisdom' },
  { name: 'Sleight of Hand', ability: 'Dexterity' },
  { name: 'Spellcraft', ability: 'Intelligence' },
  { name: 'Spot', ability: 'Wisdom' },
  { name: 'Survival', ability: 'Wisdom' },
  { name: 'Swim', ability: 'Strength' },
  { name: 'Tumble', ability: 'Dexterity' },
  { name: 'Use Magic Device', ability: 'Charisma' },
  { name: 'Use Rope', ability: 'Dexterity' }
];

// Common languages
export const languages = [
  'Common', 'Abyssal', 'Aquan', 'Auran', 'Celestial', 'Draconic', 
  'Druidic', 'Dwarven', 'Elven', 'Giant', 'Gnome', 'Goblin', 
  'Gnoll', 'Halfling', 'Ignan', 'Infernal', 'Orc', 'Sylvan', 'Terran'
];

// Helper functions
export function getRaceById(id: string): Race | undefined {
  return races.find(race => race.id === id);
}

export function getAlignmentById(id: string): Alignment | undefined {
  return alignments.find(alignment => alignment.id === id);
}

export function getClassById(id: string) {
  return baseClasses.find(cls => cls.id === id);
}

export function getSkillByName(name: string) {
  return skills.find(skill => skill.name === name);
}

// Default character creation data
export const defaultCharacterData = {
  race: races[0], // Human
  alignment: alignments[1], // Neutral Good
  class: baseClasses[4], // Fighter
  abilities: {
    strength: 15,
    dexterity: 14,
    constitution: 13,
    intelligence: 12,
    wisdom: 10,
    charisma: 8
  }
}; 