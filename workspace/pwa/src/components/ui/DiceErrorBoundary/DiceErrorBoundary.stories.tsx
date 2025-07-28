import type { Meta, StoryObj } from '@storybook/react';
import { DiceErrorBoundary } from './DiceErrorBoundary';
import { DiceButton } from '../DiceButton';
import { DiceCard, DiceCardBody } from '../DiceCard';
import React from 'react'; // Added missing import for React

const meta = {
  title: 'UI Components/ErrorBoundary',
  component: DiceErrorBoundary,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'A React error boundary component that catches JavaScript errors in child components and displays a fallback UI with optional retry functionality.',
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    fallback: {
      control: false,
      description: 'Custom fallback component to render when error occurs',
    },
    showErrorDetails: {
      control: 'boolean',
      description: 'Show detailed error information (for development)',
    },
    onError: {
      action: 'error-caught',
      description: 'Callback when error is caught',
    },
    children: {
      control: false,
      description: 'Child components to wrap',
    },
  },
} satisfies Meta<typeof DiceErrorBoundary>;

export default meta;
type Story = StoryObj<typeof meta>;

// Component that throws an error
const ErrorComponent = ({ shouldError = false }: { shouldError?: boolean }) => {
  if (shouldError) {
    throw new Error('This is a test error from the ErrorComponent');
  }
  return (
    <DiceCard>
      <DiceCardBody>
        <h3 className="text-lg font-semibold mb-2 text-green-700">✓ No Error</h3>
        <p className="text-gray-600">This component is working normally.</p>
      </DiceCardBody>
    </DiceCard>
  );
};

// Interactive error trigger
const ErrorTrigger = () => {
  const [shouldError, setShouldError] = React.useState(false);

  return (
    <div className="space-y-4">
      <div className="text-center">
        <DiceButton 
          variant={shouldError ? "danger" : "primary"}
          onClick={() => setShouldError(!shouldError)}
        >
          {shouldError ? 'Fix Component' : 'Trigger Error'}
        </DiceButton>
      </div>
      
      <DiceErrorBoundary showErrorDetails={true}>
        <ErrorComponent shouldError={shouldError} />
      </DiceErrorBoundary>
    </div>
  );
};

// Default story
export const Default: Story = {
  args: {},
  render: () => (
    <DiceErrorBoundary>
      <DiceCard>
        <DiceCardBody>
          <h3 className="text-lg font-semibold mb-2">Working Component</h3>
          <p className="text-gray-600">
            This component is wrapped in an ErrorBoundary. If it throws an error, 
            the boundary will catch it and display a fallback UI.
          </p>
        </DiceCardBody>
      </DiceCard>
    </DiceErrorBoundary>
  ),
};

// Interactive error demonstration
export const InteractiveDemo: Story = {
  args: {},
  render: () => <ErrorTrigger />,
  parameters: {
    docs: {
      description: {
        story: 'Click the button to trigger an error and see how the ErrorBoundary handles it.',
      },
    },
  },
};

// With error details (development mode)
export const WithErrorDetails: Story = {
  args: {},
  render: () => (
    <DiceErrorBoundary showErrorDetails={true}>
      <ErrorComponent shouldError={true} />
    </DiceErrorBoundary>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Error boundary with detailed error information enabled (useful for development).',
      },
    },
  },
};

// Custom fallback UI
export const CustomFallback: Story = {
  args: {},
  render: () => (
    <DiceErrorBoundary 
      fallback={
        <DiceCard variant="outlined" className="border-orange-200 bg-orange-50">
          <DiceCardBody>
            <div className="text-center">
              <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-orange-100 mb-4">
                <span className="text-2xl">⚠️</span>
              </div>
              <h3 className="text-lg font-medium text-orange-900 mb-2">
                Character Sheet Error
              </h3>
              <p className="text-sm text-orange-700 mb-4">
                We're having trouble loading your character data. 
                Please try refreshing the page.
              </p>
              <DiceButton 
                variant="outline" 
                className="border-orange-300 text-orange-700 hover:bg-orange-100"
                onClick={() => window.location.reload()}
              >
                Refresh Page
              </DiceButton>
            </div>
          </DiceCardBody>
        </DiceCard>
      }
    >
      <ErrorComponent shouldError={true} />
    </DiceErrorBoundary>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Error boundary with a custom fallback UI tailored to the application context.',
      },
    },
  },
};

