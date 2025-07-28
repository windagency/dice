import type { Meta, StoryObj } from '@storybook/react';
import { DiceCard, DiceCardHeader, DiceCardBody, DiceCardFooter } from './DiceCard';
import { DiceButton } from '../DiceButton';

const meta = {
  title: 'UI Components/Card',
  component: DiceCard,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'A flexible card component with multiple variants and modular sections. Perfect for displaying grouped content with consistent styling.',
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['default', 'elevated', 'outlined', 'flat'],
      description: 'Visual style variant of the card',
    },
    padding: {
      control: 'select',
      options: ['none', 'sm', 'md', 'lg'],
      description: 'Internal padding of the card',
    },
    className: {
      control: 'text',
      description: 'Additional CSS classes',
    },
    children: {
      control: false,
      description: 'Card content',
    },
  },
} satisfies Meta<typeof DiceCard>;

export default meta;
type Story = StoryObj<typeof meta>;

// Default story
export const Default: Story = {
  args: {
    children: (
      <DiceCardBody>
        <h3 className="text-lg font-semibold mb-2">Card Title</h3>
        <p className="text-gray-600">This is a basic card with default styling and content.</p>
      </DiceCardBody>
    ),
  },
};

// Variant stories
export const Variants: Story = {
  render: () => (
    <div className="grid grid-cols-2 gap-4 w-full max-w-4xl">
      <DiceCard variant="default">
        <DiceCardBody>
          <h4 className="font-medium mb-2">Default Card</h4>
          <p className="text-gray-600 text-sm">Shadow and border styling</p>
        </DiceCardBody>
      </DiceCard>
      
      <DiceCard variant="elevated">
        <DiceCardBody>
          <h4 className="font-medium mb-2">Elevated Card</h4>
          <p className="text-gray-600 text-sm">Stronger shadow for emphasis</p>
        </DiceCardBody>
      </DiceCard>
      
      <DiceCard variant="outlined">
        <DiceCardBody>
          <h4 className="font-medium mb-2">Outlined Card</h4>
          <p className="text-gray-600 text-sm">Prominent border styling</p>
        </DiceCardBody>
      </DiceCard>
      
      <DiceCard variant="flat">
        <DiceCardBody>
          <h4 className="font-medium mb-2">Flat Card</h4>
          <p className="text-gray-600 text-sm">No shadow or border</p>
        </DiceCardBody>
      </DiceCard>
    </div>
  ),
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        story: 'All card variants: default, elevated, outlined, and flat.',
      },
    },
  },
};

// Padding variations
export const PaddingVariations: Story = {
  render: () => (
    <div className="grid grid-cols-2 gap-4 w-full max-w-4xl">
      <DiceCard padding="none" className="border">
        <div className="p-2 bg-blue-50 text-blue-800 text-sm">No Padding</div>
        <DiceCardBody>Content flows to edges</DiceCardBody>
      </DiceCard>
      
      <DiceCard padding="sm">
        <DiceCardBody>
          <h4 className="font-medium mb-2">Small Padding</h4>
          <p className="text-gray-600 text-sm">Compact spacing</p>
        </DiceCardBody>
      </DiceCard>
      
      <DiceCard padding="md">
        <DiceCardBody>
          <h4 className="font-medium mb-2">Medium Padding</h4>
          <p className="text-gray-600 text-sm">Default comfortable spacing</p>
        </DiceCardBody>
      </DiceCard>
      
      <DiceCard padding="lg">
        <DiceCardBody>
          <h4 className="font-medium mb-2">Large Padding</h4>
          <p className="text-gray-600 text-sm">Generous spacing</p>
        </DiceCardBody>
      </DiceCard>
    </div>
  ),
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        story: 'Different padding options: none, sm, md, lg.',
      },
    },
  },
};

// Modular sections
export const WithSections: Story = {
  render: () => (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-4xl">
      <DiceCard>
        <DiceCardHeader>
          <h3 className="text-lg font-semibold">Card with Header</h3>
          <p className="text-sm text-gray-500">Subtitle information</p>
        </DiceCardHeader>
        <DiceCardBody>
          <p className="text-gray-600">Main content goes here with proper separation from the header.</p>
        </DiceCardBody>
      </DiceCard>
      
      <DiceCard>
        <DiceCardBody>
          <h3 className="text-lg font-semibold mb-2">Card with Footer</h3>
          <p className="text-gray-600">Content above the footer section.</p>
        </DiceCardBody>
        <DiceCardFooter>
          <div className="flex justify-end space-x-2">
            <DiceButton variant="outline" size="sm">Cancel</DiceButton>
            <DiceButton size="sm">Save</DiceButton>
          </div>
        </DiceCardFooter>
      </DiceCard>
    </div>
  ),
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        story: 'Cards with modular header and footer sections.',
      },
    },
  },
};

// Complex D&D character card example
export const CharacterCard: Story = {
  render: () => (
    <DiceCard className="max-w-md">
      <DiceCardHeader>
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-semibold">Thorin Ironforge</h3>
            <p className="text-sm text-gray-500">Level 5 Dwarf Fighter</p>
          </div>
          <div className="text-right">
            <div className="text-2xl font-bold text-green-600">42</div>
            <div className="text-xs text-gray-500">HP</div>
          </div>
        </div>
      </DiceCardHeader>
      
      <DiceCardBody>
        <div className="space-y-3">
          <div className="grid grid-cols-3 gap-3 text-center">
            <div>
              <div className="text-lg font-semibold">16</div>
              <div className="text-xs text-gray-500">STR (+3)</div>
            </div>
            <div>
              <div className="text-lg font-semibold">14</div>
              <div className="text-xs text-gray-500">DEX (+2)</div>
            </div>
            <div>
              <div className="text-lg font-semibold">15</div>
              <div className="text-xs text-gray-500">CON (+2)</div>
            </div>
          </div>
          
          <div className="border-t pt-3">
            <div className="flex justify-between text-sm">
              <span>Armor Class</span>
              <span className="font-medium">18</span>
            </div>
            <div className="flex justify-between text-sm">
              <span>Initiative</span>
              <span className="font-medium">+2</span>
            </div>
            <div className="flex justify-between text-sm">
              <span>Speed</span>
              <span className="font-medium">25 ft</span>
            </div>
          </div>
        </div>
      </DiceCardBody>
      
      <DiceCardFooter>
        <div className="flex space-x-2 w-full">
          <DiceButton variant="outline" size="sm" className="flex-1">Edit</DiceButton>
          <DiceButton size="sm" className="flex-1">View Sheet</DiceButton>
        </div>
      </DiceCardFooter>
    </DiceCard>
  ),
  parameters: {
    docs: {
      description: {
        story: 'A practical example of using Card for D&D character information.',
      },
    },
  },
};

// Full-width layout
export const FullWidth: Story = {
  args: {
    className: 'w-full',
    children: (
      <>
        <DiceCardHeader>
          <h3 className="text-lg font-semibold">Full Width Card</h3>
        </DiceCardHeader>
        <DiceCardBody>
          <p className="text-gray-600">This card takes the full width of its container, useful for dashboard layouts and content sections.</p>
        </DiceCardBody>
      </>
    ),
  },
  parameters: {
    layout: 'padded',
  },
}; 