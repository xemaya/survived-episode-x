// Vite plugin: watch design/vertical-slice/*.ink, recompile + HMR on change.
//
// Wired into game/vite.config.ts via `inkPlugin()`.
//
// During `vite dev`:
//   - buildStart: compile all .ink files once (so first page load has fresh JSON)
//   - watcher: register .ink files in dev server's watcher
//   - handleHotUpdate: on .ink change → recompile that file → broadcast full-reload
//     (we don't do surgical HMR for ink content — full reload is fine since story state
//      is reset anyway when source changes mid-session)

import { INK_DIR, OUT_DIR, compileInkFile, getInkFiles } from './ink-build.mjs';

export function inkPlugin() {
  return {
    name: 'survived-ink-build',
    enforce: 'pre',

    async buildStart() {
      const files = await getInkFiles();
      for (const f of files) {
        try {
          await compileInkFile(f, OUT_DIR);
        } catch (err) {
          // In dev, log but don't kill the build — user can fix and HMR will retry
          this.warn(`ink build failed for ${f}: ${err.message}`);
        }
      }
    },

    configureServer(server) {
      // Add INK_DIR to Vite's file watcher (it watches game/ by default, INK_DIR is sibling)
      server.watcher.add(`${INK_DIR}/*.ink`);
    },

    async handleHotUpdate({ file, server }) {
      if (!file.endsWith('.ink')) return;

      try {
        await compileInkFile(file, OUT_DIR);
        // Trigger full page reload — runtime will refetch the JSON
        server.ws.send({ type: 'full-reload' });
        return [];
      } catch (err) {
        // Send error to browser overlay
        server.ws.send({
          type: 'error',
          err: {
            message: `ink compile failed: ${err.message}`,
            stack: err.stack || '',
            plugin: 'survived-ink-build',
          },
        });
        return [];
      }
    },
  };
}
