// Mock Database Service for Characters
// Provides CRUD operations with localStorage persistence
// Simulates async database operations for realistic development

import type { Character, CreateCharacterRequest, UpdateCharacterRequest } from 'src/types/character';
import { v4 as uuidv4 } from 'uuid';
import { secureStorage } from 'src/lib/storage/SecureStorage';

export class MockDatabase {
  private characters: Character[] = [];
  private readonly storageKey = 'dice_characters';
  private readonly versionKey = 'dice_db_version';
  private readonly currentVersion = '1.0.0';

  constructor() {
    this.loadFromStorage();
    this.migrateIfNeeded();
  }

  // Simulate network delay for realistic development experience
  private async delay(ms: number = 100 + Math.random() * 200): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  private saveToStorage(): void {
    try {
      const data = {
        version: this.currentVersion,
        characters: this.characters,
        timestamp: new Date().toISOString()
      };
      secureStorage.setItem(this.storageKey, data);
    } catch (error) {
      console.error('Failed to save to secure storage:', error);
    }
  }

  private loadFromStorage(): void {
    try {
      const data = secureStorage.getItem<{
        version: string;
        characters: Character[];
        timestamp: string;
      }>(this.storageKey);
      
      if (data && data.characters) {
        this.characters = data.characters;
        
        // Convert date strings back to Date objects
        this.characters = this.characters.map(character => ({
          ...character,
          createdAt: new Date(character.createdAt),
          updatedAt: new Date(character.updatedAt)
        }));
      }
    } catch (error) {
      console.error('Failed to load from secure storage:', error);
      this.characters = [];
    }
  }

  private migrateIfNeeded(): void {
    const storedVersion = secureStorage.getItem<string>(this.versionKey);
    if (storedVersion !== this.currentVersion) {
      console.log(`Migrating database from ${storedVersion} to ${this.currentVersion}`);
      // Add migration logic here if needed
      secureStorage.setItem(this.versionKey, this.currentVersion);
    }
  }

  private generateId(): string {
    return uuidv4();
  }

  private validateCharacterData(data: any): void {
    if (!data.profile?.name) {
      throw new Error('Character name is required');
    }
    if (!data.abilities) {
      throw new Error('Character abilities are required');
    }
    if (!data.classes || data.classes.length === 0) {
      throw new Error('Character must have at least one class');
    }
  }

  // CRUD Operations

  async getCharacters(): Promise<Character[]> {
    await this.delay();
    return [...this.characters].sort((a, b) => 
      b.updatedAt.getTime() - a.updatedAt.getTime()
    );
  }

  async getCharacter(id: string): Promise<Character | null> {
    await this.delay();
    const character = this.characters.find(c => c.id === id);
    return character ? { ...character } : null;
  }

  async createCharacter(data: CreateCharacterRequest): Promise<Character> {
    await this.delay();
    
    this.validateCharacterData(data);

    const now = new Date();
    const character: Character = {
      id: this.generateId(),
      profile: {
        ...data.profile,
        level: 1,
        experience: 0
      },
      abilities: { ...data.abilities },
      classes: data.classes.map(cls => ({
        ...cls,
        id: this.generateId()
      })),
      combat: {
        hitPoints: { current: 0, maximum: 0, temporary: 0 },
        armorClass: 10,
        initiative: 0,
        speed: 30,
        baseAttackBonus: 0,
        savingThrows: { fortitude: 0, reflex: 0, will: 0 }
      },
      traits: {
        racialTraits: [],
        classAbilities: [],
        languages: [],
        feats: []
      },
      equipment: [],
      spells: [],
      notes: data.notes || '',
      createdAt: now,
      updatedAt: now
    };

    this.characters.push(character);
    this.saveToStorage();

    return { ...character };
  }

  async updateCharacter(id: string, updates: UpdateCharacterRequest): Promise<Character> {
    await this.delay();

    const index = this.characters.findIndex(c => c.id === id);
    if (index === -1) {
      throw new Error(`Character with id ${id} not found`);
    }

    const character = this.characters[index];
    const updatedCharacter: Character = {
      ...character,
      profile: updates.profile ? { ...character.profile, ...updates.profile } : character.profile,
      abilities: updates.abilities ? { ...character.abilities, ...updates.abilities } : character.abilities,
      classes: updates.classes || character.classes,
      combat: updates.combat ? { ...character.combat, ...updates.combat } : character.combat,
      traits: updates.traits ? { ...character.traits, ...updates.traits } : character.traits,
      equipment: updates.equipment || character.equipment,
      spells: updates.spells || character.spells,
      notes: updates.notes !== undefined ? updates.notes : character.notes,
      id, // Ensure ID cannot be changed
      updatedAt: new Date()
    };

    this.characters[index] = updatedCharacter;
    this.saveToStorage();

    return { ...updatedCharacter };
  }

