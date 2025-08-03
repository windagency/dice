// Design Tokens for Atomic Design System
// Centralized design decisions for consistent theming

export const DESIGN_TOKENS = {
  // Colors
  colors: {
    primary: {
      50: '#eff6ff',
      100: '#dbeafe',
      200: '#bfdbfe',
      300: '#93c5fd',
      400: '#60a5fa',
      500: '#3b82f6',
      600: '#2563eb',
      700: '#1d4ed8',
      800: '#1e40af',
      900: '#1e3a8a',
    },
    secondary: {
      50: '#f8fafc',
      100: '#f1f5f9',
      200: '#e2e8f0',
      300: '#cbd5e1',
      400: '#94a3b8',
      500: '#64748b',
      600: '#475569',
      700: '#334155',
      800: '#1e293b',
      900: '#0f172a',
    },
    success: {
      50: '#f0fdf4',
      100: '#dcfce7',
      200: '#bbf7d0',
      300: '#86efac',
      400: '#4ade80',
      500: '#22c55e',
      600: '#16a34a',
      700: '#15803d',
      800: '#166534',
      900: '#14532d',
    },
    danger: {
      50: '#fef2f2',
      100: '#fee2e2',
      200: '#fecaca',
      300: '#fca5a5',
      400: '#f87171',
      500: '#ef4444',
      600: '#dc2626',
      700: '#b91c1c',
      800: '#991b1b',
      900: '#7f1d1d',
    },
    warning: {
      50: '#fffbeb',
      100: '#fef3c7',
      200: '#fde68a',
      300: '#fcd34d',
      400: '#fbbf24',
      500: '#f59e0b',
      600: '#d97706',
      700: '#b45309',
      800: '#92400e',
      900: '#78350f',
    },
  },

  // Typography
  typography: {
    fontFamily: {
      sans: ['Inter', 'system-ui', 'sans-serif'],
      mono: ['JetBrains Mono', 'monospace'],
    },
    fontSize: {
      xs: '0.75rem',
      sm: '0.875rem',
      base: '1rem',
      lg: '1.125rem',
      xl: '1.25rem',
      '2xl': '1.5rem',
      '3xl': '1.875rem',
      '4xl': '2.25rem',
    },
    fontWeight: {
      normal: '400',
      medium: '500',
      semibold: '600',
      bold: '700',
    },
    lineHeight: {
      tight: '1.25',
      normal: '1.5',
      relaxed: '1.75',
    },
  },

  // Spacing
  spacing: {
    xs: '0.25rem',
    sm: '0.5rem',
    md: '1rem',
    lg: '1.5rem',
    xl: '2rem',
    '2xl': '3rem',
    '3xl': '4rem',
  },

  // Border Radius
  borderRadius: {
    none: '0',
    sm: '0.125rem',
    md: '0.375rem',
    lg: '0.5rem',
    xl: '0.75rem',
    full: '9999px',
  },

  // Shadows
  shadows: {
    sm: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
    md: '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)',
    lg: '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
    xl: '0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)',
  },

  // Transitions
  transitions: {
    fast: '150ms ease-in-out',
    normal: '200ms ease-in-out',
    slow: '300ms ease-in-out',
  },

  // Z-Index
  zIndex: {
    dropdown: '1000',
    sticky: '1020',
    fixed: '1030',
    modal: '1040',
    popover: '1050',
    tooltip: '1060',
  },
} as const;

