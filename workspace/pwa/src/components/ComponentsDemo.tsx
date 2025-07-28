import React from 'react';
import {
  DiceButton,
  DiceInput,
  DiceCard,
  DiceCardHeader,
  DiceCardBody,
  DiceCardFooter,
  DiceModal,
  DiceModalHeader,
  DiceModalBody,
  DiceModalFooter,
  DiceTabs,
  DiceLoadingSpinner,
  DiceErrorBoundary,
  DiceTooltip
} from './ui';

const ComponentsDemo: React.FC = () => {
  const [isModalOpen, setIsModalOpen] = React.useState(false);
  const [inputValue, setInputValue] = React.useState('');
  const [hasInputError, setHasInputError] = React.useState(false);

  const tabsData = [
    {
      id: 'buttons',
      label: 'Buttons',
      children: (
        <div className="space-y-6">
          <div>
            <h3 className="text-lg font-medium mb-4">Button Variants</h3>
            <div className="flex flex-wrap gap-3">
              <DiceButton variant="primary">Primary</DiceButton>
              <DiceButton variant="secondary">Secondary</DiceButton>
              <DiceButton variant="danger">Danger</DiceButton>
              <DiceButton variant="ghost">Ghost</DiceButton>
            </div>
          </div>

          <div>
            <h3 className="text-lg font-medium mb-4">Button Sizes</h3>
            <div className="flex flex-wrap gap-3 items-end">
              <DiceButton size="sm">Small</DiceButton>
              <DiceButton size="md">Medium</DiceButton>
              <DiceButton size="lg">Large</DiceButton>
            </div>
          </div>

          <div>
            <h3 className="text-lg font-medium mb-4">Button States</h3>
            <div className="flex flex-wrap gap-3">
              <DiceButton>Normal</DiceButton>
              <DiceButton disabled>Disabled</DiceButton>
              <DiceButton loading>Loading</DiceButton>
            </div>
          </div>
        </div>
      )
    },
    {
      id: 'inputs',
      label: 'Inputs',
      children: (
        <div className="space-y-6">
          <div>
            <h3 className="text-lg font-medium mb-4">Input Variants</h3>
            <div className="space-y-4 max-w-md">
              <DiceInput
                label="Default Input"
                placeholder="Enter text here..."
                value={inputValue}
                onChange={(e) => setInputValue(e.target.value)}
              />
              <DiceInput
                label="Input with Error"
                placeholder="This input has an error"
                error="This field is required"
                value=""
                onChange={() => {}}
              />
              <DiceInput
                label="Disabled Input"
                placeholder="This input is disabled"
                disabled
                value="Can't edit this"
                onChange={() => {}}
              />
            </div>
          </div>
        </div>
      )
    },
    {
      id: 'cards',
      label: 'Cards',
      children: (
        <div className="space-y-6">
          <div>
            <h3 className="text-lg font-medium mb-4">Basic Cards</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <DiceCard>
                <DiceCardHeader>
                  <h4 className="text-lg font-semibold">Simple Card</h4>
                </DiceCardHeader>
                <DiceCardBody>
                  <p>This is a basic card with header and body content.</p>
                </DiceCardBody>
              </DiceCard>

              <DiceCard>
                <DiceCardHeader>
                  <h4 className="text-lg font-semibold">Card with Footer</h4>
                </DiceCardHeader>
                <DiceCardBody>
                  <p>This card includes a footer section with actions.</p>
                </DiceCardBody>
                <DiceCardFooter>
                  <div className="flex gap-2">
                    <DiceButton size="sm" variant="primary">Action</DiceButton>
                    <DiceButton size="sm" variant="ghost">Cancel</DiceButton>
                  </div>
                </DiceCardFooter>
              </DiceCard>
            </div>
          </div>
        </div>
      )
    },
    {
      id: 'modals',
      label: 'Modals',
      children: (
        <div className="space-y-6">
          <div>
            <h3 className="text-lg font-medium mb-4">Modal Demo</h3>
            <DiceButton onClick={() => setIsModalOpen(true)}>
              Open Modal
            </DiceButton>

            <DiceModal 
              isOpen={isModalOpen} 
              onClose={() => setIsModalOpen(false)}
              title="Example Modal"
            >
              <DiceModalHeader>
                <h4 className="text-lg font-semibold">Modal Title</h4>
              </DiceModalHeader>
              <DiceModalBody>
                <p>This is the modal content. You can put any content here including forms, images, or other components.</p>
                <div className="mt-4">
                  <DiceInput
                    label="Example Input"
                    placeholder="Enter something..."
                  />
                </div>
              </DiceModalBody>
              <DiceModalFooter>
                <div className="flex gap-2 justify-end">
                  <DiceButton 
                    variant="ghost" 
                    onClick={() => setIsModalOpen(false)}
                  >
                    Cancel
                  </DiceButton>
                  <DiceButton 
                    variant="primary"
                    onClick={() => setIsModalOpen(false)}
                  >
                    Save
                  </DiceButton>
                </div>
              </DiceModalFooter>
            </DiceModal>
          </div>
        </div>
      )
    },
    {
      id: 'feedback',
      label: 'Feedback',
      children: (
        <div className="space-y-6">
          <div>
            <h3 className="text-lg font-medium mb-4">Loading States</h3>
            <div className="flex flex-wrap gap-4 items-center">
              <DiceLoadingSpinner size="sm" />
              <DiceLoadingSpinner size="md" />
              <DiceLoadingSpinner size="lg" />
            </div>
          </div>

          <div>
            <h3 className="text-lg font-medium mb-4">Error Boundary</h3>
            <DiceErrorBoundary>
              <div className="p-4 bg-green-50 border border-green-200 rounded-md">
                <p className="text-green-800">This content is protected by an error boundary.</p>
              </div>
            </DiceErrorBoundary>
          </div>

          <div>
            <h3 className="text-lg font-medium mb-4">Tooltips</h3>
            <div className="flex gap-4">
              <DiceTooltip content="This is a tooltip">
                <DiceButton>Hover me</DiceButton>
              </DiceTooltip>
              <DiceTooltip content="Another tooltip with more content">
                <DiceButton variant="secondary">Hover for tooltip</DiceButton>
              </DiceTooltip>
            </div>
          </div>
        </div>
      )
    }
  ];

  return (
    <div className="space-y-8">
      <DiceTabs 
        tabs={tabsData}
        defaultActiveTab="buttons"
      />
    </div>
  );
};

export default ComponentsDemo; 