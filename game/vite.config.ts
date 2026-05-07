import { fileURLToPath } from 'node:url';
import preact from '@preact/preset-vite';
import { type PluginOption, defineConfig } from 'vite';
// @ts-ignore — JS module without .d.ts
import { inkPlugin } from './scripts/ink-vite-plugin.mjs';

// GitHub Pages serves under /<repo-name>/ path. Use VITE_BASE env var to set base for production builds.
// Tauri / dev server uses '/' (no base). Set VITE_BASE='/survived-episode-x/' in CI for GH Pages deploy.
const base = process.env.VITE_BASE ?? '/';

export default defineConfig({
  base,
  plugins: [preact(), inkPlugin() as PluginOption],
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
