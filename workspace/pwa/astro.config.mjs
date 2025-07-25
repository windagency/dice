import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  integrations: [react(), tailwind()],
  server: {
    host: '0.0.0.0',
    port: 3000
  },
  build: {
    assets: 'assets'
  }
}); 