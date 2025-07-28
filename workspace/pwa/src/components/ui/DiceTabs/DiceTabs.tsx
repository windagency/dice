import React, { useState, useRef, useEffect } from 'react';

type TabsVariant = 'default' | 'pills' | 'underline';
type TabsSize = 'sm' | 'md' | 'lg';

interface TabItem {
  readonly id: string;
  readonly label: string;
  readonly disabled?: boolean;
  readonly icon?: React.ReactNode;
  readonly children: React.ReactNode;
}

interface TabsProps {
  readonly tabs: readonly TabItem[];
  readonly defaultTab?: string;
  readonly activeTab?: string;
  readonly onTabChange?: (tabId: string) => void;
  readonly variant?: TabsVariant;
  readonly size?: TabsSize;
  readonly fullWidth?: boolean;
  readonly className?: string;
}

interface TabListProps {
  readonly tabs: readonly TabItem[];
  readonly activeTab: string;
  readonly onTabChange: (tabId: string) => void;
  readonly variant: TabsVariant;
  readonly size: TabsSize;
  readonly fullWidth: boolean;
}

interface TabButtonProps {
  readonly tab: TabItem;
  readonly isActive: boolean;
  readonly onClick: () => void;
  readonly variant: TabsVariant;
  readonly size: TabsSize;
  readonly fullWidth: boolean;
}

interface TabPanelProps {
  readonly tab: TabItem;
  readonly isActive: boolean;
}

const TAB_VARIANTS: Record<TabsVariant, { base: string; active: string; inactive: string }> = {
  default: {
    base: 'border-b border-gray-200',
    active: 'border-blue-500 text-blue-600',
    inactive: 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
  },
  pills: {
    base: 'rounded-md',
    active: 'bg-blue-100 text-blue-700',
    inactive: 'text-gray-500 hover:text-gray-700 hover:bg-gray-100'
  },
  underline: {
    base: 'border-b-2',
    active: 'border-blue-500 text-blue-600',
    inactive: 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
  }
};

const TAB_SIZES: Record<TabsSize, string> = {
  sm: 'px-3 py-2 text-sm',
  md: 'px-4 py-2 text-sm',
  lg: 'px-6 py-3 text-base'
};

export const DiceTabs: React.FC<TabsProps> = ({
  tabs,
  defaultTab,
  activeTab: controlledActiveTab,
  onTabChange,
  variant = 'default',
  size = 'md',
  fullWidth = false,
  className = ''
}) => {
  const [internalActiveTab, setInternalActiveTab] = useState(defaultTab || tabs[0]?.id || '');
  
  const isControlled = controlledActiveTab !== undefined;
  const activeTab = isControlled ? controlledActiveTab : internalActiveTab;
  
  const handleTabChange = (tabId: string): void => {
    if (!isControlled) {
      setInternalActiveTab(tabId);
    }
    onTabChange?.(tabId);
  };

  const containerClasses = `w-full ${className}`.trim();

  return (
    <div className={containerClasses}>
      <TabList
        tabs={tabs}
        activeTab={activeTab}
        onTabChange={handleTabChange}
        variant={variant}
        size={size}
        fullWidth={fullWidth}
      />
      
      <div className="mt-4">
        {tabs.map((tab) => (
          <TabPanel
            key={tab.id}
            tab={tab}
            isActive={tab.id === activeTab}
          />
        ))}
      </div>
    </div>
  );
};

const TabList: React.FC<TabListProps> = ({
  tabs,
  activeTab,
  onTabChange,
  variant,
  size,
  fullWidth
}) => {
  const tabRefs = useRef<Record<string, HTMLButtonElement | null>>({});
  
  const handleKeyDown = (event: React.KeyboardEvent, currentTabId: string): void => {
    const currentIndex = tabs.findIndex(tab => tab.id === currentTabId);
    let nextIndex = currentIndex;
    
    switch (event.key) {
      case 'ArrowLeft':
        event.preventDefault();
        nextIndex = currentIndex > 0 ? currentIndex - 1 : tabs.length - 1;
        break;
      case 'ArrowRight':
        event.preventDefault();
        nextIndex = currentIndex < tabs.length - 1 ? currentIndex + 1 : 0;
        break;
      case 'Home':
        event.preventDefault();
        nextIndex = 0;
        break;
      case 'End':
        event.preventDefault();
        nextIndex = tabs.length - 1;
        break;
      default:
        return;
    }
    
    const nextTab = tabs[nextIndex];
    if (nextTab && !nextTab.disabled) {
      onTabChange(nextTab.id);
      tabRefs.current[nextTab.id]?.focus();
    }
  };

  const listClasses = variant === 'default' || variant === 'underline' 
    ? 'border-b border-gray-200' 
    : '';

  const containerClasses = fullWidth 
    ? `flex ${listClasses}` 
    : `inline-flex ${listClasses}`;

  return (
    <div className={containerClasses} role="tablist">
      {tabs.map((tab) => (
        <TabButton
          key={tab.id}
          tab={tab}
          isActive={tab.id === activeTab}
          onClick={() => onTabChange(tab.id)}
          variant={variant}
          size={size}
          fullWidth={fullWidth}
          ref={(el) => { tabRefs.current[tab.id] = el; }}
          onKeyDown={(event) => handleKeyDown(event, tab.id)}
        />
      ))}
    </div>
  );
};

const TabButton = React.forwardRef<HTMLButtonElement, TabButtonProps & { 
  readonly onKeyDown: (event: React.KeyboardEvent) => void;
}>(({
  tab,
  isActive,
  onClick,
  variant,
  size,
  fullWidth,
  onKeyDown
}, ref) => {
  const variantStyles = TAB_VARIANTS[variant];
  const sizeClasses = TAB_SIZES[size];
  
  const baseClasses = 'inline-flex items-center justify-center font-medium focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors duration-200';
  const variantBaseClasses = variantStyles.base;
  const stateClasses = isActive ? variantStyles.active : variantStyles.inactive;
  const widthClasses = fullWidth ? 'flex-1' : '';
  const disabledClasses = tab.disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer';
  
  const buttonClasses = [
    baseClasses,
    variantBaseClasses,
    stateClasses,
    sizeClasses,
    widthClasses,
    disabledClasses
  ].filter(Boolean).join(' ');

  return (
    <button
      ref={ref}
      type="button"
      role="tab"
      aria-selected={isActive}
      aria-controls={`panel-${tab.id}`}
      id={`tab-${tab.id}`}
      tabIndex={isActive ? 0 : -1}
      disabled={tab.disabled}
      className={buttonClasses}
      onClick={() => !tab.disabled && onClick()}
      onKeyDown={onKeyDown}
    >
      {tab.icon && (
        <span className="mr-2" aria-hidden="true">
          {tab.icon}
        </span>
      )}
      <span>{tab.label}</span>
    </button>
  );
});

const TabPanel: React.FC<TabPanelProps> = ({ tab, isActive }) => {
  if (!isActive) {
    return null;
  }

  return (
    <div
      id={`panel-${tab.id}`}
      role="tabpanel"
      aria-labelledby={`tab-${tab.id}`}
      tabIndex={0}
    >
      {tab.children}
    </div>
  );
};

DiceTabs.displayName = 'DiceTabs';
TabButton.displayName = 'TabButton'; 