// Component-specific tokens
export const COMPONENT_TOKENS = {
  button: {
    variants: {
      primary: {
        bg: DESIGN_TOKENS.colors.primary[600],
        hover: DESIGN_TOKENS.colors.primary[700],
        focus: DESIGN_TOKENS.colors.primary[500],
        text: 'white',
      },
      secondary: {
        bg: DESIGN_TOKENS.colors.secondary[100],
        hover: DESIGN_TOKENS.colors.secondary[200],
        focus: DESIGN_TOKENS.colors.secondary[500],
        text: DESIGN_TOKENS.colors.secondary[900],
      },
      danger: {
        bg: DESIGN_TOKENS.colors.danger[600],
        hover: DESIGN_TOKENS.colors.danger[700],
        focus: DESIGN_TOKENS.colors.danger[500],
        text: 'white',
      },
      ghost: {
        bg: 'transparent',
        hover: DESIGN_TOKENS.colors.secondary[100],
        focus: DESIGN_TOKENS.colors.secondary[500],
        text: DESIGN_TOKENS.colors.secondary[700],
      },
      outline: {
        bg: 'transparent',
        hover: DESIGN_TOKENS.colors.secondary[50],
        focus: DESIGN_TOKENS.colors.primary[500],
        text: DESIGN_TOKENS.colors.secondary[700],
        border: DESIGN_TOKENS.colors.secondary[300],
      },
    },
    sizes: {
      sm: {
        padding: `${DESIGN_TOKENS.spacing.sm} ${DESIGN_TOKENS.spacing.md}`,
        fontSize: DESIGN_TOKENS.typography.fontSize.sm,
      },
      md: {
        padding: `${DESIGN_TOKENS.spacing.md} ${DESIGN_TOKENS.spacing.lg}`,
        fontSize: DESIGN_TOKENS.typography.fontSize.sm,
      },
      lg: {
        padding: `${DESIGN_TOKENS.spacing.md} ${DESIGN_TOKENS.spacing.lg}`,
        fontSize: DESIGN_TOKENS.typography.fontSize.base,
      },
      xl: {
        padding: `${DESIGN_TOKENS.spacing.lg} ${DESIGN_TOKENS.spacing.xl}`,
        fontSize: DESIGN_TOKENS.typography.fontSize.base,
      },
    },
  },

  input: {
    variants: {
      default: {
        border: DESIGN_TOKENS.colors.secondary[300],
        focus: DESIGN_TOKENS.colors.primary[500],
      },
      error: {
        border: DESIGN_TOKENS.colors.danger[500],
        focus: DESIGN_TOKENS.colors.danger[500],
      },
      success: {
        border: DESIGN_TOKENS.colors.success[500],
        focus: DESIGN_TOKENS.colors.success[500],
      },
    },
    sizes: {
      sm: {
        padding: `${DESIGN_TOKENS.spacing.sm} ${DESIGN_TOKENS.spacing.md}`,
        fontSize: DESIGN_TOKENS.typography.fontSize.sm,
      },
      md: {
        padding: `${DESIGN_TOKENS.spacing.md}`,
        fontSize: DESIGN_TOKENS.typography.fontSize.sm,
      },
      lg: {
        padding: `${DESIGN_TOKENS.spacing.md} ${DESIGN_TOKENS.spacing.lg}`,
        fontSize: DESIGN_TOKENS.typography.fontSize.base,
      },
    },
  },

  card: {
    variants: {
      default: {
        bg: 'white',
        border: DESIGN_TOKENS.colors.secondary[200],
        shadow: DESIGN_TOKENS.shadows.sm,
      },
      elevated: {
        bg: 'white',
        border: DESIGN_TOKENS.colors.secondary[100],
        shadow: DESIGN_TOKENS.shadows.lg,
      },
      outlined: {
        bg: 'white',
        border: `2px solid ${DESIGN_TOKENS.colors.secondary[300]}`,
        shadow: 'none',
      },
      flat: {
        bg: 'white',
        border: 'none',
        shadow: 'none',
      },
    },
    padding: {
      none: '0',
      sm: DESIGN_TOKENS.spacing.lg,
      md: DESIGN_TOKENS.spacing.xl,
      lg: DESIGN_TOKENS.spacing['2xl'],
    },
  },
} as const;

// Utility function to get token value
export const getToken = (path: string): string => {
  const keys = path.split('.');
  let value: any = DESIGN_TOKENS;
  
  for (const key of keys) {
    value = value[key];
    if (value === undefined) {
      throw new Error(`Token not found: ${path}`);
    }
  }
  
  return value;
};

// Type exports for design tokens
export type DesignTokens = typeof DESIGN_TOKENS;
export type ComponentTokens = typeof COMPONENT_TOKENS; 