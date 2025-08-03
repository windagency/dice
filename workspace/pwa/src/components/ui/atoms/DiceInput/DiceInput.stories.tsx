import type { Meta, StoryObj } from '@storybook/react';
import { DiceInput } from './DiceInput';

const meta = {
  title: 'UI Components/Input',
  component: DiceInput,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'A flexible input component with validation, error states, helper text, and icon support. Fully accessible with proper labeling.',
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['default', 'error', 'success'],
      description: 'Visual variant of the input',
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
      description: 'Size of the input',
    },
    label: {
      control: 'text',
      description: 'Label text for the input',
    },
    placeholder: {
      control: 'text',
      description: 'Placeholder text',
    },
    helperText: {
      control: 'text',
      description: 'Helper text displayed below the input',
    },
    errorMessage: {
      control: 'text',
      description: 'Error message (overrides helperText)',
    },
    isRequired: {
      control: 'boolean',
      description: 'Marks the input as required',
    },
    isDisabled: {
      control: 'boolean',
      description: 'Disables the input',
    },
    fullWidth: {
      control: 'boolean',
      description: 'Makes the input take full width',
    },
    type: {
      control: 'select',
      options: ['text', 'email', 'password', 'number', 'tel', 'url'],
      description: 'HTML input type',
    },
    leftIcon: {
      control: false,
      description: 'Icon to display on the left',
    },
    rightIcon: {
      control: false,
      description: 'Icon to display on the right',
    },
  },
} satisfies Meta<typeof DiceInput>;

export default meta;
type Story = StoryObj<typeof meta>;

// Default story
export const Default: Story = {
  args: {
    placeholder: 'Enter some text...',
  },
};

// With label
export const WithLabel: Story = {
  args: {
    label: 'Full Name',
    placeholder: 'Enter your full name',
  },
};

// Required field
export const Required: Story = {
  args: {
    label: 'Email Address',
    placeholder: 'Enter your email',
    isRequired: true,
    type: 'email',
  },
};

// With helper text
export const WithHelperText: Story = {
  args: {
    label: 'Username',
    placeholder: 'Choose a username',
    helperText: 'Must be 3-20 characters long',
  },
};

// Error state
export const WithError: Story = {
  args: {
    label: 'Email Address',
    placeholder: 'Enter your email',
    errorMessage: 'Please enter a valid email address',
    value: 'invalid-email',
  },
};

// Success state
export const Success: Story = {
  args: {
    label: 'Email Address',
    placeholder: 'Enter your email',
    variant: 'success',
    value: 'user@example.com',
    helperText: 'Email address is valid',
  },
};

// Disabled state
export const Disabled: Story = {
  args: {
    label: 'Disabled Field',
    placeholder: 'Cannot edit this',
    isDisabled: true,
    value: 'Disabled value',
  },
};

// Size variants
export const Sizes: Story = {
  render: () => (
    <div className="space-y-4 w-80">
      <DiceInput size="sm" placeholder="Small input" label="Small" />
      <DiceInput size="md" placeholder="Medium input" label="Medium" />
      <DiceInput size="lg" placeholder="Large input" label="Large" />
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Inputs come in three sizes: sm, md, and lg.',
      },
    },
  },
};

// With icons
export const WithIcons: Story = {
  render: () => (
    <div className="space-y-4 w-80">
      <DiceInput 
        placeholder="Search..." 
        leftIcon={<span>🔍</span>}
        label="Search"
      />
      <DiceInput 
        type="email"
        placeholder="Email address" 
        rightIcon={<span>@</span>}
        label="Email"
      />
      <DiceInput 
        placeholder="Amount" 
        leftIcon={<span>$</span>}
        rightIcon={<span>.00</span>}
        label="Price"
      />
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Inputs can have icons on the left, right, or both sides.',
      },
    },
  },
};

// Different types
export const InputTypes: Story = {
  render: () => (
    <div className="space-y-4 w-80">
      <DiceInput type="text" label="Text" placeholder="Enter text" />
      <DiceInput type="email" label="Email" placeholder="Enter email address" />
      <DiceInput type="password" label="Password" placeholder="Enter password" />
      <DiceInput type="number" label="Number" placeholder="Enter a number" />
      <DiceInput type="tel" label="Phone" placeholder="Enter phone number" />
      <DiceInput type="url" label="Website" placeholder="Enter URL" />
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Different HTML input types with appropriate validation.',
      },
    },
  },
};

// Form validation example
export const FormValidation: Story = {
  render: () => (
    <div className="space-y-4 w-80">
      <DiceInput 
        label="Required Field"
        placeholder="This field is required"
        isRequired
        errorMessage="This field is required"
      />
      <DiceInput 
        label="Email Validation"
        type="email"
        placeholder="Enter valid email"
        errorMessage="Please enter a valid email address"
        value="invalid-email"
      />
      <DiceInput 
        label="Success State"
        variant="success"
        placeholder="Valid input"
        value="valid@example.com"
        helperText="✓ Email is valid"
      />
      <DiceInput 
        label="Disabled Field"
        placeholder="Cannot edit"
        isDisabled
        value="Read-only value"
      />
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Examples of form validation states and feedback.',
      },
    },
  },
}; 