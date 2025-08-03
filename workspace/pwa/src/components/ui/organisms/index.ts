// Organisms - Full UI sections composed of molecules and atoms
// Organize internal layout and state handling when necessary

export { DiceModal, DiceModalHeader, DiceModalBody, DiceModalFooter } from './DiceModal';
export { DiceTabs } from './DiceTabs';
export { DiceErrorBoundary } from './DiceErrorBoundary';

// Re-export types for convenience
export type { ModalProps, ModalHeaderProps, ModalBodyProps, ModalFooterProps } from './DiceModal/DiceModal';
export type { TabsProps, TabItem } from './DiceTabs/DiceTabs';
export type { ErrorBoundaryProps } from './DiceErrorBoundary/DiceErrorBoundary'; 