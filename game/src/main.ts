import { dayCycle } from '@/flow/day-cycle';
import { flow } from '@/flow/dispatcher';
import { installKeyboardHandler } from '@/input/keyboard';
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
  const restored = await save.loadCurrentRun();
  if (restored) {
    applyRunState(restored);
    flow.request(restored.sceneState);
    console.info('[boot] restored save:', restored.sceneState.kind);
  } else if (save.lastLoadError) {
    console.warn('[boot] save load failed:', save.lastLoadError);
    // Save-corrupt dialog wired in Task 8
  }

  dayCycle.attach();
  bindStageToFlow({ app, worldLayer });
  mountOverlay(overlayRoot);
  installKeyboardHandler();

  console.info('[boot] flow + dayCycle + overlay + keyboard ready');
}

void main();