// Multiple error boundaries
export const MultipleErrorBoundaries: Story = {
  args: {},
  render: () => (
    <div className="space-y-6 w-full max-w-4xl">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <h3 className="text-lg font-medium mb-3">Working Section</h3>
          <DiceErrorBoundary>
            <DiceCard>
              <DiceCardBody>
                <h4 className="font-semibold mb-2">Character Profile</h4>
                <p className="text-gray-600 text-sm">
                  This section is working correctly and displays character information.
                </p>
              </DiceCardBody>
            </DiceCard>
          </DiceErrorBoundary>
        </div>
        
        <div>
          <h3 className="text-lg font-medium mb-3">Error Section</h3>
          <DiceErrorBoundary showErrorDetails={false}>
            <ErrorComponent shouldError={true} />
          </DiceErrorBoundary>
        </div>
      </div>
      
      <div className="p-4 bg-blue-50 rounded-lg">
        <p className="text-sm text-blue-800">
          <strong>Isolation Benefit:</strong> The error in one section doesn't affect 
          the other sections. Each ErrorBoundary isolates errors to its own subtree.
        </p>
      </div>
    </div>
  ),
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        story: 'Multiple error boundaries isolating different sections of the application.',
      },
    },
  },
};

// D&D specific example
export const DnDCharacterSheet: Story = {
  args: {},
  render: () => {
    const CharacterSection = ({ title, shouldError = false }: { title: string; shouldError?: boolean }) => (
      <DiceErrorBoundary 
        showErrorDetails={false}
        fallback={
          <DiceCard variant="outlined" className="border-red-200 bg-red-50">
            <DiceCardBody>
              <div className="text-center py-4">
                <div className="text-red-600 mb-2">⚠️</div>
                <h4 className="font-medium text-red-900 mb-1">
                  {title} Unavailable
                </h4>
                <p className="text-sm text-red-700">
                  Unable to load this section
                </p>
              </div>
            </DiceCardBody>
          </DiceCard>
        }
      >
        <DiceCard>
          <DiceCardBody>
            <h4 className="font-semibold mb-3">{title}</h4>
            {shouldError ? (
              <ErrorComponent shouldError={true} />
            ) : (
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span>Hit Points</span>
                  <span className="font-medium">42/42</span>
                </div>
                <div className="flex justify-between">
                  <span>Armor Class</span>
                  <span className="font-medium">18</span>
                </div>
                <div className="flex justify-between">
                  <span>Initiative</span>
                  <span className="font-medium">+2</span>
                </div>
              </div>
            )}
          </DiceCardBody>
        </DiceCard>
      </DiceErrorBoundary>
    );

    return (
      <div className="w-full max-w-4xl">
        <div className="mb-6">
          <h2 className="text-2xl font-bold">Thorin Ironforge</h2>
          <p className="text-gray-600">Level 5 Dwarf Fighter</p>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <CharacterSection title="Combat Stats" />
          <CharacterSection title="Ability Scores" shouldError={true} />
          <CharacterSection title="Skills & Saves" />
        </div>
        
        <div className="mt-6 p-4 bg-gray-50 rounded-lg">
          <p className="text-sm text-gray-700">
            <strong>Resilient Design:</strong> Even when the "Ability Scores" section fails to load, 
            the rest of the character sheet remains functional.
          </p>
        </div>
      </div>
    );
  },
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        story: 'Real-world example showing how ErrorBoundary maintains application stability in a D&D character sheet.',
      },
    },
  },
};

// Error logging example
export const ErrorLogging: Story = {
  args: {},
  render: () => (
    <DiceErrorBoundary 
      onError={(error: Error, errorInfo: React.ErrorInfo) => {
        console.error('Error caught by boundary:', error);
        console.error('Error info:', errorInfo);
        // In real app, you might send this to an error tracking service
      }}
      showErrorDetails={true}
    >
      <div className="space-y-4">
        <DiceCard>
          <DiceCardBody>
            <h3 className="text-lg font-semibold mb-2">Error Logging Demo</h3>
            <p className="text-gray-600 mb-4">
              This ErrorBoundary has an onError callback that logs errors. 
              Check the browser console when an error occurs.
            </p>
            <DiceButton onClick={() => {
              throw new Error('Manual error for logging demonstration');
            }}>
              Throw Error
            </DiceButton>
          </DiceCardBody>
        </DiceCard>
      </div>
    </DiceErrorBoundary>
  ),
  parameters: {
    docs: {
      description: {
        story: 'ErrorBoundary with error logging callback for monitoring and debugging.',
      },
    },
  },
}; 