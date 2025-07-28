import React, { useState, useRef, useEffect } from 'react';

type TooltipPosition = 'top' | 'bottom' | 'left' | 'right';
type TooltipTrigger = 'hover' | 'focus' | 'click';

interface TooltipProps {
  readonly content: React.ReactNode;
  readonly position?: TooltipPosition;
  readonly trigger?: TooltipTrigger;
  readonly delay?: number;
  readonly className?: string;
  readonly children: React.ReactElement;
}

const TOOLTIP_POSITIONS: Record<TooltipPosition, {
  tooltip: string;
  arrow: string;
}> = {
  top: {
    tooltip: 'bottom-full left-1/2 transform -translate-x-1/2 mb-2',
    arrow: 'top-full left-1/2 transform -translate-x-1/2 border-l-transparent border-r-transparent border-b-transparent border-t-gray-900'
  },
  bottom: {
    tooltip: 'top-full left-1/2 transform -translate-x-1/2 mt-2',
    arrow: 'bottom-full left-1/2 transform -translate-x-1/2 border-l-transparent border-r-transparent border-t-transparent border-b-gray-900'
  },
  left: {
    tooltip: 'right-full top-1/2 transform -translate-y-1/2 mr-2',
    arrow: 'left-full top-1/2 transform -translate-y-1/2 border-t-transparent border-b-transparent border-r-transparent border-l-gray-900'
  },
  right: {
    tooltip: 'left-full top-1/2 transform -translate-y-1/2 ml-2',
    arrow: 'right-full top-1/2 transform -translate-y-1/2 border-t-transparent border-b-transparent border-l-transparent border-r-gray-900'
  }
};

export const DiceTooltip: React.FC<TooltipProps> = ({
  content,
  position = 'top',
  trigger = 'hover',
  delay = 0,
  className = '',
  children
}) => {
  const [isVisible, setIsVisible] = useState(false);
  const [timeoutId, setTimeoutId] = useState<NodeJS.Timeout | null>(null);
  const tooltipRef = useRef<HTMLDivElement>(null);

  const positionClasses = TOOLTIP_POSITIONS[position];

  const showTooltip = (): void => {
    if (timeoutId) {
      clearTimeout(timeoutId);
    }

    const id = setTimeout(() => {
      setIsVisible(true);
    }, delay);

    setTimeoutId(id);
  };

  const hideTooltip = (): void => {
    if (timeoutId) {
      clearTimeout(timeoutId);
      setTimeoutId(null);
    }
    setIsVisible(false);
  };

  const toggleTooltip = (): void => {
    if (isVisible) {
      hideTooltip();
    } else {
      showTooltip();
    }
  };

  useEffect(() => {
    return () => {
      if (timeoutId) {
        clearTimeout(timeoutId);
      }
    };
  }, [timeoutId]);

  useEffect(() => {
    if (trigger === 'click' && isVisible) {
      const handleClickOutside = (event: MouseEvent): void => {
        if (tooltipRef.current && !tooltipRef.current.contains(event.target as Node)) {
          hideTooltip();
        }
      };

      document.addEventListener('mousedown', handleClickOutside);
      return () => document.removeEventListener('mousedown', handleClickOutside);
    }
  }, [isVisible, trigger]);

  const getEventHandlers = () => {
    switch (trigger) {
      case 'hover':
        return {
          onMouseEnter: showTooltip,
          onMouseLeave: hideTooltip,
          onFocus: showTooltip,
          onBlur: hideTooltip
        };
      case 'focus':
        return {
          onFocus: showTooltip,
          onBlur: hideTooltip
        };
      case 'click':
        return {
          onClick: toggleTooltip
        };
      default:
        return {};
    }
  };

  const tooltipId = `tooltip-${Math.random().toString(36).substr(2, 9)}`;

  const clonedChild = React.cloneElement(children, {
    ...getEventHandlers(),
    'aria-describedby': isVisible ? tooltipId : undefined,
    ...children.props
  });

  const tooltipClasses = [
    'absolute z-50 px-2 py-1 text-sm text-white bg-gray-900 rounded shadow-lg pointer-events-none',
    'max-w-xs break-words',
    positionClasses.tooltip,
    className
  ].filter(Boolean).join(' ');

  const arrowClasses = [
    'absolute w-0 h-0 border-4',
    positionClasses.arrow
  ].join(' ');

  return (
    <div className="relative inline-block" ref={tooltipRef}>
      {clonedChild}
      
      {isVisible && (
        <div
          id={tooltipId}
          role="tooltip"
          className={tooltipClasses}
        >
          {content}
          <div className={arrowClasses} />
        </div>
      )}
    </div>
  );
};

DiceTooltip.displayName = 'DiceTooltip'; 