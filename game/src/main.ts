import { dayCycle } from '@/flow/day-cycle';
import { installKeyboardHandler } from '@/input/keyboard';
import { createPixiApp } from '@/render/pixi-app';
import { bindStageToFlow } from '@/render/stage';
import { mountOverlay } from '@/render/ui-overlay';
import { Container } from 'pixi.js';

async function main(): Promise<void> {
  const pixiRoot = document.getElementById('pixi-root');
  const overlayRoot = document.getElementById('ui-overlay');
  if (!pixiRoot || !overlayRoot) {
    throw new Error('Required DOM nodes (#pixi-root, #ui-overlay) not found in index.html');
  }
  const { app } = await createPixiApp(pixiRoot);

  const worldLayer = new Container();
  worldLayer.label = 'world';
  app.stage.addChild(worldLayer);

  // Day-cycle controller subscribes to AP depletion, drives recap/review
  // transitions. Must be attached BEFORE the player can spend cards.
  dayCycle.attach();

  bindStageToFlow({ app, worldLayer });
  mountOverlay(overlayRoot);
  installKeyboardHandler();

  console.info('[boot] flow + dayCycle + overlay + keyboard ready');
}

void main();
