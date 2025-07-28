import React from 'react';

type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'ghost' | 'outline';
type ButtonSize = 'sm' | 'md' | 'lg' | 'xl';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  readonly variant?: ButtonVariant;
  readonly size?: ButtonSize;
  readonly isLoading?: boolean;
  readonly leftIcon?: React.ReactNode;
  readonly rightIcon?: React.ReactNode;
  readonly fullWidth?: boolean;
  readonly children: React.ReactNode;
}

const BUTTON_VARIANTS: Record<ButtonVariant, string> = {
  primary: 'bg-blue-600 hover:bg-blue-700 focus:ring-blue-500 text-white shadow-sm',
  secondary: 'bg-gray-100 hover:bg-gray-200 focus:ring-gray-500 text-gray-900 shadow-sm',
  danger: 'bg-red-600 hover:bg-red-700 focus:ring-red-500 text-white shadow-sm',
  ghost: 'hover:bg-gray-100 focus:ring-gray-500 text-gray-700',
  outline: 'border border-gray-300 hover:bg-gray-50 focus:ring-blue-500 text-gray-700 shadow-sm'
};

const BUTTON_SIZES: Record<ButtonSize, string> = {
  sm: 'px-3 py-2 text-sm',
  md: 'px-4 py-2 text-sm',
  lg: 'px-4 py-2 text-base',
  xl: 'px-6 py-3 text-base'
};

const DISABLED_STYLES = 'disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-current';
const LOADING_STYLES = 'cursor-wait';

export const DiceButton: React.FC<ButtonProps> = ({
  variant = 'primary',
  size = 'md',
  isLoading = false,
  leftIcon,
  rightIcon,
  fullWidth = false,
  disabled,
  className = '',
  children,
  ...props
}) => {
  const baseClasses = 'inline-flex items-center justify-center font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 transition-colors duration-200';
  
  const variantClasses = BUTTON_VARIANTS[variant];
  const sizeClasses = BUTTON_SIZES[size];
  const widthClasses = fullWidth ? 'w-full' : '';
  const stateClasses = isLoading ? LOADING_STYLES : '';
  
  const buttonClasses = [
    baseClasses,
    variantClasses,
    sizeClasses,
    widthClasses,
    stateClasses,
    DISABLED_STYLES,
    className
  ].filter(Boolean).join(' ');

  const isButtonDisabled = disabled || isLoading;

  return (
    <button
      className={buttonClasses}
      disabled={isButtonDisabled}
      aria-disabled={isButtonDisabled}
      {...props}
    >
      {isLoading && (
        <svg
          className="animate-spin -ml-1 mr-2 h-4 w-4"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          aria-hidden="true"
        >
          <circle
            className="opacity-25"
            cx="12"
            cy="12"
            r="10"
            stroke="currentColor"
            strokeWidth="4"
          />
          <path
            className="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
          />
        </svg>
      )}
      
      {!isLoading && leftIcon && (
        <span className="mr-2" aria-hidden="true">
          {leftIcon}
        </span>
      )}
      
      <span>{children}</span>
      
      {!isLoading && rightIcon && (
        <span className="ml-2" aria-hidden="true">
          {rightIcon}
        </span>
      )}
    </button>
  );
};

DiceButton.displayName = 'DiceButton'; 