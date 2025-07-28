import CryptoJS from 'crypto-js';

interface SecureStorageOptions {
  encryptionKey?: string;
  storagePrefix?: string;
  expirationMs?: number;
}

interface StoredData<T> {
  data: T;
  timestamp: number;
  expiration?: number;
}

export class SecureStorage {
  private encryptionKey: string;
  private storagePrefix: string;
  private defaultExpirationMs: number;

  constructor(options: SecureStorageOptions = {}) {
    // Generate a unique encryption key based on session if not provided
    this.encryptionKey = options.encryptionKey || this.generateSessionKey();
    this.storagePrefix = options.storagePrefix || 'dice_secure_';
    this.defaultExpirationMs = options.expirationMs || 24 * 60 * 60 * 1000; // 24 hours default
  }

  /**
   * Store data with encryption
   */
  setItem<T>(key: string, value: T, expirationMs?: number): boolean {
    try {
      const storedData: StoredData<T> = {
        data: value,
        timestamp: Date.now(),
        expiration: expirationMs ? Date.now() + expirationMs : Date.now() + this.defaultExpirationMs,
      };

      const serialized = JSON.stringify(storedData);
      const encrypted = CryptoJS.AES.encrypt(serialized, this.encryptionKey).toString();
      
      localStorage.setItem(this.getStorageKey(key), encrypted);
      return true;
    } catch (error) {
      console.warn('SecureStorage: Failed to store data', { key, error: error.message });
      return false;
    }
  }

  /**
   * Retrieve and decrypt data
   */
  getItem<T>(key: string): T | null {
    try {
      const encryptedData = localStorage.getItem(this.getStorageKey(key));
      if (!encryptedData) {
        return null;
      }

      const decrypted = CryptoJS.AES.decrypt(encryptedData, this.encryptionKey);
      const serialized = decrypted.toString(CryptoJS.enc.Utf8);
      
      if (!serialized) {
        // Decryption failed - possibly wrong key or corrupted data
        this.removeItem(key);
        return null;
      }

      const storedData: StoredData<T> = JSON.parse(serialized);

      // Check expiration
      if (storedData.expiration && Date.now() > storedData.expiration) {
        this.removeItem(key);
        return null;
      }

      return storedData.data;
    } catch (error) {
      console.warn('SecureStorage: Failed to retrieve data', { key, error: error.message });
      // Clean up corrupted data
      this.removeItem(key);
      return null;
    }
  }

  /**
   * Remove encrypted data
   */
  removeItem(key: string): void {
    try {
      localStorage.removeItem(this.getStorageKey(key));
    } catch (error) {
      console.warn('SecureStorage: Failed to remove data', { key, error: error.message });
    }
  }

  /**
   * Check if key exists and is not expired
   */
  hasItem(key: string): boolean {
    return this.getItem(key) !== null;
  }

  /**
   * Clear all secure storage items
   */
  clear(): void {
    try {
      const keysToRemove: string[] = [];
      
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && key.startsWith(this.storagePrefix)) {
          keysToRemove.push(key);
        }
      }

      keysToRemove.forEach(key => localStorage.removeItem(key));
    } catch (error) {
      console.warn('SecureStorage: Failed to clear storage', { error: error.message });
    }
  }

  /**
   * Get storage statistics
   */
  getStats(): { itemCount: number; totalSize: number } {
    let itemCount = 0;
    let totalSize = 0;

    try {
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && key.startsWith(this.storagePrefix)) {
          itemCount++;
          const value = localStorage.getItem(key);
          if (value) {
            totalSize += key.length + value.length;
          }
        }
      }
    } catch (error) {
      console.warn('SecureStorage: Failed to get stats', { error: error.message });
    }

    return { itemCount, totalSize };
  }

  /**
   * Clean up expired items
   */
  cleanupExpired(): number {
    let cleanedCount = 0;

    try {
      const keysToCheck: string[] = [];
      
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && key.startsWith(this.storagePrefix)) {
          keysToCheck.push(key);
        }
      }

      keysToCheck.forEach(storageKey => {
        const originalKey = storageKey.replace(this.storagePrefix, '');
        const data = this.getItem(originalKey); // This will auto-remove expired items
        if (data === null) {
          cleanedCount++;
        }
      });
    } catch (error) {
      console.warn('SecureStorage: Failed to cleanup expired items', { error: error.message });
    }

    return cleanedCount;
  }

  private getStorageKey(key: string): string {
    return `${this.storagePrefix}${key}`;
  }

  private generateSessionKey(): string {
    // Create a unique key based on session and browser fingerprint
    const fingerprint = [
      navigator.userAgent,
      navigator.language,
      screen.width,
      screen.height,
      new Date().getTimezoneOffset(),
      sessionStorage.length,
    ].join('|');

    // Use a combination of session storage and fingerprint for the key
    const sessionId = sessionStorage.getItem('dice_session_id') || this.createSessionId();
    return CryptoJS.SHA256(fingerprint + sessionId).toString();
  }

  private createSessionId(): string {
    const sessionId = CryptoJS.lib.WordArray.random(128/8).toString();
    sessionStorage.setItem('dice_session_id', sessionId);
    return sessionId;
  }
}

// Export a default instance for convenience
export const secureStorage = new SecureStorage(); 