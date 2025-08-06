import { v4 as uuidv4 } from 'uuid';

const FLUENT_BIT_ENDPOINT = 'http://localhost:2020';
const BATCH_SIZE = 20;
const BATCH_INTERVAL_MS = 10000;

enum LogLevel {
  INFO = 'info',
  WARN = 'warn',
  ERROR = 'error',
  DEBUG = 'debug',
}

interface LogEntry {
  timestamp: string;
  level: LogLevel;
  service: string;
  correlationId: string;
  sessionId?: string;
  userId?: string;
  component?: string;
  action?: string;
  message: string;
  metadata: Record<string, unknown>;
  tags: string[];
  securityEvent?: Record<string, unknown>;
  owaspCategory?: string;
}

class BrowserLogger {
  private static instance: BrowserLogger;
  private logQueue: LogEntry[] = [];
  private correlationId: string;
  private flushInterval: NodeJS.Timeout | null = null;

  private constructor() {
    this.correlationId = this.getSessionId();
    this.initialize();
  }

  public static getInstance(): BrowserLogger {
    if (!BrowserLogger.instance) {
      BrowserLogger.instance = new BrowserLogger();
    }
    return BrowserLogger.instance;
  }

  private initialize(): void {
    if (typeof window !== 'undefined') {
      this.startFlushInterval();
      window.addEventListener('error', this.handleGlobalError.bind(this));
      window.addEventListener(
        'unhandledrejection',
        this.handleUnhandledRejection.bind(this),
      );
      window.addEventListener('click', this.handleUserInteraction.bind(this), true);
      window.addEventListener('beforeunload', this.flushQueue.bind(this));

      // Track navigation changes
      this.trackNavigation();
    }
  }

  private getSessionId(): string {
    if (typeof sessionStorage !== 'undefined') {
      let sessionId = sessionStorage.getItem('correlationId');
      if (!sessionId) {
        sessionId = uuidv4();
        sessionStorage.setItem('correlationId', sessionId);
      }
      return sessionId;
    }
    return uuidv4();
  }

  private createLogEntry(
    level: LogLevel,
    message: string,
    metadata: Record<string, unknown> = {},
    tags: string[] = ['pwa'],
    component?: string,
    action?: string,
  ): LogEntry {
    return {
      timestamp: new Date().toISOString(),
      level,
      service: 'pwa-frontend',
      message,
      correlationId: this.correlationId,
      sessionId: this.correlationId,
      userId: 'anonymous',
      component,
      action,
      metadata,
      tags,
    };
  }

  private enqueue(logEntry: LogEntry): void {
    this.logQueue.push(logEntry);
    if (this.logQueue.length >= BATCH_SIZE) {
      this.flushQueue();
    }
  }

  private async flushQueue(): Promise<void> {
    if (this.logQueue.length === 0) {
      return;
    }

    const logsToSend = [...this.logQueue];
    this.logQueue = [];

    try {
      await navigator.sendBeacon(
        FLUENT_BIT_ENDPOINT,
        JSON.stringify(logsToSend),
      );
    } catch (error) {
      console.error('Failed to send logs:', error);
      // If beacon fails, re-queue for next attempt
      this.logQueue.unshift(...logsToSend);
    }
  }

  private startFlushInterval(): void {
    if (this.flushInterval) {
      clearInterval(this.flushInterval);
    }
    this.flushInterval = setInterval(
      () => this.flushQueue(),
      BATCH_INTERVAL_MS,
    );
  }

  private stopFlushInterval(): void {
    if (this.flushInterval) {
      clearInterval(this.flushInterval);
      this.flushInterval = null;
    }
  }

  private handleGlobalError(event: ErrorEvent): void {
    this.error('Unhandled Error', {
      error: {
        message: event.message,
        filename: event.filename,
        lineno: event.lineno,
        colno: event.colno,
        stack: event.error?.stack,
      },
    }, ['pwa', 'error', 'unhandled'], 'ErrorHandler', 'handleGlobalError');
  }

  private handleUnhandledRejection(event: PromiseRejectionEvent): void {
    this.error('Unhandled Promise Rejection', {
      reason: event.reason instanceof Error ? event.reason.stack : String(event.reason),
    }, ['pwa', 'error', 'unhandled'], 'ErrorHandler', 'handleUnhandledRejection');
  }

  private handleUserInteraction(event: MouseEvent): void {
    const targetElement = event.target as HTMLElement;
    const elementDetails = {
      tagName: targetElement.tagName,
      id: targetElement.id,
      className: targetElement.className,
      text: targetElement.textContent?.trim().slice(0, 50),
    };

    this.info(`User clicked on ${targetElement.tagName}`, {
      element: elementDetails,
      position: {
        x: event.clientX,
        y: event.clientY,
      },
    }, ['pwa', 'interaction', 'click'], 'UserInteraction', 'handleClick');
  }

  public info(message: string, metadata?: Record<string, unknown>, tags?: string[], component?: string, action?: string): void {
    this.enqueue(this.createLogEntry(LogLevel.INFO, message, metadata, tags, component, action));
  }

  public warn(message: string, metadata?: Record<string, unknown>, tags?: string[], component?: string, action?: string): void {
    this.enqueue(this.createLogEntry(LogLevel.WARN, message, metadata, tags, component, action));
  }

  public error(message: string, metadata?: Record<string, unknown>, tags?: string[], component?: string, action?: string): void {
    this.enqueue(this.createLogEntry(LogLevel.ERROR, message, metadata, tags, component, action));
  }

  public debug(message: string, metadata?: Record<string, unknown>, tags?: string[], component?: string, action?: string): void {
    this.enqueue(this.createLogEntry(LogLevel.DEBUG, message, metadata, tags, component, action));
  }

  private trackNavigation(): void {
    // Track initial page load
    this.info('Page loaded', {
      url: window.location.href,
      referrer: document.referrer,
      userAgent: navigator.userAgent,
    }, ['pwa', 'navigation', 'page-load'], 'Navigation', 'pageLoad');

    // Track navigation changes using History API
    const originalPushState = history.pushState;
    const originalReplaceState = history.replaceState;

    history.pushState = (...args) => {
      originalPushState.apply(history, args);
      this.info('Navigation occurred', {
        url: window.location.href,
        method: 'pushState',
      }, ['pwa', 'navigation', 'push-state'], 'Navigation', 'pushState');
    };

    history.replaceState = (...args) => {
      originalReplaceState.apply(history, args);
      this.info('Navigation occurred', {
        url: window.location.href,
        method: 'replaceState',
      }, ['pwa', 'navigation', 'replace-state'], 'Navigation', 'replaceState');
    };

    // Track popstate events
    window.addEventListener('popstate', () => {
      this.info('Navigation occurred', {
        url: window.location.href,
        method: 'popstate',
      }, ['pwa', 'navigation', 'popstate'], 'Navigation', 'popstate');
    });
  }

  public destroy(): void {
    this.stopFlushInterval();
    window.removeEventListener('error', this.handleGlobalError);
    window.removeEventListener('unhandledrejection', this.handleUnhandledRejection);
    window.removeEventListener('click', this.handleUserInteraction, true);
    window.removeEventListener('beforeunload', this.flushQueue);
  }
}

export const browserLogger = BrowserLogger.getInstance();
