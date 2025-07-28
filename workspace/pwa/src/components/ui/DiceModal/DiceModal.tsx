import React, { useEffect, useRef } from 'react';

type ModalSize = 'sm' | 'md' | 'lg' | 'xl' | 'full';

interface ModalProps {
  readonly isOpen: boolean;
  readonly onClose: () => void;
  readonly size?: ModalSize;
  readonly title?: string;
  readonly showCloseButton?: boolean;
  readonly closeOnBackdrop?: boolean;
  readonly closeOnEscape?: boolean;
  readonly className?: string;
  readonly children: React.ReactNode;
}

interface ModalHeaderProps {
  readonly title?: string;
  readonly onClose?: () => void;
  readonly showCloseButton?: boolean;
  readonly children?: React.ReactNode;
}

interface ModalBodyProps {
  readonly className?: string;
  readonly children: React.ReactNode;
}

interface ModalFooterProps {
  readonly className?: string;
  readonly children: React.ReactNode;
}

const MODAL_SIZES: Record<ModalSize, string> = {
  sm: 'max-w-md',
  md: 'max-w-lg',
  lg: 'max-w-2xl',
  xl: 'max-w-4xl',
  full: 'max-w-full mx-4'
};

export const DiceModal: React.FC<ModalProps> = ({
  isOpen,
  onClose,
  size = 'md',
  title,
  showCloseButton = true,
  closeOnBackdrop = true,
  closeOnEscape = true,
  className = '',
  children
}) => {
  const modalRef = useRef<HTMLDivElement>(null);
  const previousActiveElement = useRef<HTMLElement | null>(null);

  useEffect(() => {
    if (isOpen) {
      previousActiveElement.current = document.activeElement as HTMLElement;
      modalRef.current?.focus();
      
      if (closeOnEscape) {
        const handleEscape = (event: KeyboardEvent): void => {
          if (event.key === 'Escape') {
            onClose();
          }
        };
        
        document.addEventListener('keydown', handleEscape);
        return () => document.removeEventListener('keydown', handleEscape);
      }
    } else {
      previousActiveElement.current?.focus();
    }
  }, [isOpen, closeOnEscape, onClose]);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    
    return () => {
      document.body.style.overflow = '';
    };
  }, [isOpen]);

  if (!isOpen) {
    return null;
  }

  const handleBackdropClick = (event: React.MouseEvent<HTMLDivElement>): void => {
    if (event.target === event.currentTarget && closeOnBackdrop) {
      onClose();
    }
  };

  const sizeClasses = MODAL_SIZES[size];
  
  const modalClasses = [
    'relative bg-white rounded-lg shadow-xl transform transition-all',
    sizeClasses,
    className
  ].filter(Boolean).join(' ');

  return (
    <div 
      className="fixed inset-0 z-50 overflow-y-auto"
      aria-labelledby={title ? 'modal-title' : undefined}
      aria-modal="true"
      role="dialog"
    >
      <div 
        className="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0"
        onClick={handleBackdropClick}
      >
        <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" />
        
        <span className="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">
          &#8203;
        </span>
        
        <div
          ref={modalRef}
          className={modalClasses}
          tabIndex={-1}
        >
          {(title || showCloseButton) && (
            <DiceModalHeader title={title} onClose={onClose} showCloseButton={showCloseButton} />
          )}
          
          {children}
        </div>
      </div>
    </div>
  );
};

export const DiceModalHeader: React.FC<ModalHeaderProps> = ({
  title,
  onClose,
  showCloseButton = true,
  children
}) => {
  return (
    <div className="px-6 py-4 border-b border-gray-200">
      <div className="flex items-center justify-between">
        <div className="flex-1">
          {title && (
            <h3 id="modal-title" className="text-lg font-medium text-gray-900">
              {title}
            </h3>
          )}
          {children}
        </div>
        
        {showCloseButton && onClose && (
          <button
            type="button"
            className="ml-4 text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500 rounded-md"
            onClick={onClose}
            aria-label="Close modal"
          >
            <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        )}
      </div>
    </div>
  );
};

export const DiceModalBody: React.FC<ModalBodyProps> = ({
  className = '',
  children
}) => {
  const bodyClasses = `px-6 py-4 ${className}`.trim();
  
  return (
    <div className={bodyClasses}>
      {children}
    </div>
  );
};

export const DiceModalFooter: React.FC<ModalFooterProps> = ({
  className = '',
  children
}) => {
  const footerClasses = `px-6 py-4 border-t border-gray-200 flex justify-end space-x-3 ${className}`.trim();
  
  return (
    <div className={footerClasses}>
      {children}
    </div>
  );
};

DiceModal.displayName = 'DiceModal';
DiceModalHeader.displayName = 'DiceModalHeader';
DiceModalBody.displayName = 'DiceModalBody';
DiceModalFooter.displayName = 'DiceModalFooter'; 