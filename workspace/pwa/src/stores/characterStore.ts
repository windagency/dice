// Character Store using JavaScript Proxy State Management
// Provides character CRUD operations and state management
// Uses native Proxy implementation without external dependencies

import { ProxyStateManager } from 'src/lib/state/ProxyStateManager';
import { useProxyState, useProxySelector } from 'src/lib/state/useProxyState';
import { mockDatabase } from 'src/lib/mockData/MockDatabase';
import { dndCalculations } from 'src/lib/calculations/DnDCalculations';
import type { 
  Character, 
  CreateCharacterRequest, 
  UpdateCharacterRequest,
  DerivedStats 
} from 'src/types/character';

// Character store state interface
interface CharacterState {
  characters: Character[];
  currentCharacter: Character | null;
  loading: boolean;
  error: string | null;
  searchQuery: string;
  selectedCharacterIds: string[];
  lastOperation: string | null;
}

// Initial state
const initialCharacterState: CharacterState = {
  characters: [],
  currentCharacter: null,
  loading: false,
  error: null,
  searchQuery: '',
  selectedCharacterIds: [],
  lastOperation: null,
};

// Create the character state manager
const characterStateManager = new ProxyStateManager(initialCharacterState);

// Character store actions
export const characterActions = {
  // Loading operations
  async loadCharacters(): Promise<void> {
    characterStateManager.setState(state => {
      state.loading = true;
      state.error = null;
      state.lastOperation = 'loadCharacters';
    });

    try {
      const characters = await mockDatabase.getCharacters();
      characterStateManager.setState(state => {
        state.characters = characters;
        state.loading = false;
      });
    } catch (error) {
      characterStateManager.setState(state => {
        state.error = error instanceof Error ? error.message : 'Failed to load characters';
        state.loading = false;
      });
    }
  },

  async loadCharacter(id: string): Promise<void> {
    characterStateManager.setState(state => {
      state.loading = true;
      state.error = null;
      state.lastOperation = 'loadCharacter';
    });

    try {
      const character = await mockDatabase.getCharacter(id);
      characterStateManager.setState(state => {
        state.currentCharacter = character;
        state.loading = false;
      });
    } catch (error) {
      characterStateManager.setState(state => {
        state.error = error instanceof Error ? error.message : 'Failed to load character';
        state.loading = false;
      });
    }
  },

  // CRUD operations
  async createCharacter(characterData: CreateCharacterRequest): Promise<string | null> {
    characterStateManager.setState(state => {
      state.loading = true;
      state.error = null;
      state.lastOperation = 'createCharacter';
    });

    try {
      const newCharacter = await mockDatabase.createCharacter(characterData);
      
      // Calculate derived stats for the new character
      const derivedStats = dndCalculations.calculateDerivedStats(newCharacter);
      const updatedCharacter = {
        ...newCharacter,
        combat: {
          ...newCharacter.combat,
          hitPoints: {
            ...newCharacter.combat.hitPoints,
            maximum: derivedStats.hitPoints,
            current: derivedStats.hitPoints
          },
          armorClass: derivedStats.armorClass,
          initiative: derivedStats.initiative,
          baseAttackBonus: derivedStats.baseAttackBonus,
          savingThrows: derivedStats.savingThrows
        }
      };

      // Update the character with calculated stats
      await mockDatabase.updateCharacter(newCharacter.id, updatedCharacter);

      characterStateManager.setState(state => {
        state.characters.unshift(updatedCharacter);
        state.currentCharacter = updatedCharacter;
        state.loading = false;
      });

      return newCharacter.id;
    } catch (error) {
      characterStateManager.setState(state => {
        state.error = error instanceof Error ? error.message : 'Failed to create character';
        state.loading = false;
      });
      return null;
    }
  },

  async updateCharacter(id: string, updates: UpdateCharacterRequest): Promise<void> {
    characterStateManager.setState(state => {
      state.loading = true;
      state.error = null;
      state.lastOperation = 'updateCharacter';
    });

    try {
      const updatedCharacter = await mockDatabase.updateCharacter(id, updates);
      
      // Recalculate derived stats if abilities or classes changed
      if (updates.abilities || updates.classes) {
        const derivedStats = dndCalculations.calculateDerivedStats(updatedCharacter);
        await mockDatabase.updateCharacter(id, {
          combat: {
            ...updatedCharacter.combat,
            hitPoints: {
              ...updatedCharacter.combat.hitPoints,
              maximum: derivedStats.hitPoints
            },
            armorClass: derivedStats.armorClass,
            initiative: derivedStats.initiative,
            baseAttackBonus: derivedStats.baseAttackBonus,
            savingThrows: derivedStats.savingThrows
          }
        });
      }

      characterStateManager.setState(state => {
        const index = state.characters.findIndex(c => c.id === id);
        if (index !== -1) {
          state.characters[index] = updatedCharacter;
        }
        if (state.currentCharacter?.id === id) {
          state.currentCharacter = updatedCharacter;
        }
        state.loading = false;
      });
    } catch (error) {
      characterStateManager.setState(state => {
        state.error = error instanceof Error ? error.message : 'Failed to update character';
        state.loading = false;
      });
    }
  },

  async deleteCharacter(id: string): Promise<void> {
    characterStateManager.setState(state => {
      state.loading = true;
      state.error = null;
      state.lastOperation = 'deleteCharacter';
    });

    try {
      await mockDatabase.deleteCharacter(id);
      characterStateManager.setState(state => {
        state.characters = state.characters.filter(c => c.id !== id);
        if (state.currentCharacter?.id === id) {
          state.currentCharacter = null;
        }
        state.selectedCharacterIds = state.selectedCharacterIds.filter(selectedId => selectedId !== id);
        state.loading = false;
      });
    } catch (error) {
      characterStateManager.setState(state => {
        state.error = error instanceof Error ? error.message : 'Failed to delete character';
        state.loading = false;
      });
    }
  },

  async duplicateCharacter(id: string, newName?: string): Promise<void> {
    characterStateManager.setState(state => {
      state.loading = true;
      state.error = null;
      state.lastOperation = 'duplicateCharacter';
    });

    try {
      const duplicatedCharacter = await mockDatabase.duplicateCharacter(id, newName);
      characterStateManager.setState(state => {
        state.characters.unshift(duplicatedCharacter);
        state.loading = false;
      });
    } catch (error) {
      characterStateManager.setState(state => {
        state.error = error instanceof Error ? error.message : 'Failed to duplicate character';
        state.loading = false;
      });
    }
  },

  // UI operations
  setCurrentCharacter(character: Character | null): void {
    characterStateManager.setState(state => {
      state.currentCharacter = character;
    });
  },

  setSearchQuery(query: string): void {
    characterStateManager.setState(state => {
      state.searchQuery = query;
    });
  },

  toggleCharacterSelection(id: string): void {
    characterStateManager.setState(state => {
      const index = state.selectedCharacterIds.indexOf(id);
      if (index === -1) {
        state.selectedCharacterIds.push(id);
      } else {
        state.selectedCharacterIds.splice(index, 1);
      }
    });
  },

  clearSelection(): void {
    characterStateManager.setState(state => {
      state.selectedCharacterIds = [];
    });
  },

  clearError(): void {
    characterStateManager.setState(state => {
      state.error = null;
    });
  },

  // Search operations
  async searchCharacters(query: string): Promise<void> {
    characterStateManager.setState(state => {
      state.loading = true;
      state.error = null;
      state.searchQuery = query;
      state.lastOperation = 'searchCharacters';
    });

    try {
      const results = await mockDatabase.searchCharacters(query);
      characterStateManager.setState(state => {
        state.characters = results;
        state.loading = false;
      });
    } catch (error) {
      characterStateManager.setState(state => {
        state.error = error instanceof Error ? error.message : 'Failed to search characters';
        state.loading = false;
      });
    }
  },

  // Import/Export operations
  async exportCharacters(): Promise<string | null> {
    characterStateManager.setState(state => {
      state.loading = true;
      state.error = null;
      state.lastOperation = 'exportCharacters';
    });

    try {
      const exportData = await mockDatabase.exportCharacters();
      characterStateManager.setState(state => {
        state.loading = false;
      });
      return exportData;
    } catch (error) {
      characterStateManager.setState(state => {
        state.error = error instanceof Error ? error.message : 'Failed to export characters';
        state.loading = false;
      });
      return null;
    }
  },

  async importCharacters(jsonData: string, replaceExisting: boolean = false): Promise<number | null> {
    characterStateManager.setState(state => {
      state.loading = true;
      state.error = null;
      state.lastOperation = 'importCharacters';
    });

    try {
      const importedCount = await mockDatabase.importCharacters(jsonData, replaceExisting);
      
      // Reload characters after import
      const characters = await mockDatabase.getCharacters();
      characterStateManager.setState(state => {
        state.characters = characters;
        state.loading = false;
      });

      return importedCount;
    } catch (error) {
      characterStateManager.setState(state => {
        state.error = error instanceof Error ? error.message : 'Failed to import characters';
        state.loading = false;
      });
      return null;
    }
  }
};

