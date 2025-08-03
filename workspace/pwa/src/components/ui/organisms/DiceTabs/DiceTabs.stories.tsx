import type { Meta, StoryObj } from '@storybook/react';
import { DiceTabs } from './DiceTabs';
import { DiceCard, DiceCardBody } from 'ui/molecules/DiceCard';
import { DiceButton } from 'ui/atoms/DiceButton';

// Atomic Design: Organisms - Full UI sections composed of molecules and atoms
// This component organizes internal layout and state handling

const meta = {
  title: 'UI Components/Tabs',
  component: DiceTabs,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'A flexible tabs component with keyboard navigation, accessibility features, and multiple visual variants. Supports both controlled and uncontrolled state.',
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['default', 'pills', 'underline'],
      description: 'Visual style variant of the tabs',
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
      description: 'Size of the tabs',
    },
    fullWidth: {
      control: 'boolean',
      description: 'Make tabs take full width',
    },
    defaultTab: {
      control: 'text',
      description: 'Default active tab ID',
    },
    onTabChange: {
      action: 'tab-changed',
      description: 'Tab change event handler',
    },
  },
} satisfies Meta<typeof DiceTabs>;

export default meta;
type Story = StoryObj<typeof meta>;

// Sample tabs data
const sampleTabs = [
  {
    id: 'overview',
    label: 'Overview',
    children: (
      <div className="p-4">
        <h3 className="text-lg font-semibold mb-2">Character Overview</h3>
        <p className="text-gray-600">
          This tab contains general information about your D&D character including 
          basic stats, background, and current status.
        </p>
      </div>
    ),
  },
  {
    id: 'abilities',
    label: 'Abilities',
    children: (
      <div className="p-4">
        <h3 className="text-lg font-semibold mb-2">Ability Scores</h3>
        <div className="grid grid-cols-3 gap-4 text-center">
          <div>
            <div className="text-2xl font-bold">16</div>
            <div className="text-sm text-gray-500">STR (+3)</div>
          </div>
          <div>
            <div className="text-2xl font-bold">14</div>
            <div className="text-sm text-gray-500">DEX (+2)</div>
          </div>
          <div>
            <div className="text-2xl font-bold">15</div>
            <div className="text-sm text-gray-500">CON (+2)</div>
          </div>
        </div>
      </div>
    ),
  },
  {
    id: 'equipment',
    label: 'Equipment',
    children: (
      <div className="p-4">
        <h3 className="text-lg font-semibold mb-2">Equipment & Inventory</h3>
        <ul className="space-y-2">
          <li className="flex justify-between">
            <span>Longsword +1</span>
            <span className="text-gray-500">1d8+4</span>
          </li>
          <li className="flex justify-between">
            <span>Chain Mail</span>
            <span className="text-gray-500">AC 16</span>
          </li>
          <li className="flex justify-between">
            <span>Shield</span>
            <span className="text-gray-500">+2 AC</span>
          </li>
        </ul>
      </div>
    ),
  },
  {
    id: 'spells',
    label: 'Spells',
    disabled: true,
    children: (
      <div className="p-4">
        <p className="text-gray-500">No spells available for this character class.</p>
      </div>
    ),
  },
];

// Default story
export const Default: Story = {
  args: {
    tabs: sampleTabs,
    variant: 'default',
    size: 'md',
  },
};

// Different variants
export const Variants: Story = {
  render: () => (
    <div className="space-y-8 w-full max-w-4xl">
      <div>
        <h3 className="text-lg font-medium mb-4">Default Tabs</h3>
        <DiceTabs tabs={sampleTabs} variant="default" />
      </div>
      
      <div>
        <h3 className="text-lg font-medium mb-4">Pills Tabs</h3>
        <DiceTabs tabs={sampleTabs} variant="pills" />
      </div>
      
      <div>
        <h3 className="text-lg font-medium mb-4">Underline Tabs</h3>
        <DiceTabs tabs={sampleTabs} variant="underline" />
      </div>
    </div>
  ),
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        story: 'All tab variants: default, pills, and underline.',
      },
    },
  },
};

// Different sizes
export const Sizes: Story = {
  render: () => (
    <div className="space-y-8 w-full max-w-4xl">
      <div>
        <h3 className="text-lg font-medium mb-4">Small Tabs</h3>
        <DiceTabs tabs={sampleTabs} size="sm" />
      </div>
      
      <div>
        <h3 className="text-lg font-medium mb-4">Medium Tabs</h3>
        <DiceTabs tabs={sampleTabs} size="md" />
      </div>
      
      <div>
        <h3 className="text-lg font-medium mb-4">Large Tabs</h3>
        <DiceTabs tabs={sampleTabs} size="lg" />
      </div>
    </div>
  ),
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        story: 'Tab sizes: sm, md, and lg.',
      },
    },
  },
};

