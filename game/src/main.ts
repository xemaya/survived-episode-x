import { createPixiApp } from '@/render/pixi-app';
import { Assets, Sprite } from 'pixi.js';

// Relative path (no leading slash) so it resolves correctly against both
// http://localhost:1420/ in dev and Tauri's tauri:// scheme in release.
// A leading-slash absolute path becomes "tauri://sprites/..." with host=
// "sprites" under Tauri 2's URL resolution, which 404s.
const PLAYER_IDLE_URL = 'sprites/character/player_idle_anchor.png';

async function main(): Promise<void> {
  const root = document.getElementById('pixi-root');
  if (!root) throw new Error('#pixi-root not found in index.html');
  const { app } = await createPixiApp(root);

  const texture = await Assets.load(PLAYER_IDLE_URL);
  texture.source.scaleMode = 'nearest';
  const sprite = new Sprite(texture);
  sprite.anchor.set(0.5);
  sprite.x = app.screen.width / 2;
  sprite.y = app.screen.height / 2;
  // Scale large source PNG (1024×1024) down to a reasonable on-canvas size.
  // The art is reference-resolution; pixel-perfect downscale to ~128 px tall.
  const targetHeight = 200;
  sprite.scale.set(targetHeight / texture.height);
  app.stage.addChild(sprite);

  console.info('[boot] sprite mounted:', PLAYER_IDLE_URL);
}

void main();
