// JavaScript Proxy-based State Management
// Native implementation without external dependencies
// Provides reactive state management with TypeScript support

type StateListener<T> = (newState: T, prevState: T, path: string[]) => void;
type StateSelector<T, R> = (state: T) => R;
type StateUpdater<T> = (state: T) => void;

export class ProxyStateManager<T extends Record<string, any>> {
  private listeners = new Set<StateListener<T>>();
  private state: T;
  private proxy: T;
  private isUpdating = false;

  constructor(initialState: T) {
    this.state = this.deepClone(initialState);
    this.proxy = this.createProxy(this.state, []);
  }

  private deepClone<K>(obj: K): K {
    if (obj === null || typeof obj !== 'object') return obj;
    if (obj instanceof Date) return new Date(obj.getTime()) as K;
    if (Array.isArray(obj)) return obj.map(item => this.deepClone(item)) as K;
    
    const cloned = {} as K;
    for (const key in obj) {
      if (obj.hasOwnProperty(key)) {
        cloned[key] = this.deepClone(obj[key]);
      }
    }
    return cloned;
  }

  private createProxy(target: any, path: string[]): any {
    if (target === null || typeof target !== 'object') {
      return target;
    }

    return new Proxy(target, {
      get: (obj, prop) => {
        const value = obj[prop];
        
        // Return functions bound to the original object
        if (typeof value === 'function') {
          return value.bind(obj);
        }
        
        // Create nested proxies for objects and arrays
        if (typeof value === 'object' && value !== null) {
          return this.createProxy(value, [...path, String(prop)]);
        }
        
        return value;
      },
      
      set: (obj, prop, value) => {
        // Prevent updates during listener execution to avoid infinite loops
        if (this.isUpdating) {
          obj[prop] = value;
          return true;
        }

        const prevState = this.deepClone(this.state);
        obj[prop] = value;
        
        // Notify listeners of the change
        this.notifyListeners(this.state, prevState, [...path, String(prop)]);
        
        return true;
      },

      deleteProperty: (obj, prop) => {
        if (this.isUpdating) {
          delete obj[prop];
          return true;
        }

        const prevState = this.deepClone(this.state);
        delete obj[prop];
        
        this.notifyListeners(this.state, prevState, [...path, String(prop)]);
        
        return true;
      }
    });
  }

  private notifyListeners(newState: T, prevState: T, path: string[]): void {
    this.isUpdating = true;
    
    try {
      this.listeners.forEach(listener => {
        try {
          listener(newState, prevState, path);
        } catch (error) {
          console.error('Error in state listener:', error);
        }
      });
    } finally {
      this.isUpdating = false;
    }
  }

  getState(): T {
    return this.proxy;
  }

  getRawState(): T {
    return this.deepClone(this.state);
  }

  subscribe(listener: StateListener<T>): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  setState(updater: StateUpdater<T>): void {
    const prevState = this.deepClone(this.state);
    
    this.isUpdating = true;
    try {
      updater(this.proxy);
    } finally {
      this.isUpdating = false;
    }
    
    this.notifyListeners(this.state, prevState, []);
  }

  // Selector-based subscription for optimized re-renders
  subscribeWithSelector<R>(
    selector: StateSelector<T, R>,
    listener: (selectedState: R, prevSelectedState: R) => void,
    equalityFn?: (a: R, b: R) => boolean
  ): () => void {
    let selectedState = selector(this.state);
    
    const unsubscribe = this.subscribe((newState, prevState) => {
      const nextSelectedState = selector(newState);
      const prevSelectedState = selector(prevState);
      
      const isEqual = equalityFn 
        ? equalityFn(nextSelectedState, prevSelectedState)
        : nextSelectedState === prevSelectedState;
      
      if (!isEqual) {
        selectedState = nextSelectedState;
        listener(nextSelectedState, prevSelectedState);
      }
    });
    
    return unsubscribe;
  }

  // Reset state to initial values
  reset(newState?: T): void {
    const prevState = this.deepClone(this.state);
    
    if (newState) {
      this.state = this.deepClone(newState);
      this.proxy = this.createProxy(this.state, []);
    } else {
      // Reset to initial state would require storing it
      throw new Error('Reset with initial state not implemented. Provide newState parameter.');
    }
    
    this.notifyListeners(this.state, prevState, []);
  }

  // Batch multiple updates together
  batch(updater: StateUpdater<T>): void {
    this.setState(updater);
  }

  // Get current number of listeners (useful for debugging)
  getListenerCount(): number {
    return this.listeners.size;
  }

  // Debug helper to log state changes
  enableDebugMode(): () => void {
    const debugListener: StateListener<T> = (newState, prevState, path) => {
      console.group(`🔄 State Update: ${path.join('.')}`);
      console.log('Previous:', prevState);
      console.log('Current:', newState);
      console.log('Path:', path);
      console.groupEnd();
    };

    this.listeners.add(debugListener);
    
    return () => this.listeners.delete(debugListener);
  }
} 