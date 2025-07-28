// React Hook for JavaScript Proxy State Management
// Provides React integration with optimized re-renders
// Full TypeScript support with state and selector types

import { useEffect, useReducer, useRef, useCallback } from 'react';
import type { ProxyStateManager } from './ProxyStateManager';

type StateSelector<T, R> = (state: T) => R;
type StateUpdater<T> = (state: T) => void;

// Main hook for accessing full state
export function useProxyState<T extends Record<string, any>>(
  stateManager: ProxyStateManager<T>
): [T, (updater: StateUpdater<T>) => void] {
  const [, forceUpdate] = useReducer((x: number) => x + 1, 0);
  const stateRef = useRef(stateManager.getState());
  const listenerRef = useRef<(() => void) | null>(null);

  useEffect(() => {
    // Clean up previous listener
    if (listenerRef.current) {
      listenerRef.current();
    }

    // Subscribe to state changes
    listenerRef.current = stateManager.subscribe((newState, prevState) => {
      // Only re-render if state reference actually changed
      if (newState !== stateRef.current) {
        stateRef.current = newState;
        forceUpdate();
      }
    });

    // Update ref with current state
    stateRef.current = stateManager.getState();

    return () => {
      if (listenerRef.current) {
        listenerRef.current();
        listenerRef.current = null;
      }
    };
  }, [stateManager]);

  const setState = useCallback(
    (updater: StateUpdater<T>) => {
      stateManager.setState(updater);
    },
    [stateManager]
  );

  return [stateRef.current, setState];
}

// Optimized hook for selecting specific parts of state
export function useProxySelector<T extends Record<string, any>, R>(
  stateManager: ProxyStateManager<T>,
  selector: StateSelector<T, R>,
  equalityFn?: (a: R, b: R) => boolean
): R {
  const [, forceUpdate] = useReducer((x: number) => x + 1, 0);
  const selectedStateRef = useRef<R>(selector(stateManager.getState()));
  const selectorRef = useRef(selector);
  const equalityFnRef = useRef(equalityFn);
  const listenerRef = useRef<(() => void) | null>(null);

  // Update refs when dependencies change
  selectorRef.current = selector;
  equalityFnRef.current = equalityFn;

  useEffect(() => {
    // Clean up previous listener
    if (listenerRef.current) {
      listenerRef.current();
    }

    // Subscribe with selector optimization
    listenerRef.current = stateManager.subscribeWithSelector(
      selectorRef.current,
      (selectedState) => {
        selectedStateRef.current = selectedState;
        forceUpdate();
      },
      equalityFnRef.current
    );

    // Update ref with current selected state
    selectedStateRef.current = selectorRef.current(stateManager.getState());

    return () => {
      if (listenerRef.current) {
        listenerRef.current();
        listenerRef.current = null;
      }
    };
  }, [stateManager]);

  return selectedStateRef.current;
}

// Hook for actions-only access (doesn't cause re-renders)
export function useProxyActions<T extends Record<string, any>>(
  stateManager: ProxyStateManager<T>
): (updater: StateUpdater<T>) => void {
  return useCallback(
    (updater: StateUpdater<T>) => {
      stateManager.setState(updater);
    },
    [stateManager]
  );
}

// Hook for batched updates
export function useProxyBatch<T extends Record<string, any>>(
  stateManager: ProxyStateManager<T>
): (updater: StateUpdater<T>) => void {
  return useCallback(
    (updater: StateUpdater<T>) => {
      stateManager.batch(updater);
    },
    [stateManager]
  );
}

// Development hook for debugging state changes
export function useProxyDebug<T extends Record<string, any>>(
  stateManager: ProxyStateManager<T>,
  enabled: boolean = false
): void {
  useEffect(() => {
    if (!enabled) return;

    const disableDebug = stateManager.enableDebugMode();
    
    return disableDebug;
  }, [stateManager, enabled]);
}

// Shallow equality function for common use cases
export function shallowEqual<T>(a: T, b: T): boolean {
  if (a === b) return true;
  
  if (typeof a !== 'object' || typeof b !== 'object' || a === null || b === null) {
    return false;
  }

  const keysA = Object.keys(a);
  const keysB = Object.keys(b);

  if (keysA.length !== keysB.length) return false;

  for (const key of keysA) {
    if (!keysB.includes(key) || (a as any)[key] !== (b as any)[key]) {
      return false;
    }
  }

  return true;
}

// Custom hook for form state management
export function useProxyForm<T extends Record<string, any>>(
  stateManager: ProxyStateManager<T>,
  formSelector: StateSelector<T, any>
) {
  const formState = useProxySelector(stateManager, formSelector, shallowEqual);
  const updateForm = useProxyActions(stateManager);

  const setField = useCallback(
    (fieldPath: string, value: any) => {
      updateForm((state) => {
        const pathParts = fieldPath.split('.');
        let current = state as any;
        
        for (let i = 0; i < pathParts.length - 1; i++) {
          current = current[pathParts[i]];
        }
        
        current[pathParts[pathParts.length - 1]] = value;
      });
    },
    [updateForm]
  );

  const resetForm = useCallback(
    (defaultValues: Partial<T>) => {
      updateForm((state) => {
        Object.assign(state, defaultValues);
      });
    },
    [updateForm]
  );

  return {
    formState,
    setField,
    resetForm,
    updateForm
  };
} 