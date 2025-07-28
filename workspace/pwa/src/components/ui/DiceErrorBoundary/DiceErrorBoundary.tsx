import React, { Component } from 'react';
import type { ErrorInfo, ReactNode } from 'react';
import { DiceButton } from '../DiceButton';
import { DiceCard, DiceCardBody } from '../DiceCard';

interface ErrorBoundaryState {
  readonly hasError: boolean;
  readonly error: Error | null;
  readonly errorInfo: ErrorInfo | null;
}

interface ErrorBoundaryProps {
  readonly children: ReactNode;
  readonly fallback?: ReactNode;
  readonly onError?: (error: Error, errorInfo: ErrorInfo) => void;
  readonly showErrorDetails?: boolean;
}

interface ErrorDisplayProps {
  readonly error: Error;
  readonly errorInfo: ErrorInfo;
  readonly onRetry: () => void;
  readonly showDetails: boolean;
}

export class DiceErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null
    };
  }

  static getDerivedStateFromError(error: Error): Partial<ErrorBoundaryState> {
    return {
      hasError: true,
      error
    };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo): void {
    this.setState({
      error,
      errorInfo
    });
    
    this.props.onError?.(error, errorInfo);
    
    // Log error for debugging in development
    if (process.env.NODE_ENV === 'development') {
      console.error('ErrorBoundary caught an error:', error, errorInfo);
    }
  }

  handleRetry = (): void => {
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null
    });
  };

  render(): ReactNode {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      if (this.state.error && this.state.errorInfo) {
        return (
          <ErrorDisplay
            error={this.state.error}
            errorInfo={this.state.errorInfo}
            onRetry={this.handleRetry}
            showDetails={this.props.showErrorDetails ?? false}
          />
        );
      }

      return (
        <DefaultErrorFallback onRetry={this.handleRetry} />
      );
    }

    return this.props.children;
  }
}

const ErrorDisplay: React.FC<ErrorDisplayProps> = ({
  error,
  errorInfo,
  onRetry,
  showDetails
}) => {
  return (
    <div className="min-h-[200px] flex items-center justify-center p-4">
      <DiceCard variant="outlined" className="max-w-md w-full">
        <DiceCardBody>
          <div className="text-center">
            <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-100 mb-4">
              <svg
                className="h-6 w-6 text-red-600"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                aria-hidden="true"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"
                />
              </svg>
            </div>
            
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              Something went wrong
            </h3>
            
            <p className="text-sm text-gray-500 mb-4">
              An unexpected error occurred. Please try again.
            </p>
            
            <DiceButton onClick={onRetry} variant="primary">
              Try Again
            </DiceButton>
            
            {showDetails && (
              <details className="mt-4 text-left">
                <summary className="cursor-pointer text-sm font-medium text-gray-700 hover:text-gray-900">
                  Show Error Details
                </summary>
                <div className="mt-2 p-3 bg-gray-50 rounded-md text-xs font-mono text-gray-800 overflow-auto max-h-40">
                  <div className="font-bold text-red-600 mb-2">
                    {error.name}: {error.message}
                  </div>
                  <div className="whitespace-pre-wrap">
                    {error.stack}
                  </div>
                  {errorInfo.componentStack && (
                    <div className="mt-2 pt-2 border-t border-gray-200">
                      <div className="font-bold mb-1">Component Stack:</div>
                      <div className="whitespace-pre-wrap">
                        {errorInfo.componentStack}
                      </div>
                    </div>
                  )}
                </div>
              </details>
            )}
          </div>
        </DiceCardBody>
      </DiceCard>
    </div>
  );
};

const DefaultErrorFallback: React.FC<{ readonly onRetry: () => void }> = ({ onRetry }) => {
  return (
    <div className="min-h-[200px] flex items-center justify-center p-4">
      <DiceCard variant="outlined" className="max-w-md w-full">
        <DiceCardBody>
          <div className="text-center">
            <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-100 mb-4">
              <svg
                className="h-6 w-6 text-red-600"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                aria-hidden="true"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"
                />
              </svg>
            </div>
            
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              Something went wrong
            </h3>
            
            <p className="text-sm text-gray-500 mb-4">
              An unexpected error occurred. Please try again.
            </p>
            
            <DiceButton onClick={onRetry} variant="primary">
              Try Again
            </DiceButton>
          </div>
        </DiceCardBody>
      </DiceCard>
    </div>
  );
};

(DiceErrorBoundary as any).displayName = 'DiceErrorBoundary'; 