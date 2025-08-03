// Wizard Navigation Component
// Provides step navigation and progress indication for character creation wizard

import React from 'react';
import { DiceButton } from 'ui/atoms';
import { wizardActions } from 'src/lib/state/characterWizardStore';
import { useProxyState } from 'src/lib/state/useProxyState';
import { characterWizardStore } from 'src/lib/state/characterWizardStore';

interface WizardNavigationProps {
  onComplete?: () => void;
  onSave?: () => void;
  className?: string;
}

export const WizardNavigation: React.FC<WizardNavigationProps> = ({
  onComplete,
  onSave,
  className = ''
}) => {
  const [wizardState] = useProxyState(characterWizardStore);

  const { currentStep, steps } = wizardState;
  const isFirstStep = currentStep === 0;
  const isLastStep = currentStep === steps.length - 1;
  const canProceed = wizardActions.canProceedToNextStep();
  const progressPercentage = wizardActions.getProgressPercentage();

  const handleNext = () => {
    if (isLastStep) {
      onComplete?.();
    } else {
      wizardActions.nextStep();
    }
  };

  const handlePrevious = () => {
    wizardActions.previousStep();
  };

  const handleSave = () => {
    onSave?.();
  };

  return (
    <div className={`wizard-navigation ${className}`}>
      {/* Progress Bar */}
      <div className="mb-6">
        <div className="flex justify-between items-center mb-2">
          <span className="text-sm font-medium text-gray-700">
            Step {currentStep + 1} of {steps.length}
          </span>
          <span className="text-sm text-gray-500">
            {Math.round(progressPercentage)}% Complete
          </span>
        </div>
        <div className="w-full bg-gray-200 rounded-full h-2">
          <div
            className="bg-blue-600 h-2 rounded-full transition-all duration-300"
            style={{ width: `${progressPercentage}%` }}
          />
        </div>
      </div>

      {/* Step Indicators */}
      <div className="flex justify-between mb-6">
        {steps.map((step, index) => (
          <div
            key={step.step}
            className={`flex flex-col items-center ${
              index <= currentStep ? 'text-blue-600' : 'text-gray-400'
            }`}
          >
            <div
              className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium border-2 transition-colors ${
                index < currentStep
                  ? 'bg-green-500 border-green-500 text-white'
                  : index === currentStep
                  ? 'bg-blue-600 border-blue-600 text-white'
                  : 'bg-gray-200 border-gray-300 text-gray-500'
              }`}
            >
              {index < currentStep ? '✓' : index + 1}
            </div>
            <span className="text-xs mt-1 text-center max-w-16">
              {step.title}
            </span>
          </div>
        ))}
      </div>

      {/* Navigation Buttons */}
      <div className="flex justify-between items-center">
        <div className="flex gap-2">
          {!isFirstStep && (
            <DiceButton
              variant="outline"
              onClick={handlePrevious}
              leftIcon={<span>←</span>}
            >
              Previous
            </DiceButton>
          )}
          
          <DiceButton
            variant="ghost"
            onClick={handleSave}
            disabled={!wizardActions.isCharacterValid()}
          >
            Save Draft
          </DiceButton>
        </div>

        <div className="flex gap-2">
          <DiceButton
            variant="primary"
            onClick={handleNext}
            disabled={!canProceed}
            rightIcon={isLastStep ? undefined : <span>→</span>}
          >
            {isLastStep ? 'Create Character' : 'Next'}
          </DiceButton>
        </div>
      </div>

      {/* Step Information */}
      <div className="mt-4 p-4 bg-gray-50 rounded-lg">
        <h3 className="font-medium text-gray-900 mb-1">
          {steps[currentStep]?.title}
        </h3>
        <p className="text-sm text-gray-600">
          {steps[currentStep]?.description}
        </p>
        {steps[currentStep]?.completed && (
          <div className="mt-2 flex items-center text-sm text-green-600">
            <span className="mr-1">✓</span>
            Step completed
          </div>
        )}
      </div>
    </div>
  );
};

WizardNavigation.displayName = 'WizardNavigation'; 