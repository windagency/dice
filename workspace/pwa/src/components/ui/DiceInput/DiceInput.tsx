import React, { forwardRef } from 'react';

type InputSize = 'sm' | 'md' | 'lg';
type InputVariant = 'default' | 'error' | 'success';

interface InputProps extends Omit<React.InputHTMLAttributes<HTMLInputElement>, 'size'> {
  readonly label?: string;
  readonly helperText?: string;
  readonly errorMessage?: string;
  readonly size?: InputSize;
  readonly variant?: InputVariant;
  readonly leftIcon?: React.ReactNode;
  readonly rightIcon?: React.ReactNode;
  readonly isRequired?: boolean;
  readonly isDisabled?: boolean;
  readonly fullWidth?: boolean;
}

const INPUT_SIZES: Record<InputSize, string> = {
  sm: 'px-3 py-2 text-sm',
  md: 'px-3 py-3 text-sm',
  lg: 'px-4 py-3 text-base'
};

const INPUT_VARIANTS: Record<InputVariant, string> = {
  default: 'border-gray-300 focus:ring-blue-500 focus:border-blue-500',
  error: 'border-red-500 focus:ring-red-500 focus:border-red-500',
  success: 'border-green-500 focus:ring-green-500 focus:border-green-500'
};

const DISABLED_STYLES = 'disabled:bg-gray-50 disabled:text-gray-500 disabled:cursor-not-allowed';

export const DiceInput = forwardRef<HTMLInputElement, InputProps>(({
  label,
  helperText,
  errorMessage,
  size = 'md',
  variant = 'default',
  leftIcon,
  rightIcon,
  isRequired = false,
  isDisabled = false,
  fullWidth = true,
  className = '',
  id,
  ...props
}, ref) => {
  const inputId = id || `input-${Math.random().toString(36).substr(2, 9)}`;
  const helperTextId = `${inputId}-helper`;
  const errorId = `${inputId}-error`;
  
  const finalVariant = errorMessage ? 'error' : variant;
  
  const baseClasses = 'block border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-0 transition-colors duration-200';
  const sizeClasses = INPUT_SIZES[size];
  const variantClasses = INPUT_VARIANTS[finalVariant];
  const widthClasses = fullWidth ? 'w-full' : '';
  
  const inputClasses = [
    baseClasses,
    sizeClasses,
    variantClasses,
    widthClasses,
    DISABLED_STYLES,
    leftIcon ? 'pl-10' : '',
    rightIcon ? 'pr-10' : '',
    className
  ].filter(Boolean).join(' ');

  const containerClasses = fullWidth ? 'w-full' : 'inline-block';

  return (
    <div className={containerClasses}>
      {label && (
        <label 
          htmlFor={inputId}
          className="block text-sm font-medium text-gray-700 mb-1"
        >
          {label}
          {isRequired && (
            <span className="text-red-500 ml-1" aria-label="required">
              *
            </span>
          )}
        </label>
      )}
      
      <div className="relative">
        {leftIcon && (
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <span className="text-gray-400" aria-hidden="true">
              {leftIcon}
            </span>
          </div>
        )}
        
        <input
          ref={ref}
          id={inputId}
          disabled={isDisabled}
          required={isRequired}
          className={inputClasses}
          aria-invalid={!!errorMessage}
          aria-describedby={`${helperText ? helperTextId : ''} ${errorMessage ? errorId : ''}`.trim() || undefined}
          {...props}
        />
        
        {rightIcon && (
          <div className="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
            <span className={`${errorMessage ? 'text-red-400' : 'text-gray-400'}`} aria-hidden="true">
              {rightIcon}
            </span>
          </div>
        )}
      </div>
      
      {errorMessage && (
        <p id={errorId} className="mt-2 text-sm text-red-600" role="alert">
          {errorMessage}
        </p>
      )}
      
      {!errorMessage && helperText && (
        <p id={helperTextId} className="mt-2 text-sm text-gray-500">
          {helperText}
        </p>
      )}
    </div>
  );
});

DiceInput.displayName = 'DiceInput'; 