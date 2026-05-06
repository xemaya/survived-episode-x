import { dayCycle } from '@/flow/day-cycle';
import { flow } from '@/flow/dispatcher';
import { loadEpisode } from '@/ink/loader';
import { ink } from '@/ink/runtime';
import { installKeyboardHandler } from '@/input/keyboard';
import { dialogState } from '@/render/dialog/dialog-state';
import { createPixiApp } from '@/render/pixi-app';
import { bindStageToFlow } from '@/render/stage';
import { mountOverlay } from '@/render/ui-overlay';
import { applyRunState } from '@/save/restore'; // see Step 1.15
import { save } from '@/save/system';
import { Container } from 'pixi.js';

async function main(): Promise<void> {
  const pixiRoot = document.getElementById('pixi-root');
  const overlayRoot = document.getElementById('ui-overlay');
  if (!pixiRoot || !overlayRoot) {
    throw new Error('Required DOM nodes not found');
  }
  const { app } = await createPixiApp(pixiRoot);

  const worldLayer = new Container();
  worldLayer.label = 'world';
  app.stage.addChild(worldLayer);

  // P4: try to load existing save on boot. If found, restore state and
  // resume from saved sceneState. If not, leave FSM at initial main_menu.
  // If load fails (corrupt JSON / schema mismatch), show save_corrupt dialog.
  const restored = await save.loadCurrentRun();
  if (restored) {
    applyRunState(restored);
    // QA Bug #23: morning_briefing was removed from the live day-cycle
    // (its Preact card was a P0-P4 holdover; AVG narrative covers the
    // day intro inline). Old saves can still have sceneState =
    // morning_briefing; bridge them to action_day so boot doesn't land
    // on a no-overlay state with no UI affordance.
    const initial =
      restored.sceneState.kind === 'morning_briefing'
        ? ({ kind: 'action_day', day: restored.sceneState.day, phase: 'morning' } as const)
        : restored.sceneState;
    flow.setInitialState(initial);
    console.info('[boot] restored save:', initial.kind);
  } else if (save.lastLoadError) {
    flow.setInitialState({ kind: 'save_corrupt', errorMessage: save.lastLoadError });
    console.warn('[boot] save load failed:', save.lastLoadError);
  }

  dayCycle.attach();
  bindStageToFlow({ app, worldLayer });
  mountOverlay(overlayRoot);
  installKeyboardHandler();

  // P5: load episode-1 ink story on boot. Workstation scene's mountInkDialog()
  // reads from this singleton when action_day mounts.
  try {
    await loadEpisode('episode-1');
    // T16: if a save with ink state exists, restore the runtime to that
    // position so [继续] resumes mid-episode instead of replaying intro.
    // Saves predating T16 (no inkStateJson field) fall back to a fresh
    // intro divert.
    if (restored?.inkStateJson) {
      try {
        ink.loadState(restored.inkStateJson);
        // QA Bug #11: also restore the last visible narration so the
        // dialog can pre-fill the panel on first paint instead of
        // rendering `...` when ink has nothing to drain.
        if (restored.lastNarrationText) {
          dialogState.setLastNarrationText(restored.lastNarrationText);
        }
        console.info('[boot] ink: loaded episode-1 + restored ink state');
      } catch (e) {
        console.warn('[boot] ink loadState failed; falling back to intro:', e);
        ink.divertTo('intro');
      }
    } else {
      ink.divertTo('intro');
      console.info('[boot] ink: loaded episode-1, diverted to intro knot');
    }
  } catch (err) {
    console.error('[boot] ink load failed:', err);
  }

  console.info('[boot] flow + dayCycle + overlay + keyboard + ink ready');

  // QA hook (dev only) — exposes runtime singletons for Playwright driver to
  // inspect ink state + drive selectChoice without clicking through canvas.
  // Stripped from production via import.meta.env.DEV check.
  if (import.meta.env.DEV) {
    const { sceneState } = await import('@/scene/scene-state-mirror');
    const { propRegistry } = await import('@/render/diegetic/prop-registry');
    (globalThis as { __qa?: unknown }).__qa = {
      ink,
      flow,
      save,
      app,
      sceneState,
      propRegistry,
    };
  }
}

void main();
