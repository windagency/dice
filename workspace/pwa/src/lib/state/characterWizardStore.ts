// Character Wizard State Management
// Manages the multi-step character creation process
// Uses ProxyStateManager for reactive state updates

import type { Character, CharacterFormStep, CharacterCreationWizardState } from 'src/types/character';
import { ProxyStateManager } from './ProxyStateManager';

// Wizard step definitions
const WIZARD_STEPS: CharacterFormStep[] = [
  {
    step: 0,
    title: 'Profile',
    description: 'Basic character information',
    completed: false,
    data: {}
  },
  {
    step: 1,
    title: 'Class & Abilities',
    description: 'Choose class and assign ability scores',
    completed: false,
    data: {}
  },
  {
    step: 2,
    title: 'Combat Stats',
    description: 'Calculate derived combat statistics',
    completed: false,
    data: {}
  },
  {
    step: 3,
    title: 'Traits & Abilities',
    description: 'Review racial and class abilities',
    completed: false,
    data: {}
  }
];

// Initial wizard state
const initialWizardState: CharacterCreationWizardState = {
  currentStep: 0,
  steps: WIZARD_STEPS,
  character: {},
  isDraft: true,
  lastSaved: null
};

// Create wizard state manager
export const characterWizardStore = new ProxyStateManager<CharacterCreationWizardState>(initialWizardState);

// Wizard state actions
export const wizardActions = {
  // Navigation
  nextStep: () => {
    characterWizardStore.setState(state => {
      if (state.currentStep < state.steps.length - 1) {
        return {
          ...state,
          currentStep: state.currentStep + 1
        };
      }
      return state;
    });
  },

  previousStep: () => {
    characterWizardStore.setState(state => {
      if (state.currentStep > 0) {
        return {
          ...state,
          currentStep: state.currentStep - 1
        };
      }
      return state;
    });
  },

  goToStep: (step: number) => {
    characterWizardStore.setState(state => {
      if (step >= 0 && step < state.steps.length) {
        return {
          ...state,
          currentStep: step
        };
      }
      return state;
    });
  },

  // Character data updates
  updateCharacter: (updates: Partial<Character>) => {
    characterWizardStore.setState(state => ({
      ...state,
      character: {
        ...state.character,
        ...updates
      },
      lastSaved: new Date()
    }));
  },

  updateStepData: (stepIndex: number, data: any) => {
    characterWizardStore.setState(state => {
      const updatedSteps = [...state.steps];
      if (updatedSteps[stepIndex]) {
        updatedSteps[stepIndex] = {
          ...updatedSteps[stepIndex],
          data,
          completed: true
        };
      }
      return {
        ...state,
        steps: updatedSteps
      };
    });
  },

  // Step completion
  markStepCompleted: (stepIndex: number) => {
    characterWizardStore.setState(state => {
      const updatedSteps = [...state.steps];
      if (updatedSteps[stepIndex]) {
        updatedSteps[stepIndex] = {
          ...updatedSteps[stepIndex],
          completed: true
        };
      }
      return {
        ...state,
        steps: updatedSteps
      };
    });
  },

  markStepIncomplete: (stepIndex: number) => {
    characterWizardStore.setState(state => {
      const updatedSteps = [...state.steps];
      if (updatedSteps[stepIndex]) {
        updatedSteps[stepIndex] = {
          ...updatedSteps[stepIndex],
          completed: false
        };
      }
      return {
        ...state,
        steps: updatedSteps
      };
    });
  },

  // Draft management
  setDraftStatus: (isDraft: boolean) => {
    characterWizardStore.setState(state => ({
      ...state,
      isDraft
    }));
  },

  // Reset wizard
  resetWizard: () => {
    characterWizardStore.setState(initialWizardState);
  },

  // Validation helpers
  canProceedToNextStep: () => {
    const state = characterWizardStore.getState();
    const currentStep = state.steps[state.currentStep];
    return currentStep?.completed || false;
  },

  canGoToStep: (stepIndex: number) => {
    const state = characterWizardStore.getState();
    // Can go to any previous step or current step
    if (stepIndex <= state.currentStep) return true;
    
    // Can go to next step only if current step is completed
    if (stepIndex === state.currentStep + 1) {
      return state.steps[state.currentStep]?.completed || false;
    }
    
    // Can go to future steps only if all previous steps are completed
    for (let i = 0; i < stepIndex; i++) {
      if (!state.steps[i]?.completed) return false;
    }
    return true;
  },

  getCompletedStepsCount: () => {
    const state = characterWizardStore.getState();
    return state.steps.filter(step => step.completed).length;
  },

  getProgressPercentage: () => {
    const state = characterWizardStore.getState();
    const completedSteps = state.steps.filter(step => step.completed).length;
    return (completedSteps / state.steps.length) * 100;
  },

  // Character validation
  isCharacterValid: () => {
    const state = characterWizardStore.getState();
    const { character } = state;
    
    // Basic validation checks
    if (!character.profile?.name) return false;
    if (!character.profile?.race) return false;
    if (!character.profile?.alignment) return false;
    if (!character.abilities) return false;
    if (!character.classes || character.classes.length === 0) return false;
    
    return true;
  },

  // Get current step data
  getCurrentStepData: () => {
    const state = characterWizardStore.getState();
    return state.steps[state.currentStep]?.data || {};
  },

  // Get all step data
  getAllStepData: () => {
    const state = characterWizardStore.getState();
    return state.steps.reduce((acc, step) => {
      acc[step.step] = step.data;
      return acc;
    }, {} as Record<number, any>);
  }
};

// Export wizard store for direct access
export { characterWizardStore as wizardStore }; 