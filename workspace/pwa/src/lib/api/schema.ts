// Zod Schema Definitions for tRPC Validation
// Provides type-safe validation for API requests and responses
// Ensures data integrity between frontend and backend

import { z } from 'zod';

// Base schemas for reusable components
export const abilityScoresSchema = z.object({
  strength: z.number().min(1).max(20),
  dexterity: z.number().min(1).max(20),
  constitution: z.number().min(1).max(20),
  intelligence: z.number().min(1).max(20),
  wisdom: z.number().min(1).max(20),
  charisma: z.number().min(1).max(20)
});

export const raceSchema = z.object({
  id: z.string(),
  name: z.string(),
  abilityScoreIncrease: z.record(z.string(), z.number()),
  size: z.enum(['Small', 'Medium', 'Large']),
  speed: z.number().min(0),
  languages: z.array(z.string()),
  traits: z.array(z.string()),
  description: z.string()
});

export const alignmentSchema = z.object({
  id: z.string(),
  name: z.string(),
  shortName: z.string(),
  description: z.string()
});

export const characterProfileSchema = z.object({
  name: z.string().min(1, 'Character name is required'),
  race: raceSchema,
  alignment: alignmentSchema,
  level: z.number().min(1).max(20),
  experience: z.number().min(0),
  age: z.number().optional(),
  gender: z.string().optional(),
  height: z.string().optional(),
  weight: z.string().optional(),
  background: z.string().optional()
});

export const characterClassSchema = z.object({
  id: z.string(),
  name: z.string(),
  level: z.number().min(1).max(20),
  hitDie: z.string(),
  primaryAbility: z.array(z.string()),
  savingThrowProficiencies: z.array(z.string()),
  skillProficiencies: z.number(),
  armorProficiencies: z.array(z.string()),
  weaponProficiencies: z.array(z.string()),
  spellcastingAbility: z.string().optional()
});

export const hitPointsSchema = z.object({
  current: z.number(),
  maximum: z.number(),
  temporary: z.number()
});

export const savingThrowsSchema = z.object({
  fortitude: z.number(),
  reflex: z.number(),
  will: z.number()
});

export const combatStatsSchema = z.object({
  hitPoints: hitPointsSchema,
  armorClass: z.number(),
  initiative: z.number(),
  speed: z.number(),
  baseAttackBonus: z.number(),
  savingThrows: savingThrowsSchema
});

export const characterTraitsSchema = z.object({
  racialTraits: z.array(z.string()),
  classAbilities: z.array(z.string()),
  languages: z.array(z.string()),
  feats: z.array(z.string())
});

export const equipmentSchema = z.object({
  id: z.string(),
  name: z.string(),
  type: z.enum(['Weapon', 'Armor', 'Shield', 'Item']),
  category: z.string(),
  damage: z.string().optional(),
  ac: z.string().optional(),
  weight: z.number(),
  cost: z.string(),
  properties: z.array(z.string()),
  equipped: z.boolean(),
  quantity: z.number()
});

export const spellSchema = z.object({
  id: z.string(),
  name: z.string(),
  level: z.number(),
  school: z.string(),
  castingTime: z.string(),
  range: z.string(),
  components: z.array(z.string()),
  duration: z.string(),
  description: z.string(),
  prepared: z.boolean().optional()
});

// Main character schema
export const characterSchema = z.object({
  id: z.string(),
  profile: characterProfileSchema,
  abilities: abilityScoresSchema,
  classes: z.array(characterClassSchema),
  combat: combatStatsSchema,
  traits: characterTraitsSchema,
  equipment: z.array(equipmentSchema),
  spells: z.array(spellSchema).optional(),
  notes: z.string(),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime()
});

// Request schemas
export const createCharacterRequestSchema = z.object({
  profile: characterProfileSchema.omit({ level: true, experience: true }),
  abilities: abilityScoresSchema,
  classes: z.array(characterClassSchema.omit({ id: true })),
  notes: z.string().optional()
});

