import { defineConfig } from 'vite';
import { fileURLToPath } from 'node:url';

export default defineConfig({
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  server: {
    port: 1420,
    strictPort: true,
  },
  clearScreen: false,
  build: {
    target: 'safari15',
    sourcemap: true,
    minify: 'esbuild',
    chunkSizeWarningLimit: 2000,
  },
});
