import type { Meta, StoryObj } from '@storybook/react';
import { DiceTooltip } from './DiceTooltip';
import { DiceButton } from '../DiceButton';
import { DiceCard, DiceCardBody } from '../DiceCard';

const meta = {
  title: 'UI Components/Tooltip',
  component: DiceTooltip,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'A flexible tooltip component with multiple positioning options and trigger methods. Provides contextual information with proper accessibility support.',
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    content: {
      control: 'text',
      description: 'Tooltip content (text or React node)',
    },
    position: {
      control: 'select',
      options: ['top', 'bottom', 'left', 'right'],
      description: 'Position of the tooltip relative to trigger',
    },
    trigger: {
      control: 'select',
      options: ['hover', 'focus', 'click'],
      description: 'How the tooltip is triggered',
    },
    delay: {
      control: 'number',
      description: 'Delay in milliseconds before showing tooltip',
    },
    className: {
      control: 'text',
      description: 'Additional CSS classes for tooltip',
    },
  },
} satisfies Meta<typeof DiceTooltip>;

export default meta;
type Story = StoryObj<typeof meta>;

// Default story
export const Default: Story = {
  args: {
    content: 'This is a helpful tooltip',
    children: <DiceButton>Hover me</DiceButton>,
  },
};

// Different positions
export const Positions: Story = {
  render: () => (
    <div className="flex flex-wrap gap-8 items-center justify-center min-h-[200px]">
      <DiceTooltip content="Tooltip on top" position="top">
        <DiceButton>Top</DiceButton>
      </DiceTooltip>
      
      <DiceTooltip content="Tooltip on bottom" position="bottom">
        <DiceButton>Bottom</DiceButton>
      </DiceTooltip>
      
      <DiceTooltip content="Tooltip on left" position="left">
        <DiceButton>Left</DiceButton>
      </DiceTooltip>
      
      <DiceTooltip content="Tooltip on right" position="right">
        <DiceButton>Right</DiceButton>
      </DiceTooltip>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Tooltips positioned in all four directions: top, bottom, left, right.',
      },
    },
  },
};

// Different triggers
export const Triggers: Story = {
  render: () => (
    <div className="flex flex-wrap gap-6">
      <DiceTooltip content="Appears on hover and focus" trigger="hover">
        <DiceButton>Hover Trigger</DiceButton>
      </DiceTooltip>
      
      <DiceTooltip content="Appears only on focus (keyboard/screen reader)" trigger="focus">
        <DiceButton>Focus Trigger</DiceButton>
      </DiceTooltip>
      
      <DiceTooltip content="Click to toggle tooltip" trigger="click">
        <DiceButton>Click Trigger</DiceButton>
      </DiceTooltip>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Different ways to trigger tooltips: hover, focus, or click.',
      },
    },
  },
};

// With delay
export const WithDelay: Story = {
  render: () => (
    <div className="flex gap-6">
      <DiceTooltip content="No delay" delay={0}>
        <DiceButton>No Delay</DiceButton>
      </DiceTooltip>
      
      <DiceTooltip content="500ms delay" delay={500}>
        <DiceButton>500ms Delay</DiceButton>
      </DiceTooltip>
      
      <DiceTooltip content="1000ms delay" delay={1000}>
        <DiceButton>1s Delay</DiceButton>
      </DiceTooltip>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Tooltips with different show delays to prevent accidental triggering.',
      },
    },
  },
};

// Rich content
export const RichContent: Story = {
  render: () => (
    <div className="flex flex-wrap gap-6">
      <DiceTooltip 
        content={
          <div>
            <div className="font-semibold mb-1">Longsword +1</div>
            <div className="text-xs opacity-90">Damage: 1d8+4 slashing</div>
            <div className="text-xs opacity-90">Magical weapon</div>
          </div>
        }
      >
        <DiceButton>Equipment Info</DiceButton>
      </DiceTooltip>
      
      <DiceTooltip 
        content={
          <div>
            <div className="font-semibold mb-1">⚔️ Attack Roll</div>
            <div className="text-xs opacity-90">1d20 + STR modifier + proficiency</div>
          </div>
        }
      >
        <DiceButton>Combat Tooltip</DiceButton>
      </DiceTooltip>
      
      <DiceTooltip 
        content={
          <div className="max-w-xs">
            <div className="font-semibold mb-1">Spell: Fireball</div>
            <div className="text-xs opacity-90 mb-2">
              A bright streak flashes from your pointing finger to a point you choose 
              within range and then blossoms with a low roar into an explosion of flame.
            </div>
            <div className="text-xs opacity-75">Level 3 • Evocation</div>
          </div>
        }
        position="bottom"
      >
        <DiceButton>Spell Description</DiceButton>
      </DiceTooltip>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Tooltips with rich content including formatting, icons, and detailed information.',
      },
    },
  },
};