// React hooks for components
export function useCharacterStore() {
  return useProxyState(characterStateManager);
}

export function useCharacters() {
  return useProxySelector(
    characterStateManager,
    state => state.characters
  );
}

export function useCurrentCharacter() {
  return useProxySelector(
    characterStateManager,
    state => state.currentCharacter
  );
}

export function useCharacterLoading() {
  return useProxySelector(
    characterStateManager,
    state => state.loading
  );
}

export function useCharacterError() {
  return useProxySelector(
    characterStateManager,
    state => state.error
  );
}

export function useCharacterSearch() {
  return useProxySelector(
    characterStateManager,
    state => ({
      query: state.searchQuery,
      results: state.characters
    })
  );
}

export function useSelectedCharacters() {
  return useProxySelector(
    characterStateManager,
    state => ({
      selectedIds: state.selectedCharacterIds,
      selectedCharacters: state.characters.filter(c => 
        state.selectedCharacterIds.includes(c.id)
      )
    })
  );
}

// Computed values
export function useFilteredCharacters() {
  return useProxySelector(
    characterStateManager,
    state => {
      if (!state.searchQuery) return state.characters;
      
      const query = state.searchQuery.toLowerCase();
      return state.characters.filter(character =>
        character.profile.name.toLowerCase().includes(query) ||
        character.profile.race.name.toLowerCase().includes(query) ||
        character.classes.some(cls => cls.name.toLowerCase().includes(query))
      );
    }
  );
}

export function useCharacterStats() {
  return useProxySelector(
    characterStateManager,
    state => {
      const total = state.characters.length;
      const avgLevel = total > 0 
        ? state.characters.reduce((sum, char) => sum + char.profile.level, 0) / total 
        : 0;
      
      const classCounts = state.characters.reduce((counts, char) => {
        char.classes.forEach(cls => {
          counts[cls.name] = (counts[cls.name] || 0) + 1;
        });
        return counts;
      }, {} as Record<string, number>);

      const raceCounts = state.characters.reduce((counts, char) => {
        const raceName = char.profile.race.name;
        counts[raceName] = (counts[raceName] || 0) + 1;
        return counts;
      }, {} as Record<string, number>);

      return {
        totalCharacters: total,
        averageLevel: Math.round(avgLevel * 100) / 100,
        classCounts,
        raceCounts
      };
    }
  );
}

// Export the state manager for advanced usage
export { characterStateManager }; 