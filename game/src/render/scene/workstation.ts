import type { SceneState } from '@/flow/scene-state';
import { Assets, Sprite } from 'pixi.js';
import type { StageContext } from '../stage';

// Static layout for P1 — these sprites just sit there. P2 binds them
// to AP / KPI / day so they actually mean something visually.
//
// Logical canvas is 640×360. Coordinates assume a desk surface
// roughly the bottom 2/3 of the canvas, props clustered around it.

interface PropSpec {
  url: string;
  x: number;
  y: number;
  scale: number;
  label: string;
}

const PROPS: ReadonlyArray<PropSpec> = [
  // Calendar — top-left wall mount
  { url: 'sprites/hud/calendar_month_day_1.png', x: 50, y: 50, scale: 0.12, label: 'calendar' },
  // Monitor — center, on desk
  { url: 'sprites/hud/monitor_idle.png', x: 320, y: 160, scale: 0.18, label: 'monitor' },
  // Sticky note — to the right of monitor
  { url: 'sprites/hud/sticky_blank.png', x: 470, y: 200, scale: 0.1, label: 'sticky' },
  // Mug — bottom-left of desk
  { url: 'sprites/hud/coffee_full.png', x: 130, y: 260, scale: 0.1, label: 'mug' },
];

export async function mountWorkstation(_state: SceneState, ctx: StageContext): Promise<() => void> {
  const sprites: Sprite[] = [];
  for (const spec of PROPS) {
    const tex = await Assets.load(spec.url);
    tex.source.scaleMode = 'nearest';
    const sprite = new Sprite(tex);
    sprite.label = spec.label;
    sprite.anchor.set(0.5);
    sprite.x = spec.x;
    sprite.y = spec.y;
    sprite.scale.set(spec.scale);
    ctx.worldLayer.addChild(sprite);
    sprites.push(sprite);
  }
  return () => {
    for (const sprite of sprites) {
      sprite.destroy();
    }
  };
}
