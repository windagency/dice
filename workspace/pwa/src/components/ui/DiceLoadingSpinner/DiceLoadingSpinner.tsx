import React from 'react';

type SpinnerSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl';
type SpinnerVariant = 'primary' | 'secondary' | 'white';

interface LoadingSpinnerProps {
  readonly size?: SpinnerSize;
  readonly variant?: SpinnerVariant;
  readonly className?: string;
  readonly label?: string;
}

const SPINNER_SIZES: Record<SpinnerSize, string> = {
  xs: 'h-3 w-3',
  sm: 'h-4 w-4',
  md: 'h-6 w-6',
  lg: 'h-8 w-8',
  xl: 'h-12 w-12'
};

const SPINNER_VARIANTS: Record<SpinnerVariant, string> = {
  primary: 'text-blue-600',
  secondary: 'text-gray-600',
  white: 'text-white'
};

export const DiceLoadingSpinner: React.FC<LoadingSpinnerProps> = ({
  size = 'md',
  variant = 'primary',
  className = '',
  label = 'Loading...'
}) => {
  const sizeClasses = SPINNER_SIZES[size];
  const variantClasses = SPINNER_VARIANTS[variant];
  
  const spinnerClasses = [
    'animate-spin',
    sizeClasses,
    variantClasses,
    className
  ].filter(Boolean).join(' ');

  return (
    <div 
      className="inline-flex items-center justify-center"
      role="status"
      aria-label={label}
    >
      <svg
        className={spinnerClasses}
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
      <span className="sr-only">{label}</span>
    </div>
  );
};

DiceLoadingSpinner.displayName = 'DiceLoadingSpinner'; 