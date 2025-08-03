// API Client with Mock/Real Switch
// Provides seamless transition between mock data and real API endpoints
// Supports tRPC integration when backend is ready

import type { Character, CreateCharacterRequest, UpdateCharacterRequest } from 'src/types/character';
import { CharacterTransformers } from './transformers';
import { MockDatabase } from 'src/lib/mockData/MockDatabase';
import { 
  validateCharacter, 
  validateCreateRequest, 
  validateUpdateRequest,
  validateCharacterResponse,
  validateCharactersResponse,
  safeValidateCharacter,
  safeValidateCreateRequest
} from './schema';

export interface ApiResponse<T> {
  data: T;
  success: boolean;
  message?: string;
  errors?: string[];
}

export interface ApiError {
  message: string;
  code?: string;
  details?: any;
}

export class ApiClient {
  private baseUrl: string;
  private useMock: boolean;
  private mockDb: MockDatabase;

  constructor(baseUrl: string, useMock: boolean = true) {
    this.baseUrl = baseUrl;
    this.useMock = useMock;
    this.mockDb = new MockDatabase();
  }

  // Switch between mock and real API
  setUseMock(useMock: boolean): void {
    this.useMock = useMock;
    console.log(`API Client: Switched to ${useMock ? 'mock' : 'real'} mode`);
  }

  // Get current mode
  isUsingMock(): boolean {
    return this.useMock;
  }

  // Character CRUD Operations
  async getCharacters(): Promise<Character[]> {
    if (this.useMock) {
      return this.mockDb.getCharacters();
    }
    
    try {
      const response = await fetch(`${this.baseUrl}/api/characters`);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      const validatedData = validateCharactersResponse(data);
      return validatedData.characters.map(CharacterTransformers.fromApi);
    } catch (error) {
      console.error('Failed to fetch characters:', error);
      throw new Error('Failed to load characters');
    }
  }

