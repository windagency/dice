import type { Meta, StoryObj } from '@storybook/react';
import { DiceButton } from './DiceButton';

const meta = {
  title: 'UI Components/DiceButton',
  component: DiceButton,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'A versatile button component with multiple variants, sizes, and states. Supports loading states, icons, and full accessibility.',
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'danger', 'ghost', 'outline'],
      description: 'Visual style variant of the button',
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg', 'xl'],
      description: 'Size of the button',
    },
    isLoading: {
      control: 'boolean',
      description: 'Shows loading spinner and disables the button',
    },
    disabled: {
      control: 'boolean',
      description: 'Disables the button',
    },
    fullWidth: {
      control: 'boolean',
      description: 'Makes the button take full width of its container',
    },
    children: {
      control: 'text',
      description: 'Button text content',
    },
    leftIcon: {
      control: false,
      description: 'Icon to display on the left side',
    },
    rightIcon: {
      control: false,
      description: 'Icon to display on the right side',
    },
    onClick: {
      action: 'clicked',
      description: 'Click event handler',
    },
  },
} satisfies Meta<typeof DiceButton>;

export default meta;
type Story = StoryObj<typeof meta>;

// Default story
export const Default: Story = {
  args: {
    children: 'Button',
  },
};

// Variant stories
export const Primary: Story = {
  args: {
    variant: 'primary',
    children: 'Primary Button',
  },
};

export const Secondary: Story = {
  args: {
    variant: 'secondary',
    children: 'Secondary Button',
  },
};

export const Danger: Story = {
  args: {
    variant: 'danger',
    children: 'Danger Button',
  },
};

export const Ghost: Story = {
  args: {
    variant: 'ghost',
    children: 'Ghost Button',
  },
};

export const Outline: Story = {
  args: {
    variant: 'outline',
    children: 'Outline Button',
  },
};

// Size stories
export const Sizes: Story = {
  args: {},
  render: () => (
    <div className="flex items-center gap-4">
      <DiceButton size="sm">Small</DiceButton>
      <DiceButton size="md">Medium</DiceButton>
      <DiceButton size="lg">Large</DiceButton>
      <DiceButton size="xl">Extra Large</DiceButton>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Buttons come in four different sizes: sm, md, lg, and xl.',
      },
    },
  },
};

// State stories
export const Loading: Story = {
  args: {
    isLoading: true,
    children: 'Loading...',
  },
};

export const Disabled: Story = {
  args: {
    disabled: true,
    children: 'Disabled Button',
  },
};

export const FullWidth: Story = {
  args: {
    fullWidth: true,
    children: 'Full Width Button',
  },
  parameters: {
    layout: 'padded',
  },
};

// Icon stories
export const WithIcons: Story = {
  args: {},
  render: () => (
    <div className="flex gap-4">
      <DiceButton leftIcon={<span>🚀</span>}>With Left Icon</DiceButton>
      <DiceButton rightIcon={<span>→</span>}>With Right Icon</DiceButton>
      <DiceButton leftIcon={<span>📁</span>} rightIcon={<span>↗</span>}>
        Both Icons
      </DiceButton>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Buttons can display icons on the left, right, or both sides.',
      },
    },
  },
};

// All variants showcase
export const AllVariants: Story = {
  args: {},
  render: () => (
    <div className="space-y-4">
      <div className="flex gap-3">
        <DiceButton variant="primary">Primary</DiceButton>
        <DiceButton variant="secondary">Secondary</DiceButton>
        <DiceButton variant="danger">Danger</DiceButton>
        <DiceButton variant="ghost">Ghost</DiceButton>
        <DiceButton variant="outline">Outline</DiceButton>
      </div>
      <div className="flex gap-3">
        <DiceButton variant="primary" disabled>Primary</DiceButton>
        <DiceButton variant="secondary" disabled>Secondary</DiceButton>
        <DiceButton variant="danger" disabled>Danger</DiceButton>
        <DiceButton variant="ghost" disabled>Ghost</DiceButton>
        <DiceButton variant="outline" disabled>Outline</DiceButton>
      </div>
      <div className="flex gap-3">
        <DiceButton variant="primary" isLoading>Primary</DiceButton>
        <DiceButton variant="secondary" isLoading>Secondary</DiceButton>
        <DiceButton variant="danger" isLoading>Danger</DiceButton>
      </div>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'All button variants in normal, disabled, and loading states.',
      },
    },
  },
}; 