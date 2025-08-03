// D&D 3.0 Rules Calculations Engine
// Implements core D&D mechanics for character statistics
// Based on D&D 3.0 System Reference Document

import type { 
  Character, 
  AbilityScores, 
  CharacterClass, 
  CombatStats, 
  DerivedStats,
  ValidationResult 
} from 'src/types/character';

export class DnDCalculations {
  // Core D&D 3.0 ability modifier calculation: (score - 10) / 2, rounded down
  static getAbilityModifier(score: number): number {
    return Math.floor((score - 10) / 2);
  }

  // Calculate all ability modifiers at once
  static getAbilityModifiers(abilities: AbilityScores): Record<keyof AbilityScores, number> {
    return {
      strength: this.getAbilityModifier(abilities.strength),
      dexterity: this.getAbilityModifier(abilities.dexterity),
      constitution: this.getAbilityModifier(abilities.constitution),
      intelligence: this.getAbilityModifier(abilities.intelligence),
      wisdom: this.getAbilityModifier(abilities.wisdom),
      charisma: this.getAbilityModifier(abilities.charisma)
    };
  }

  // Calculate maximum hit points based on class hit dice and Constitution modifier
  static calculateHitPoints(character: Character): number {
    const conModifier = this.getAbilityModifier(character.abilities.constitution);
    let totalHP = 0;

    for (const characterClass of character.classes) {
      const hitDieSize = this.getHitDieSize(characterClass.hitDie);
      
      // First level gets maximum hit die + Con modifier
      // Additional levels get average + Con modifier (rounded down)
      if (characterClass.level >= 1) {
        totalHP += hitDieSize + conModifier; // First level
        
        if (characterClass.level > 1) {
          const averagePerLevel = Math.floor((hitDieSize + 1) / 2) + conModifier;
          totalHP += averagePerLevel * (characterClass.level - 1);
        }
      }
    }

    // Minimum 1 HP per level
    const totalLevel = character.classes.reduce((sum, cls) => sum + cls.level, 0);
    return Math.max(totalHP, totalLevel);
  }

  // Extract hit die size from string (e.g., "d10" -> 10)
  private static getHitDieSize(hitDie: string): number {
    const match = hitDie.match(/d(\d+)/);
    return match ? parseInt(match[1]) : 6; // Default to d6 if parsing fails
  }

  // Calculate Armor Class: 10 + Dex modifier + armor + shield + other modifiers
  static calculateArmorClass(character: Character): number {
    const dexModifier = this.getAbilityModifier(character.abilities.dexterity);
    let ac = 10 + dexModifier;

    // Add armor bonuses from equipment
    const armor = character.equipment.filter(item => 
      item.type === 'Armor' && item.equipped
    );
    
    const shield = character.equipment.filter(item =>
      item.type === 'Shield' && item.equipped
    );

    // For now, use simple AC calculation
    // In a full implementation, this would parse AC strings like "11 + Dex modifier"
    for (const armorPiece of armor) {
      if (armorPiece.ac) {
        const acValue = this.parseArmorClass(armorPiece.ac, dexModifier);
        ac = Math.max(ac, acValue); // Use best armor
      }
    }

    for (const shieldPiece of shield) {
      if (shieldPiece.ac) {
        const shieldBonus = parseInt(shieldPiece.ac.replace(/\D/g, '')) || 0;
        ac += shieldBonus;
      }
    }

    return ac;
  }

  // Parse armor class strings like "11 + Dex modifier" or "14"
  private static parseArmorClass(acString: string, dexModifier: number): number {
    const baseMatch = acString.match(/(\d+)/);
    const baseAC = baseMatch ? parseInt(baseMatch[1]) : 10;
    
    if (acString.includes('Dex')) {
      return baseAC + dexModifier;
    }
    
    return baseAC;
  }

  // Calculate initiative modifier (Dexterity modifier)
  static calculateInitiative(character: Character): number {
    return this.getAbilityModifier(character.abilities.dexterity);
  }

