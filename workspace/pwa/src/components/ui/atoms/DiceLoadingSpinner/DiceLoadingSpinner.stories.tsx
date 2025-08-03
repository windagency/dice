import type { Meta, StoryObj } from '@storybook/react';
import { DiceLoadingSpinner } from './DiceLoadingSpinner';
import { DiceButton } from 'ui/atoms/DiceButton';
import { DiceCard, DiceCardBody } from 'ui/molecules/DiceCard';

const meta = {
  title: 'UI Components/LoadingSpinner',
  component: DiceLoadingSpinner,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'A simple, accessible loading spinner component with multiple sizes and color variants. Perfect for indicating loading states throughout the application.',
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    size: {
      control: 'select',
      options: ['xs', 'sm', 'md', 'lg', 'xl'],
      description: 'Size of the spinner',
    },
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'white'],
      description: 'Color variant of the spinner',
    },
    label: {
      control: 'text',
      description: 'Accessibility label for screen readers',
    },
    className: {
      control: 'text',
      description: 'Additional CSS classes',
    },
  },
} satisfies Meta<typeof DiceLoadingSpinner>;

export default meta;
type Story = StoryObj<typeof meta>;

// Default story
export const Default: Story = {
  args: {
    size: 'md',
    variant: 'primary',
  },
};

// All sizes
export const Sizes: Story = {
  render: () => (
    <div className="flex items-center gap-8">
      <div className="text-center">
        <DiceLoadingSpinner size="xs" />
        <p className="text-xs mt-2 text-gray-600">XS (12px)</p>
      </div>
      <div className="text-center">
        <DiceLoadingSpinner size="sm" />
        <p className="text-xs mt-2 text-gray-600">SM (16px)</p>
      </div>
      <div className="text-center">
        <DiceLoadingSpinner size="md" />
        <p className="text-xs mt-2 text-gray-600">MD (24px)</p>
      </div>
      <div className="text-center">
        <DiceLoadingSpinner size="lg" />
        <p className="text-xs mt-2 text-gray-600">LG (32px)</p>
      </div>
      <div className="text-center">
        <DiceLoadingSpinner size="xl" />
        <p className="text-xs mt-2 text-gray-600">XL (48px)</p>
      </div>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Loading spinners in all available sizes from xs to xl.',
      },
    },
  },
};

// All variants
export const Variants: Story = {
  render: () => (
    <div className="flex items-center gap-8">
      <div className="text-center">
        <DiceLoadingSpinner variant="primary" />
        <p className="text-xs mt-2 text-gray-600">Primary</p>
      </div>
      <div className="text-center">
        <DiceLoadingSpinner variant="secondary" />
        <p className="text-xs mt-2 text-gray-600">Secondary</p>
      </div>
      <div className="text-center bg-gray-800 p-4 rounded">
        <DiceLoadingSpinner variant="white" />
        <p className="text-xs mt-2 text-white">White</p>
      </div>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Loading spinners in different color variants.',
      },
    },
  },
};

// In buttons
export const InButtons: Story = {
  render: () => (
    <div className="flex gap-4">
      <DiceButton isLoading>
        Loading...
      </DiceButton>
      <DiceButton variant="secondary" isLoading>
        Processing
      </DiceButton>
      <DiceButton variant="outline" isLoading>
        Saving
      </DiceButton>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Loading spinners integrated into buttons (handled automatically by Button component).',
      },
    },
  },
};

// In cards
export const InCards: Story = {
  render: () => (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-4xl">
      <DiceCard>
        <DiceCardBody>
          <div className="text-center py-8">
            <DiceLoadingSpinner size="lg" />
            <p className="mt-4 text-gray-600">Loading character data...</p>
          </div>
        </DiceCardBody>
      </DiceCard>
      
      <DiceCard>
        <DiceCardBody>
          <div className="flex items-center gap-3 mb-4">
            <DiceLoadingSpinner size="sm" />
            <span className="text-gray-600">Updating inventory...</span>
          </div>
          <div className="space-y-2">
            <div className="h-4 bg-gray-200 rounded animate-pulse"></div>
            <div className="h-4 bg-gray-200 rounded animate-pulse w-3/4"></div>
            <div className="h-4 bg-gray-200 rounded animate-pulse w-1/2"></div>
          </div>
        </DiceCardBody>
      </DiceCard>
    </div>
  ),
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        story: 'Loading spinners used in card layouts for different loading scenarios.',
      },
    },
  },
};

// Inline with text
export const InlineWithText: Story = {
  render: () => (
    <div className="space-y-4 max-w-md">
      <div className="flex items-center gap-2">
        <DiceLoadingSpinner size="xs" />
        <span className="text-sm text-gray-600">Loading dice roll results...</span>
      </div>
      
      <div className="flex items-center gap-2">
        <DiceLoadingSpinner size="sm" />
        <span className="text-gray-600">Calculating ability modifiers...</span>
      </div>
      
      <div className="flex items-center gap-3 p-4 bg-blue-50 rounded-lg">
        <DiceLoadingSpinner size="md" />
        <div>
          <div className="font-medium text-blue-900">Saving character sheet</div>
          <div className="text-sm text-blue-700">Please wait while we update your progress...</div>
        </div>
      </div>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Loading spinners used inline with text for contextual loading messages.',
      },
    },
  },
};

// Custom styling
export const CustomStyling: Story = {
  render: () => (
    <div className="flex gap-6">
      <div className="text-center">
        <DiceLoadingSpinner 
          size="lg" 
          variant="primary" 
          className="text-green-500" 
        />
        <p className="text-xs mt-2 text-gray-600">Custom Green</p>
      </div>
      
      <div className="text-center">
        <DiceLoadingSpinner 
          size="lg" 
          variant="primary" 
          className="text-purple-500" 
        />
        <p className="text-xs mt-2 text-gray-600">Custom Purple</p>
      </div>
      
      <div className="text-center">
        <DiceLoadingSpinner 
          size="lg" 
          variant="primary" 
          className="text-orange-500" 
        />
        <p className="text-xs mt-2 text-gray-600">Custom Orange</p>
      </div>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Loading spinners with custom colors using className overrides.',
      },
    },
  },
};

// Accessibility example
export const Accessibility: Story = {
  render: () => (
    <div className="space-y-6 max-w-md">
      <div>
        <h3 className="text-lg font-medium mb-3">Proper Accessibility Labels</h3>
        <div className="space-y-3">
          <div className="flex items-center gap-3">
            <DiceLoadingSpinner size="sm" label="Loading character list" />
            <span className="text-gray-600">Loading character list...</span>
          </div>
          
          <div className="flex items-center gap-3">
            <DiceLoadingSpinner size="sm" label="Saving character changes" />
            <span className="text-gray-600">Saving changes...</span>
          </div>
          
          <div className="flex items-center gap-3">
            <DiceLoadingSpinner size="sm" label="Rolling dice" />
            <span className="text-gray-600">Rolling dice...</span>
          </div>
        </div>
      </div>
      
      <div className="p-4 bg-blue-50 rounded-lg">
        <p className="text-sm text-blue-800">
          <strong>Screen Reader:</strong> Each spinner has a proper aria-label and role="status" 
          for screen reader accessibility. The label is also visually hidden but announced 
          to assistive technologies.
        </p>
      </div>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Examples showing proper accessibility implementation with descriptive labels.',
      },
    },
  },
}; 