export const updateCharacterRequestSchema = z.object({
  profile: characterProfileSchema.partial().optional(),
  abilities: abilityScoresSchema.partial().optional(),
  classes: z.array(characterClassSchema).optional(),
  combat: combatStatsSchema.partial().optional(),
  traits: characterTraitsSchema.partial().optional(),
  equipment: z.array(equipmentSchema).optional(),
  spells: z.array(spellSchema).optional(),
  notes: z.string().optional()
});

// Response schemas
export const characterResponseSchema = z.object({
  character: characterSchema
});

export const charactersResponseSchema = z.object({
  characters: z.array(characterSchema)
});

export const apiResponseSchema = z.object({
  success: z.boolean(),
  message: z.string().optional(),
  errors: z.array(z.string()).optional()
});

export const characterApiResponseSchema = apiResponseSchema.extend({
  data: characterSchema
});

export const charactersApiResponseSchema = apiResponseSchema.extend({
  data: z.array(characterSchema)
});

// Search and filter schemas
export const searchRequestSchema = z.object({
  query: z.string().min(1)
});

export const filterRequestSchema = z.object({
  class: z.string().optional(),
  race: z.string().optional(),
  level: z.number().min(1).max(20).optional()
});

// Import/Export schemas
export const importRequestSchema = z.object({
  data: z.string(),
  replaceExisting: z.boolean().default(false)
});

export const importResponseSchema = apiResponseSchema.extend({
  importedCount: z.number()
});

export const databaseStatsSchema = z.object({
  characterCount: z.number(),
  totalClasses: z.number(),
  averageLevel: z.number(),
  storageSize: z.string(),
  lastUpdated: z.string()
});

// Health check schema
export const healthResponseSchema = z.object({
  status: z.enum(['healthy', 'unhealthy']),
  timestamp: z.string().datetime(),
  version: z.string(),
  uptime: z.number()
});

// Type exports for use in application
export type CharacterInput = z.infer<typeof characterSchema>;
export type CreateCharacterInput = z.infer<typeof createCharacterRequestSchema>;
export type UpdateCharacterInput = z.infer<typeof updateCharacterRequestSchema>;
export type CharacterResponse = z.infer<typeof characterResponseSchema>;
export type CharactersResponse = z.infer<typeof charactersResponseSchema>;
export type ApiResponse = z.infer<typeof apiResponseSchema>;
export type CharacterApiResponse = z.infer<typeof characterApiResponseSchema>;
export type CharactersApiResponse = z.infer<typeof charactersApiResponseSchema>;
export type SearchRequest = z.infer<typeof searchRequestSchema>;
export type FilterRequest = z.infer<typeof filterRequestSchema>;
export type ImportRequest = z.infer<typeof importRequestSchema>;
export type ImportResponse = z.infer<typeof importResponseSchema>;
export type DatabaseStats = z.infer<typeof databaseStatsSchema>;
export type HealthResponse = z.infer<typeof healthResponseSchema>;

// Validation helper functions
export const validateCharacter = (data: unknown): CharacterInput => {
  return characterSchema.parse(data);
};

export const validateCreateRequest = (data: unknown): CreateCharacterInput => {
  return createCharacterRequestSchema.parse(data);
};

export const validateUpdateRequest = (data: unknown): UpdateCharacterInput => {
  return updateCharacterRequestSchema.parse(data);
};

export const validateCharacterResponse = (data: unknown): CharacterResponse => {
  return characterResponseSchema.parse(data);
};

export const validateCharactersResponse = (data: unknown): CharactersResponse => {
  return charactersResponseSchema.parse(data);
};

// Safe validation that returns null on error
export const safeValidateCharacter = (data: unknown): CharacterInput | null => {
  try {
    return characterSchema.parse(data);
  } catch {
    return null;
  }
};

export const safeValidateCreateRequest = (data: unknown): CreateCharacterInput | null => {
  try {
    return createCharacterRequestSchema.parse(data);
  } catch {
    return null;
  }
}; 