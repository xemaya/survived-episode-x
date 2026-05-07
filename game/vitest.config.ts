import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vitest/config';

// Keep vitest from picking up Playwright specs under qa/.
export default defineConfig({
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  test: {
    include: ['tests/**/*.{test,spec}.?(c|m)[jt]s?(x)'],
    exclude: ['node_modules', 'dist', 'qa/**'],
  },
});