  async deleteCharacter(id: string): Promise<void> {
    await this.delay();

    const index = this.characters.findIndex(c => c.id === id);
    if (index === -1) {
      throw new Error(`Character with id ${id} not found`);
    }

    this.characters.splice(index, 1);
    this.saveToStorage();
  }

  async duplicateCharacter(id: string, newName?: string): Promise<Character> {
    const original = await this.getCharacter(id);
    if (!original) {
      throw new Error(`Character with id ${id} not found`);
    }

    const duplicated = await this.createCharacter({
      profile: {
        name: newName || `${original.profile.name} (Copy)`,
        race: original.profile.race,
        alignment: original.profile.alignment,
        age: original.profile.age,
        gender: original.profile.gender,
        height: original.profile.height,
        weight: original.profile.weight,
        background: original.profile.background
      },
      abilities: { ...original.abilities },
      classes: original.classes.map(cls => ({
        name: cls.name,
        level: cls.level,
        hitDie: cls.hitDie,
        primaryAbility: [...cls.primaryAbility],
        savingThrowProficiencies: [...cls.savingThrowProficiencies],
        skillProficiencies: cls.skillProficiencies,
        armorProficiencies: [...cls.armorProficiencies],
        weaponProficiencies: [...cls.weaponProficiencies],
        spellcastingAbility: cls.spellcastingAbility
      })),
      notes: original.notes
    });

    return duplicated;
  }

  // Utility methods

  async searchCharacters(query: string): Promise<Character[]> {
    await this.delay();
    
    const lowerQuery = query.toLowerCase();
    return this.characters.filter(character =>
      character.profile.name.toLowerCase().includes(lowerQuery) ||
      character.profile.race.name.toLowerCase().includes(lowerQuery) ||
      character.classes.some(cls => cls.name.toLowerCase().includes(lowerQuery))
    );
  }

  async getCharactersByClass(className: string): Promise<Character[]> {
    await this.delay();
    
    return this.characters.filter(character =>
      character.classes.some(cls => 
        cls.name.toLowerCase() === className.toLowerCase()
      )
    );
  }

  async getCharactersByRace(raceName: string): Promise<Character[]> {
    await this.delay();
    
    return this.characters.filter(character =>
      character.profile.race.name.toLowerCase() === raceName.toLowerCase()
    );
  }

  async exportCharacters(): Promise<string> {
    await this.delay();
    
    const exportData = {
      version: this.currentVersion,
      exportDate: new Date().toISOString(),
      characters: this.characters
    };
    
    return JSON.stringify(exportData, null, 2);
  }

  async importCharacters(jsonData: string, replaceExisting: boolean = false): Promise<number> {
    await this.delay();
    
    try {
      const importData = JSON.parse(jsonData);
      const importedCharacters = importData.characters || [];
      
      if (replaceExisting) {
        this.characters = [];
      }
      
      let importedCount = 0;
      for (const characterData of importedCharacters) {
        try {
          // Generate new IDs to avoid conflicts
          const character: Character = {
            ...characterData,
            id: this.generateId(),
            classes: characterData.classes.map((cls: any) => ({
              ...cls,
              id: this.generateId()
            })),
            createdAt: new Date(characterData.createdAt),
            updatedAt: new Date()
          };
          
          this.characters.push(character);
          importedCount++;
        } catch (error) {
          console.error('Failed to import character:', characterData.profile?.name, error);
        }
      }
      
      this.saveToStorage();
      return importedCount;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      throw new Error(`Failed to import characters: ${errorMessage}`);
    }
  }

  // Database management

  async clearDatabase(): Promise<void> {
    await this.delay();
    
    this.characters = [];
    this.saveToStorage();
  }

  async getDatabaseStats(): Promise<{
    characterCount: number;
    totalClasses: number;
    averageLevel: number;
    storageSize: string;
    lastUpdated: string;
  }> {
    await this.delay();
    
    const characterCount = this.characters.length;
    const totalClasses = this.characters.reduce((sum, char) => sum + char.classes.length, 0);
    const averageLevel = characterCount > 0 
      ? this.characters.reduce((sum, char) => sum + char.profile.level, 0) / characterCount 
      : 0;
    
    const storageStats = secureStorage.getStats();
    const storageSize = `${(storageStats.totalSize / 1024).toFixed(2)} KB`;
    
    const lastUpdated = this.characters.length > 0
      ? Math.max(...this.characters.map(c => c.updatedAt.getTime()))
      : 0;
    
    return {
      characterCount,
      totalClasses,
      averageLevel: Math.round(averageLevel * 100) / 100,
      storageSize,
      lastUpdated: new Date(lastUpdated).toISOString()
    };
  }
}

// Singleton instance
export const mockDatabase = new MockDatabase(); 