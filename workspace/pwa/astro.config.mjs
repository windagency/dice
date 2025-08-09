import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';
import { defineConfig } from 'astro/config';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  integrations: [react(), tailwind()],
  server: {
    host: '0.0.0.0',
    port: 3000
  },
  build: {
    assets: 'assets'
  },
  vite: {
    plugins: [
      tsconfigPaths({
        loose: true,
        root: process.cwd()
      })
    ],
    server: {
      fs: {
        allow: ['..']
      }
    },
    optimizeDeps: {
      noDiscovery: true
    }
  }
}); 