  // Calculate saving throws based on class and ability modifiers
  static calculateSavingThrows(character: Character): { fortitude: number; reflex: number; will: number } {
    const abilities = character.abilities;
    const conMod = this.getAbilityModifier(abilities.constitution);
    const dexMod = this.getAbilityModifier(abilities.dexterity);
    const wisMod = this.getAbilityModifier(abilities.wisdom);

    let fortBase = 0;
    let reflexBase = 0;
    let willBase = 0;

    // Calculate base saves from class levels
    for (const characterClass of character.classes) {
      const classSaves = this.getClassBaseSaves(characterClass);
      fortBase += classSaves.fortitude;
      reflexBase += classSaves.reflex;
      willBase += classSaves.will;
    }

    return {
      fortitude: fortBase + conMod,
      reflex: reflexBase + dexMod,
      will: willBase + wisMod
    };
  }

  // Get base saving throw bonuses for a class (simplified)
  private static getClassBaseSaves(characterClass: CharacterClass): { fortitude: number; reflex: number; will: number } {
    const level = characterClass.level;
    
    // Simplified base save progression (good save = 2 + level/2, poor save = level/3)
    const goodSave = Math.floor(level / 2) + 2;
    const poorSave = Math.floor(level / 3);

    // Class-specific save progressions (simplified)
    switch (characterClass.name.toLowerCase()) {
      case 'fighter':
        return { fortitude: goodSave, reflex: poorSave, will: poorSave };
      case 'wizard':
        return { fortitude: poorSave, reflex: poorSave, will: goodSave };
      case 'rogue':
        return { fortitude: poorSave, reflex: goodSave, will: poorSave };
      case 'cleric':
        return { fortitude: goodSave, reflex: poorSave, will: goodSave };
      default:
        return { fortitude: poorSave, reflex: poorSave, will: poorSave };
    }
  }

  // Calculate base attack bonus
  static calculateBaseAttackBonus(character: Character): number {
    let totalBAB = 0;

    for (const characterClass of character.classes) {
      totalBAB += this.getClassBaseAttackBonus(characterClass);
    }

    return totalBAB;
  }

  // Get base attack bonus for a class level
  private static getClassBaseAttackBonus(characterClass: CharacterClass): number {
    const level = characterClass.level;

    // BAB progression by class type
    switch (characterClass.name.toLowerCase()) {
      case 'fighter': // Full BAB progression
        return level;
      case 'cleric':
      case 'rogue': // 3/4 BAB progression
        return Math.floor(level * 3 / 4);
      case 'wizard': // 1/2 BAB progression
        return Math.floor(level / 2);
      default:
        return Math.floor(level * 3 / 4); // Default to medium progression
    }
  }

  // Calculate movement speed based on race and equipment
  static calculateMovementSpeed(character: Character): number {
    let baseSpeed = character.profile.race.speed || 30;

    // TODO: Modify based on armor and encumbrance
    // For now, return base speed
    return baseSpeed;
  }

  // Calculate skill modifiers
  static calculateSkillModifiers(character: Character): Record<string, number> {
    const abilities = character.abilities;
    const modifiers = this.getAbilityModifiers(abilities);

    // Basic skill list with associated abilities
    const skills = {
      'Acrobatics': modifiers.dexterity,
      'Animal Handling': modifiers.wisdom,
      'Arcana': modifiers.intelligence,
      'Athletics': modifiers.strength,
      'Deception': modifiers.charisma,
      'History': modifiers.intelligence,
      'Insight': modifiers.wisdom,
      'Intimidation': modifiers.charisma,
      'Investigation': modifiers.intelligence,
      'Medicine': modifiers.wisdom,
      'Nature': modifiers.intelligence,
      'Perception': modifiers.wisdom,
      'Performance': modifiers.charisma,
      'Persuasion': modifiers.charisma,
      'Religion': modifiers.intelligence,
      'Sleight of Hand': modifiers.dexterity,
      'Stealth': modifiers.dexterity,
      'Survival': modifiers.wisdom
    };

    // TODO: Add ranks, class skills, and other bonuses
    return skills;
  }

