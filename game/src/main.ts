import { createPixiApp } from '@/render/pixi-app';

async function main(): Promise<void> {
  const root = document.getElementById('pixi-root');
  if (!root) throw new Error('#pixi-root not found in index.html');
  await createPixiApp(root);
  console.info('[boot] PixiJS application ready');
}

void main();
