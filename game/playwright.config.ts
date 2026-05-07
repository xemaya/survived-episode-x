import { defineConfig } from '@playwright/test';

// QA harness for P5 demo. Drives an externally-running Vite dev server
// on http://localhost:1420 (assumes `pnpm dev` is already running). Does
// NOT start its own server — keeps the user's HMR session intact.

export default defineConfig({
  testDir: './qa',
  testMatch: '**/*.spec.ts',
  fullyParallel: false,
  workers: 1,
  reporter: [['list']],
  use: {
    baseURL: 'http://localhost:1420',
    headless: true,
    screenshot: 'on',
    video: 'off',
    trace: 'retain-on-failure',
    viewport: { width: 1280, height: 720 },
  },
  outputDir: './qa/output',
});