  // Validate multiclass requirements
  static validateMulticlass(classes: CharacterClass[]): ValidationResult {
    const errors: string[] = [];
    const warnings: string[] = [];

    if (classes.length === 0) {
      errors.push('Character must have at least one class');
    }

    // Check for duplicate classes
    const classNames = classes.map(c => c.name.toLowerCase());
    const duplicates = classNames.filter((name, index) => classNames.indexOf(name) !== index);
    if (duplicates.length > 0) {
      errors.push(`Duplicate classes found: ${duplicates.join(', ')}`);
    }

    // Warn about complex multiclassing
    if (classes.length > 2) {
      warnings.push('Multiclassing with more than 2 classes can be complex to manage');
    }

    return {
      isValid: errors.length === 0,
      errors,
      warnings
    };
  }

  // Generate all derived statistics
  static calculateDerivedStats(character: Character): DerivedStats {
    return {
      abilityModifiers: this.getAbilityModifiers(character.abilities),
      hitPoints: this.calculateHitPoints(character),
      armorClass: this.calculateArmorClass(character),
      initiative: this.calculateInitiative(character),
      savingThrows: this.calculateSavingThrows(character),
      baseAttackBonus: this.calculateBaseAttackBonus(character),
      skillModifiers: this.calculateSkillModifiers(character)
    };
  }

  // Validate ability scores (D&D 3.0 typically uses 3-18 range)
  static validateAbilityScores(abilities: AbilityScores): ValidationResult {
    const errors: string[] = [];
    const warnings: string[] = [];

    const abilityNames: (keyof AbilityScores)[] = [
      'strength', 'dexterity', 'constitution', 
      'intelligence', 'wisdom', 'charisma'
    ];

    for (const abilityName of abilityNames) {
      const score = abilities[abilityName];
      
      if (score < 1 || score > 25) {
        errors.push(`${abilityName} score ${score} is outside valid range (1-25)`);
      } else if (score < 8) {
        warnings.push(`${abilityName} score ${score} is very low and may impact gameplay`);
      } else if (score > 18) {
        warnings.push(`${abilityName} score ${score} is exceptionally high`);
      }
    }

    return {
      isValid: errors.length === 0,
      errors,
      warnings
    };
  }

  // Roll ability scores using various methods
  static rollAbilityScores(method: 'standard' | 'pointBuy' | 'dice'): AbilityScores {
    switch (method) {
      case 'standard':
        return {
          strength: 15,
          dexterity: 14,
          constitution: 13,
          intelligence: 12,
          wisdom: 10,
          charisma: 8
        };
      
      case 'pointBuy':
        // Return base scores for point buy (player adjusts)
        return {
          strength: 10,
          dexterity: 10,
          constitution: 10,
          intelligence: 10,
          wisdom: 10,
          charisma: 10
        };
      
      case 'dice':
        // 4d6 drop lowest for each ability
        return {
          strength: this.roll4d6DropLowest(),
          dexterity: this.roll4d6DropLowest(),
          constitution: this.roll4d6DropLowest(),
          intelligence: this.roll4d6DropLowest(),
          wisdom: this.roll4d6DropLowest(),
          charisma: this.roll4d6DropLowest()
        };
      
      default:
        return this.rollAbilityScores('standard');
    }
  }

  // Roll 4d6, drop lowest die
  private static roll4d6DropLowest(): number {
    const rolls = Array.from({ length: 4 }, () => Math.floor(Math.random() * 6) + 1);
    rolls.sort((a, b) => b - a); // Sort descending
    return rolls.slice(0, 3).reduce((sum, roll) => sum + roll, 0); // Take top 3
  }
}

// Export singleton instance with common methods
export const dndCalculations = DnDCalculations; 