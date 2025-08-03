import type { Meta, StoryObj } from '@storybook/react';
import { useState } from 'react';
import { DiceModal, DiceModalHeader, DiceModalBody, DiceModalFooter } from './DiceModal';
import { DiceButton } from 'ui/atoms/DiceButton';
import { DiceInput } from 'ui/atoms/DiceInput';

// Atomic Design: Organisms - Full UI sections composed of molecules and atoms
// This component organizes internal layout and state handling

const meta = {
  title: 'UI Components/Modal',
  component: DiceModal,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'A flexible modal dialog component with focus management, keyboard navigation, and accessibility features. Supports multiple sizes and customizable content sections.',
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    isOpen: {
      control: 'boolean',
      description: 'Controls modal visibility',
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg', 'xl', 'full'],
      description: 'Size of the modal dialog',
    },
    title: {
      control: 'text',
      description: 'Modal title (optional)',
    },
    showCloseButton: {
      control: 'boolean',
      description: 'Show X close button in header',
    },
    closeOnBackdrop: {
      control: 'boolean',
      description: 'Close modal when clicking backdrop',
    },
    closeOnEscape: {
      control: 'boolean',
      description: 'Close modal when pressing Escape key',
    },
    onClose: {
      action: 'closed',
      description: 'Close event handler',
    },
  },
} satisfies Meta<typeof DiceModal>;

export default meta;
type Story = StoryObj<typeof meta>;

// Interactive modal example
const InteractiveModal = ({ size = 'md', title = 'Example Modal' }) => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      <DiceButton onClick={() => setIsOpen(true)}>
        Open {size.toUpperCase()} Modal
      </DiceButton>
      
      <DiceModal
        isOpen={isOpen}
        onClose={() => setIsOpen(false)}
        title={title}
        size={size}
      >
        <DiceModalBody>
          <p className="text-gray-600 mb-4">
            This is a {size} modal dialog. You can close it by clicking the X button, 
            pressing Escape, or clicking outside the modal.
          </p>
          <p className="text-sm text-gray-500">
            The modal automatically manages focus and prevents background scrolling.
          </p>
        </DiceModalBody>
        <DiceModalFooter>
          <DiceButton variant="outline" onClick={() => setIsOpen(false)}>
            Cancel
          </DiceButton>
          <DiceButton onClick={() => setIsOpen(false)}>
            Confirm
          </DiceButton>
        </DiceModalFooter>
      </DiceModal>
    </>
  );
};

// Default story
export const Default: Story = {
  render: () => <InteractiveModal />,
};

// Different sizes
export const Sizes: Story = {
  render: () => (
    <div className="flex flex-wrap gap-3">
      <InteractiveModal size="sm" title="Small Modal" />
      <InteractiveModal size="md" title="Medium Modal" />
      <InteractiveModal size="lg" title="Large Modal" />
      <InteractiveModal size="xl" title="Extra Large Modal" />
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Modal dialogs in different sizes: sm, md, lg, xl.',
      },
    },
  },
};

// Form modal example
export const FormModal: Story = {
  render: () => {
    const [isOpen, setIsOpen] = useState(false);
    const [formData, setFormData] = useState({
      name: '',
      email: '',
      message: ''
    });

    const handleSubmit = (e: React.FormEvent) => {
      e.preventDefault();
      console.log('Form submitted:', formData);
      setIsOpen(false);
      setFormData({ name: '', email: '', message: '' });
    };

    return (
      <>
        <DiceButton onClick={() => setIsOpen(true)}>
          Open Contact Form
        </DiceButton>
        
        <DiceModal
          isOpen={isOpen}
          onClose={() => setIsOpen(false)}
          title="Contact Us"
          size="md"
        >
          <form onSubmit={handleSubmit}>
            <DiceModalBody>
              <div className="space-y-4">
                <DiceInput
                  label="Full Name"
                  value={formData.name}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                  placeholder="Enter your name"
                  isRequired
                />
                <DiceInput
                  label="Email Address"
                  type="email"
                  value={formData.email}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => setFormData(prev => ({ ...prev, email: e.target.value }))}
                  placeholder="Enter your email"
                  isRequired
                />
                <DiceInput
                  label="Message"
                  value={formData.message}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => setFormData(prev => ({ ...prev, message: e.target.value }))}
                  placeholder="Your message..."
                  isRequired
                />
              </div>
            </DiceModalBody>
            <DiceModalFooter>
              <DiceButton 
                type="button" 
                variant="outline" 
                onClick={() => setIsOpen(false)}
              >
                Cancel
              </DiceButton>
              <DiceButton type="submit">
                Send Message
              </DiceButton>
            </DiceModalFooter>
          </form>
        </DiceModal>
      </>
    );
  },
  parameters: {
    docs: {
      description: {
        story: 'Modal with form inputs and proper submission handling.',
      },
    },
  },
};

// Confirmation modal
export const ConfirmationModal: Story = {
  render: () => {
    const [isOpen, setIsOpen] = useState(false);

    const handleConfirm = () => {
      console.log('Action confirmed');
      setIsOpen(false);
    };

    return (
      <>
        <DiceButton variant="danger" onClick={() => setIsOpen(true)}>
          Delete Character
        </DiceButton>
        
        <DiceModal
          isOpen={isOpen}
          onClose={() => setIsOpen(false)}
          title="Confirm Deletion"
          size="sm"
        >
          <DiceModalBody>
            <div className="text-center">
              <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-100 mb-4">
                <svg className="h-6 w-6 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
                </svg>
              </div>
              <h3 className="text-lg font-medium text-gray-900 mb-2">
                Delete Character
              </h3>
              <p className="text-sm text-gray-500">
                Are you sure you want to delete this character? This action cannot be undone.
              </p>
            </div>
          </DiceModalBody>
          <DiceModalFooter>
            <DiceButton variant="outline" onClick={() => setIsOpen(false)}>
              Cancel
            </DiceButton>
            <DiceButton variant="danger" onClick={handleConfirm}>
              Delete
            </DiceButton>
          </DiceModalFooter>
        </DiceModal>
      </>
    );
  },
  parameters: {
    docs: {
      description: {
        story: 'Confirmation modal for destructive actions.',
      },
    },
  },
};

// Custom modal without sections
export const CustomModal: Story = {
  render: () => {
    const [isOpen, setIsOpen] = useState(false);

    return (
      <>
        <DiceButton onClick={() => setIsOpen(true)}>
          Open Custom Modal
        </DiceButton>
        
        <DiceModal
          isOpen={isOpen}
          onClose={() => setIsOpen(false)}
          showCloseButton={false}
          closeOnBackdrop={false}
          size="lg"
        >
          <div className="p-6 text-center">
            <div className="mx-auto flex items-center justify-center h-16 w-16 rounded-full bg-green-100 mb-4">
              <svg className="h-8 w-8 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
            </div>
            <h2 className="text-2xl font-bold text-gray-900 mb-2">
              Character Created!
            </h2>
            <p className="text-gray-600 mb-6">
              Your new D&D character has been successfully created and saved.
            </p>
            <DiceButton onClick={() => setIsOpen(false)}>
              Continue to Character Sheet
            </DiceButton>
          </div>
        </DiceModal>
      </>
    );
  },
  parameters: {
    docs: {
      description: {
        story: 'Custom modal without predefined sections, useful for success messages and custom layouts.',
      },
    },
  },
}; 