// With icons
export const WithIcons: Story = {
  args: {
    tabs: [
      {
        id: 'profile',
        label: 'Profile',
        icon: <span>👤</span>,
        children: (
          <DiceCard>
            <DiceCardBody>
              <h3 className="text-lg font-semibold mb-2">Character Profile</h3>
              <p className="text-gray-600">Personal information and background details.</p>
            </DiceCardBody>
          </DiceCard>
        ),
      },
      {
        id: 'combat',
        label: 'Combat',
        icon: <span>⚔️</span>,
        children: (
          <DiceCard>
            <DiceCardBody>
              <h3 className="text-lg font-semibold mb-2">Combat Stats</h3>
              <p className="text-gray-600">Attack bonuses, damage, and defensive capabilities.</p>
            </DiceCardBody>
          </DiceCard>
        ),
      },
      {
        id: 'magic',
        label: 'Magic',
        icon: <span>✨</span>,
        children: (
          <DiceCard>
            <DiceCardBody>
              <h3 className="text-lg font-semibold mb-2">Spells & Magic</h3>
              <p className="text-gray-600">Available spells and magical abilities.</p>
            </DiceCardBody>
          </DiceCard>
        ),
      },
    ],
    variant: 'pills',
  },
  parameters: {
    docs: {
      description: {
        story: 'Tabs with icons for better visual identification.',
      },
    },
  },
};

// Full width
export const FullWidth: Story = {
  args: {
    tabs: sampleTabs.slice(0, 3), // Show only first 3 tabs
    fullWidth: true,
    variant: 'underline',
  },
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        story: 'Full-width tabs that expand to fill available space.',
      },
    },
  },
};

// Character sheet example
export const CharacterSheet: Story = {
  render: () => {
    const characterTabs = [
      {
        id: 'stats',
        label: 'Stats',
        children: (
          <div className="p-6">
            <div className="grid grid-cols-2 md:grid-cols-3 gap-6">
              <DiceCard>
                <DiceCardBody>
                  <h4 className="font-semibold mb-2">Ability Scores</h4>
                  <div className="space-y-1 text-sm">
                    <div className="flex justify-between">
                      <span>Strength</span>
                      <span>16 (+3)</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Dexterity</span>
                      <span>14 (+2)</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Constitution</span>
                      <span>15 (+2)</span>
                    </div>
                  </div>
                </DiceCardBody>
              </DiceCard>
              
              <DiceCard>
                <DiceCardBody>
                  <h4 className="font-semibold mb-2">Combat</h4>
                  <div className="space-y-1 text-sm">
                    <div className="flex justify-between">
                      <span>Armor Class</span>
                      <span>18</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Hit Points</span>
                      <span>42/42</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Initiative</span>
                      <span>+2</span>
                    </div>
                  </div>
                </DiceCardBody>
              </DiceCard>
              
              <DiceCard>
                <DiceCardBody>
                  <h4 className="font-semibold mb-2">Saves</h4>
                  <div className="space-y-1 text-sm">
                    <div className="flex justify-between">
                      <span>Fortitude</span>
                      <span>+6</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Reflex</span>
                      <span>+3</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Will</span>
                      <span>+2</span>
                    </div>
                  </div>
                </DiceCardBody>
              </DiceCard>
            </div>
          </div>
        ),
      },
      {
        id: 'inventory',
        label: 'Inventory',
        children: (
          <div className="p-6">
            <DiceCard>
              <DiceCardBody>
                <h4 className="font-semibold mb-4">Equipment</h4>
                <div className="space-y-3">
                  <div className="flex items-center justify-between p-3 bg-gray-50 rounded">
                    <div>
                      <div className="font-medium">Longsword +1</div>
                      <div className="text-sm text-gray-600">Damage: 1d8+4 slashing</div>
                    </div>
                    <DiceButton size="sm" variant="outline">Use</DiceButton>
                  </div>
                  <div className="flex items-center justify-between p-3 bg-gray-50 rounded">
                    <div>
                      <div className="font-medium">Chain Mail</div>
                      <div className="text-sm text-gray-600">AC: 16, Max Dex: +2</div>
                    </div>
                    <DiceButton size="sm" variant="outline">Equipped</DiceButton>
                  </div>
                </div>
              </DiceCardBody>
            </DiceCard>
          </div>
        ),
      },
      {
        id: 'notes',
        label: 'Notes',
        children: (
          <div className="p-6">
            <DiceCard>
              <DiceCardBody>
                <h4 className="font-semibold mb-4">Character Notes</h4>
                <textarea
                  className="w-full h-32 p-3 border border-gray-300 rounded-md resize-none focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Add notes about your character's story, goals, or important details..."
                  defaultValue="Thorin is a proud dwarf warrior seeking to reclaim his ancestral homeland. He carries the weight of his clan's expectations and fights with honor above all else."
                />
              </DiceCardBody>
            </DiceCard>
          </div>
        ),
      },
    ];

    return (
      <div className="w-full max-w-4xl">
        <div className="mb-6">
          <h2 className="text-2xl font-bold">Thorin Ironforge</h2>
          <p className="text-gray-600">Level 5 Dwarf Fighter</p>
        </div>
        <DiceTabs tabs={characterTabs} variant="underline" size="md" />
      </div>
    );
  },
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        story: 'A realistic example of tabs used in a D&D character sheet interface.',
      },
    },
  },
}; 