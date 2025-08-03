// Profile Step Component
// First step of character creation wizard - basic character information

import React, { useState, useEffect } from 'react';
import { DiceInput } from 'ui/atoms';
import { DiceCard, DiceCardBody } from 'ui/molecules';
import { wizardActions } from 'src/lib/state/characterWizardStore';
import { useProxyState } from 'src/lib/state/useProxyState';
import { characterWizardStore } from 'src/lib/state/characterWizardStore';
import { races, alignments, getRaceById, getAlignmentById } from 'src/data/dndData';
import type { CharacterProfile } from 'src/types/character';

interface ProfileStepProps {
  className?: string;
}

export const ProfileStep: React.FC<ProfileStepProps> = ({ className = '' }) => {
  const [wizardState] = useProxyState(characterWizardStore);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [formData, setFormData] = useState<Partial<CharacterProfile>>({
    name: '',
    age: undefined,
    gender: '',
    height: '',
    weight: '',
    background: ''
  });

  // Load existing data if available
  useEffect(() => {
    if (wizardState.character.profile) {
      setFormData(wizardState.character.profile);
    }
  }, [wizardState.character.profile]);

  // Validate form data
  const validateForm = (): boolean => {
    const newErrors: Record<string, string> = {};

    if (!formData.name?.trim()) {
      newErrors.name = 'Character name is required';
    }

    if (!formData.race) {
      newErrors.race = 'Please select a race';
    }

    if (!formData.alignment) {
      newErrors.alignment = 'Please select an alignment';
    }

    if (formData.age !== undefined && (formData.age < 0 || formData.age > 1000)) {
      newErrors.age = 'Age must be between 0 and 1000';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  // Handle form field changes
  const handleFieldChange = (field: keyof CharacterProfile, value: any) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));

    // Clear error when user starts typing
    if (errors[field]) {
      setErrors(prev => ({
        ...prev,
        [field]: ''
      }));
    }
  };

  // Handle race selection
  const handleRaceChange = (raceId: string) => {
    const race = getRaceById(raceId);
    if (race) {
      handleFieldChange('race', race);
      // Auto-set level to 1 for new characters
      handleFieldChange('level', 1);
      handleFieldChange('experience', 0);
    }
  };

  // Handle alignment selection
  const handleAlignmentChange = (alignmentId: string) => {
    const alignment = getAlignmentById(alignmentId);
    if (alignment) {
      handleFieldChange('alignment', alignment);
    }
  };

  // Save step data
  const saveStepData = () => {
    if (validateForm()) {
      wizardActions.updateCharacter({ profile: formData as CharacterProfile });
      wizardActions.markStepCompleted(0);
      wizardActions.updateStepData(0, formData);
    }
  };

  // Auto-save on form changes
  useEffect(() => {
    const timeoutId = setTimeout(() => {
      if (formData.name && formData.race && formData.alignment) {
        saveStepData();
      }
    }, 1000);

    return () => clearTimeout(timeoutId);
  }, [formData]);

  return (
    <div className={`profile-step ${className}`}>
      <DiceCard>
        <DiceCardBody>
          <h2 className="text-2xl font-bold mb-6">Character Profile</h2>
          
          <div className="space-y-6">
            {/* Character Name */}
            <DiceInput
              label="Character Name"
              value={formData.name || ''}
              onChange={(e) => handleFieldChange('name', e.target.value)}
              errorMessage={errors.name}
              isRequired
              placeholder="Enter character name..."
            />

            {/* Race and Alignment Selection */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Race <span className="text-red-500">*</span>
                </label>
                <select
                  value={formData.race?.id || ''}
                  onChange={(e) => handleRaceChange(e.target.value)}
                  className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                    errors.race ? 'border-red-500' : 'border-gray-300'
                  }`}
                >
                  <option value="">Select a race...</option>
                  {races.map(race => (
                    <option key={race.id} value={race.id}>
                      {race.name}
                    </option>
                  ))}
                </select>
                {errors.race && (
                  <p className="mt-1 text-sm text-red-600">{errors.race}</p>
                )}
                {formData.race && (
                  <p className="mt-1 text-sm text-gray-600">
                    {formData.race.description}
                  </p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Alignment <span className="text-red-500">*</span>
                </label>
                <select
                  value={formData.alignment?.id || ''}
                  onChange={(e) => handleAlignmentChange(e.target.value)}
                  className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                    errors.alignment ? 'border-red-500' : 'border-gray-300'
                  }`}
                >
                  <option value="">Select an alignment...</option>
                  {alignments.map(alignment => (
                    <option key={alignment.id} value={alignment.id}>
                      {alignment.name}
                    </option>
                  ))}
                </select>
                {errors.alignment && (
                  <p className="mt-1 text-sm text-red-600">{errors.alignment}</p>
                )}
                {formData.alignment && (
                  <p className="mt-1 text-sm text-gray-600">
                    {formData.alignment.description}
                  </p>
                )}
              </div>
            </div>

            {/* Optional Character Details */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <DiceInput
                label="Age"
                type="number"
                value={formData.age?.toString() || ''}
                onChange={(e) => handleFieldChange('age', e.target.value ? parseInt(e.target.value) : undefined)}
                errorMessage={errors.age}
                placeholder="Age in years..."
              />

              <DiceInput
                label="Gender"
                value={formData.gender || ''}
                onChange={(e) => handleFieldChange('gender', e.target.value)}
                placeholder="Gender..."
              />

              <DiceInput
                label="Height"
                value={formData.height || ''}
                onChange={(e) => handleFieldChange('height', e.target.value)}
                placeholder="Height..."
              />
            </div>

            <DiceInput
              label="Weight"
              value={formData.weight || ''}
              onChange={(e) => handleFieldChange('weight', e.target.value)}
              placeholder="Weight..."
            />

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Background
              </label>
              <textarea
                value={formData.background || ''}
                onChange={(e) => handleFieldChange('background', e.target.value)}
                rows={4}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Describe your character's background, personality, or notable features..."
              />
            </div>
          </div>

          {/* Race Information Display */}
          {formData.race && (
            <div className="mt-6 p-4 bg-blue-50 rounded-lg">
              <h3 className="font-medium text-blue-900 mb-2">
                {formData.race.name} Traits
              </h3>
              <div className="space-y-1 text-sm text-blue-800">
                <div><strong>Size:</strong> {formData.race.size}</div>
                <div><strong>Speed:</strong> {formData.race.speed} feet</div>
                <div><strong>Languages:</strong> {formData.race.languages.join(', ')}</div>
                {formData.race.traits.length > 0 && (
                  <div><strong>Traits:</strong> {formData.race.traits.join(', ')}</div>
                )}
              </div>
            </div>
          )}
        </DiceCardBody>
      </DiceCard>
    </div>
  );
};

ProfileStep.displayName = 'ProfileStep'; 