// D&D character sheet tooltips
export const DnDCharacterSheet: Story = {
  render: () => (
    <DiceCard className="max-w-md">
      <DiceCardBody>
        <h3 className="text-lg font-semibold mb-4">Character Stats</h3>
        
        <div className="grid grid-cols-3 gap-4 text-center mb-6">
          <DiceTooltip 
            content={
              <div>
                <div className="font-semibold">Strength</div>
                <div className="text-xs opacity-90">Measures physical power</div>
                <div className="text-xs opacity-90">Affects: Attack rolls, damage, carrying capacity</div>
              </div>
            }
            position="top"
          >
            <div className="cursor-help">
              <div className="text-2xl font-bold">16</div>
              <div className="text-sm text-gray-500">STR (+3)</div>
            </div>
          </DiceTooltip>
          
          <DiceTooltip 
            content={
              <div>
                <div className="font-semibold">Dexterity</div>
                <div className="text-xs opacity-90">Measures agility and reflexes</div>
                <div className="text-xs opacity-90">Affects: AC, initiative, ranged attacks</div>
              </div>
            }
            position="top"
          >
            <div className="cursor-help">
              <div className="text-2xl font-bold">14</div>
              <div className="text-sm text-gray-500">DEX (+2)</div>
            </div>
          </DiceTooltip>
          
          <DiceTooltip 
            content={
              <div>
                <div className="font-semibold">Constitution</div>
                <div className="text-xs opacity-90">Measures health and stamina</div>
                <div className="text-xs opacity-90">Affects: Hit points, fortitude saves</div>
              </div>
            }
            position="top"
          >
            <div className="cursor-help">
              <div className="text-2xl font-bold">15</div>
              <div className="text-sm text-gray-500">CON (+2)</div>
            </div>
          </DiceTooltip>
        </div>
        
        <div className="space-y-2">
          <div className="flex justify-between items-center">
            <DiceTooltip content="Your defense against physical attacks">
              <span className="cursor-help text-gray-700">Armor Class</span>
            </DiceTooltip>
            <span className="font-medium">18</span>
          </div>
          
          <div className="flex justify-between items-center">
            <DiceTooltip content="Your current health out of maximum">
              <span className="cursor-help text-gray-700">Hit Points</span>
            </DiceTooltip>
            <span className="font-medium text-green-600">42/42</span>
          </div>
          
          <div className="flex justify-between items-center">
            <DiceTooltip content="Added to initiative rolls for combat order">
              <span className="cursor-help text-gray-700">Initiative</span>
            </DiceTooltip>
            <span className="font-medium">+2</span>
          </div>
        </div>
      </DiceCardBody>
    </DiceCard>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Realistic D&D character sheet with helpful tooltips explaining game mechanics.',
      },
    },
  },
};

// Accessibility example
export const Accessibility: Story = {
  render: () => (
    <div className="space-y-6 max-w-md">
      <div>
        <h3 className="text-lg font-medium mb-4">Keyboard Navigation</h3>
        <div className="space-y-2">
          <DiceTooltip content="This tooltip appears on focus for keyboard users" trigger="focus">
            <button className="block w-full p-2 text-left border border-gray-300 rounded hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500">
              Focus me with Tab key
            </button>
          </DiceTooltip>
          
          <DiceTooltip content="Screen readers will announce this tooltip content">
            <button className="block w-full p-2 text-left border border-gray-300 rounded hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500">
              Screen reader accessible
            </button>
          </DiceTooltip>
        </div>
      </div>
      
      <div className="p-4 bg-blue-50 rounded-lg">
        <p className="text-sm text-blue-800">
          <strong>Accessibility Features:</strong><br/>
          • Tooltips are announced to screen readers<br/>
          • Keyboard navigation support with focus trigger<br/>
          • Proper ARIA attributes for tooltip relationship<br/>
          • Respects user preferences for reduced motion
        </p>
      </div>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Demonstrating tooltip accessibility features for keyboard and screen reader users.',
      },
    },
  },
};

// Custom styling
export const CustomStyling: Story = {
  render: () => (
    <div className="flex gap-6">
      <DiceTooltip 
        content="Success tooltip with custom styling"
        className="bg-green-600 text-green-50"
      >
        <DiceButton variant="outline">Success Style</DiceButton>
      </DiceTooltip>
      
      <DiceTooltip 
        content="Warning tooltip with custom styling"
        className="bg-yellow-500 text-yellow-900"
      >
        <DiceButton variant="outline">Warning Style</DiceButton>
      </DiceTooltip>
      
      <DiceTooltip 
        content="Error tooltip with custom styling"
        className="bg-red-600 text-red-50"
      >
        <DiceButton variant="outline">Error Style</DiceButton>
      </DiceTooltip>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Tooltips with custom colors and styling for different contexts.',
      },
    },
  },
}; 