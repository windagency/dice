// API Transformers for tRPC-ready data transformation
// Handles conversion between frontend Character types and API data structures

import type { 
  Character, 
  CreateCharacterRequest, 
  UpdateCharacterRequest,
  CharacterProfile,
  AbilityScores,
  CharacterClass,
  CombatStats,
  CharacterTraits,
  Equipment,
  Spell
} from 'src/types/character';

export class CharacterTransformers {
  static fromApi(data: any): Character {
    return {
      id: data.id,
      profile: {
        name: data.profile.name,
        race: data.profile.race,
        alignment: data.profile.alignment,
        level: data.profile.level,
        experience: data.profile.experience,
        age: data.profile.age,
        gender: data.profile.gender,
        height: data.profile.height,
        weight: data.profile.weight,
        background: data.profile.background
      },
      abilities: {
        strength: data.abilities.strength,
        dexterity: data.abilities.dexterity,
        constitution: data.abilities.constitution,
        intelligence: data.abilities.intelligence,
        wisdom: data.abilities.wisdom,
        charisma: data.abilities.charisma
      },
      classes: data.classes.map((cls: any) => ({
        id: cls.id,
        name: cls.name,
        level: cls.level,
        hitDie: cls.hitDie,
        primaryAbility: cls.primaryAbility,
        savingThrowProficiencies: cls.savingThrowProficiencies,
        skillProficiencies: cls.skillProficiencies,
        armorProficiencies: cls.armorProficiencies,
        weaponProficiencies: cls.weaponProficiencies,
        spellcastingAbility: cls.spellcastingAbility
      })),
      combat: {
        hitPoints: {
          current: data.combat.hitPoints.current,
          maximum: data.combat.hitPoints.maximum,
          temporary: data.combat.hitPoints.temporary
        },
        armorClass: data.combat.armorClass,
        initiative: data.combat.initiative,
        speed: data.combat.speed,
        baseAttackBonus: data.combat.baseAttackBonus,
        savingThrows: {
          fortitude: data.combat.savingThrows.fortitude,
          reflex: data.combat.savingThrows.reflex,
          will: data.combat.savingThrows.will
        }
      },
      traits: {
        racialTraits: data.traits.racialTraits,
        classAbilities: data.traits.classAbilities,
        languages: data.traits.languages,
        feats: data.traits.feats
      },
      equipment: data.equipment || [],
      spells: data.spells || [],
      notes: data.notes || '',
      createdAt: new Date(data.createdAt),
      updatedAt: new Date(data.updatedAt)
    };
  }

  static toApi(character: Character): any {
    return {
      id: character.id,
      profile: character.profile,
      abilities: character.abilities,
      classes: character.classes,
      combat: character.combat,
      traits: character.traits,
      equipment: character.equipment,
      spells: character.spells,
      notes: character.notes,
      createdAt: character.createdAt.toISOString(),
      updatedAt: character.updatedAt.toISOString()
    };
  }

  static fromCreateRequest(request: CreateCharacterRequest): any {
    return {
      profile: request.profile,
      abilities: request.abilities,
      classes: request.classes,
      notes: request.notes || ''
    };
  }

  static fromUpdateRequest(request: UpdateCharacterRequest): any {
    return {
      profile: request.profile,
      abilities: request.abilities,
      classes: request.classes,
      combat: request.combat,
      traits: request.traits,
      equipment: request.equipment,
      spells: request.spells,
      notes: request.notes
    };
  }
} 