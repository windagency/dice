import React from 'react';
import { COMPONENT_TOKENS } from 'ui/tokens/design-tokens';

type CardVariant = 'default' | 'elevated' | 'outlined' | 'flat';
type CardPadding = 'none' | 'sm' | 'md' | 'lg';

interface CardProps {
  readonly variant?: CardVariant;
  readonly padding?: CardPadding;
  readonly className?: string;
  readonly children: React.ReactNode;
}

interface CardHeaderProps {
  readonly className?: string;
  readonly children: React.ReactNode;
}

interface CardBodyProps {
  readonly className?: string;
  readonly children: React.ReactNode;
}

interface CardFooterProps {
  readonly className?: string;
  readonly children: React.ReactNode;
}

// Token-driven card variants
const CARD_VARIANTS: Record<CardVariant, string> = {
  default: 'bg-white shadow-sm border border-gray-200',
  elevated: 'bg-white shadow-lg border border-gray-100',
  outlined: 'bg-white border-2 border-gray-300',
  flat: 'bg-white'
};

// Token-driven card padding
const CARD_PADDING: Record<CardPadding, string> = {
  none: '',
  sm: 'p-4',
  md: 'p-6',
  lg: 'p-8'
};

export const DiceCard: React.FC<CardProps> = ({
  variant = 'default',
  padding = 'md',
  className = '',
  children
}) => {
  const baseClasses = 'rounded-lg';
  const variantClasses = CARD_VARIANTS[variant];
  const paddingClasses = CARD_PADDING[padding];
  
  const cardClasses = [
    baseClasses,
    variantClasses,
    paddingClasses,
    className
  ].filter(Boolean).join(' ');

  return (
    <div className={cardClasses}>
      {children}
    </div>
  );
};

export const DiceCardHeader: React.FC<CardHeaderProps> = ({
  className = '',
  children
}) => {
  const headerClasses = `border-b border-gray-200 pb-4 mb-4 ${className}`.trim();
  
  return (
    <div className={headerClasses}>
      {children}
    </div>
  );
};

export const DiceCardBody: React.FC<CardBodyProps> = ({
  className = '',
  children
}) => {
  return (
    <div className={className}>
      {children}
    </div>
  );
};

export const DiceCardFooter: React.FC<CardFooterProps> = ({
  className = '',
  children
}) => {
  const footerClasses = `border-t border-gray-200 pt-4 mt-4 ${className}`.trim();
  
  return (
    <div className={footerClasses}>
      {children}
    </div>
  );
};

DiceCard.displayName = 'DiceCard';
DiceCardHeader.displayName = 'DiceCardHeader';
DiceCardBody.displayName = 'DiceCardBody';
DiceCardFooter.displayName = 'DiceCardFooter'; 