  async getCharacter(id: string): Promise<Character | null> {
    if (this.useMock) {
      return this.mockDb.getCharacter(id);
    }
    
    try {
      const response = await fetch(`${this.baseUrl}/api/characters/${id}`);
      if (!response.ok) {
        if (response.status === 404) {
          return null;
        }
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      const validatedData = validateCharacterResponse(data);
      return CharacterTransformers.fromApi(validatedData.character);
    } catch (error) {
      console.error(`Failed to fetch character ${id}:`, error);
      throw new Error('Failed to load character');
    }
  }

  async createCharacter(character: CreateCharacterRequest): Promise<Character> {
    if (this.useMock) {
      return this.mockDb.createCharacter(character);
    }
    
    try {
      // Validate input data
      const validatedRequest = validateCreateRequest(character);
      const payload = CharacterTransformers.fromCreateRequest(validatedRequest);
      
      const response = await fetch(`${this.baseUrl}/api/characters`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      const validatedData = validateCharacterResponse(data);
      return CharacterTransformers.fromApi(validatedData.character);
    } catch (error) {
      console.error('Failed to create character:', error);
      throw new Error('Failed to create character');
    }
  }

  async updateCharacter(id: string, updates: UpdateCharacterRequest): Promise<Character> {
    if (this.useMock) {
      return this.mockDb.updateCharacter(id, updates);
    }
    
    try {
      // Validate input data
      const validatedRequest = validateUpdateRequest(updates);
      const payload = CharacterTransformers.fromUpdateRequest(validatedRequest);
      
      const response = await fetch(`${this.baseUrl}/api/characters/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      const validatedData = validateCharacterResponse(data);
      return CharacterTransformers.fromApi(validatedData.character);
    } catch (error) {
      console.error(`Failed to update character ${id}:`, error);
      throw new Error('Failed to update character');
    }
  }

  async deleteCharacter(id: string): Promise<void> {
    if (this.useMock) {
      return this.mockDb.deleteCharacter(id);
    }
    
    try {
      const response = await fetch(`${this.baseUrl}/api/characters/${id}`, {
        method: 'DELETE'
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
    } catch (error) {
      console.error(`Failed to delete character ${id}:`, error);
      throw new Error('Failed to delete character');
    }
  }

  async duplicateCharacter(id: string, newName?: string): Promise<Character> {
    if (this.useMock) {
      return this.mockDb.duplicateCharacter(id, newName);
    }
    
    try {
      const response = await fetch(`${this.baseUrl}/api/characters/${id}/duplicate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ newName })
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      const validatedData = validateCharacterResponse(data);
      return CharacterTransformers.fromApi(validatedData.character);
    } catch (error) {
      console.error(`Failed to duplicate character ${id}:`, error);
      throw new Error('Failed to duplicate character');
    }
  }

  // Search and Filter Operations
  async searchCharacters(query: string): Promise<Character[]> {
    if (this.useMock) {
      return this.mockDb.searchCharacters(query);
    }
    
    try {
      const response = await fetch(`${this.baseUrl}/api/characters/search?q=${encodeURIComponent(query)}`);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      const validatedData = validateCharactersResponse(data);
      return validatedData.characters.map(CharacterTransformers.fromApi);
    } catch (error) {
      console.error('Failed to search characters:', error);
      throw new Error('Failed to search characters');
    }
  }

  async getCharactersByClass(className: string): Promise<Character[]> {
    if (this.useMock) {
      return this.mockDb.getCharactersByClass(className);
    }
    
    try {
      const response = await fetch(`${this.baseUrl}/api/characters?class=${encodeURIComponent(className)}`);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      const validatedData = validateCharactersResponse(data);
      return validatedData.characters.map(CharacterTransformers.fromApi);
    } catch (error) {
      console.error(`Failed to fetch characters by class ${className}:`, error);
      throw new Error('Failed to load characters by class');
    }
  }

  async getCharactersByRace(raceName: string): Promise<Character[]> {
    if (this.useMock) {
      return this.mockDb.getCharactersByRace(raceName);
    }
    
    try {
      const response = await fetch(`${this.baseUrl}/api/characters?race=${encodeURIComponent(raceName)}`);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      const validatedData = validateCharactersResponse(data);
      return validatedData.characters.map(CharacterTransformers.fromApi);
    } catch (error) {
      console.error(`Failed to fetch characters by race ${raceName}:`, error);
      throw new Error('Failed to load characters by race');
    }
  }

  // Import/Export Operations
  async exportCharacters(): Promise<string> {
    if (this.useMock) {
      return this.mockDb.exportCharacters();
    }
    
    try {
      const response = await fetch(`${this.baseUrl}/api/characters/export`);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      return await response.text();
    } catch (error) {
      console.error('Failed to export characters:', error);
      throw new Error('Failed to export characters');
    }
  }

  async importCharacters(jsonData: string, replaceExisting: boolean = false): Promise<number> {
    if (this.useMock) {
      return this.mockDb.importCharacters(jsonData, replaceExisting);
    }
    
    try {
      const response = await fetch(`${this.baseUrl}/api/characters/import`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ data: jsonData, replaceExisting })
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      return data.importedCount;
    } catch (error) {
      console.error('Failed to import characters:', error);
      throw new Error('Failed to import characters');
    }
  }

  // Database Management
  async clearDatabase(): Promise<void> {
    if (this.useMock) {
      return this.mockDb.clearDatabase();
    }
    
    try {
      const response = await fetch(`${this.baseUrl}/api/characters`, {
        method: 'DELETE'
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
    } catch (error) {
      console.error('Failed to clear database:', error);
      throw new Error('Failed to clear database');
    }
  }

  async getDatabaseStats(): Promise<{
    characterCount: number;
    totalClasses: number;
    averageLevel: number;
    storageSize: string;
    lastUpdated: string;
  }> {
    if (this.useMock) {
      return this.mockDb.getDatabaseStats();
    }
    
    try {
      const response = await fetch(`${this.baseUrl}/api/characters/stats`);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      return await response.json();
    } catch (error) {
      console.error('Failed to get database stats:', error);
      throw new Error('Failed to get database stats');
    }
  }

  // Health Check
  async healthCheck(): Promise<boolean> {
    if (this.useMock) {
      return true; // Mock is always healthy
    }
    
    try {
      const response = await fetch(`${this.baseUrl}/api/health`);
      return response.ok;
    } catch (error) {
      console.error('Health check failed:', error);
      return false;
    }
  }
}

// Default API client instance
export const apiClient = new ApiClient(
  process.env.VITE_API_URL || 'http://localhost:3001',
  process.env.NODE_ENV === 'development'
); 