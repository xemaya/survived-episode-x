import { createPixiApp } from '@/render/pixi-app';
import { bindStageToFlow } from '@/render/stage';
import { Container } from 'pixi.js';

async function main(): Promise<void> {
  const root = document.getElementById('pixi-root');
  if (!root) throw new Error('#pixi-root not found in index.html');
  const { app } = await createPixiApp(root);

  // Single world-layer container. Scene mounters add/remove children here.
  const worldLayer = new Container();
  worldLayer.label = 'world';
  app.stage.addChild(worldLayer);

  bindStageToFlow({ app, worldLayer });

  console.info('[boot] flow bound to stage; initial state:', 'main_menu');
}

void main();
