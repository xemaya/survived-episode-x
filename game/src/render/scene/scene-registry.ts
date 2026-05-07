// T-1 (W1 P1): scene BG registry + tag-driven transitions.
//
// Ink emits `# scene: <id>` tags as the narrative changes location
// (break_room / cafeteria / meeting_room / etc). Each id resolves to
// a BG sprite URL; the registry handles loading + 200 ms fade
// crossfade swap. Per-scene props (PropRegistry scope='scene') and
// NPCs (npcRegistry) already auto-unmount on `# scene:` change via
// existing listeners — this module is purely about the visual
// backdrop.
//
// W5 deliverable list (all under public/sprites/backgrounds/):
//   workstation_closeup, tea_room, meeting_room, hallway, boss_office,
//   mom_kitchen_endgame, office_floor_top, kpi_review, main_menu.
//
// Scene ids without a registered BG fall back to leaving the current
// BG in place (warning logged). Designer / W5 can add entries
// incrementally in `SCENE_BG_TABLE` below.

import { Assets, type Container, Graphics, Sprite } from 'pixi.js';

interface SceneBgSpec {
  /** Path under public/ (Vite serves at root). */
  url: string;
  /** Optional uniform scale-mode override; defaults to 'linear'. */
  scaleMode?: 'linear' | 'nearest';
}

export const SCENE_BG_TABLE: Readonly<Record<string, SceneBgSpec>> = {
  workstation: { url: 'sprites/backgrounds/workstation_closeup.png' },
  break_room: { url: 'sprites/backgrounds/tea_room.png' },
  // Some episodes refer to break room as `tea_room` directly.
  tea_room: { url: 'sprites/backgrounds/tea_room.png' },
  cafeteria: { url: 'sprites/backgrounds/office_floor_top.png' },
  // Cafeteria fallback shares office_floor_top until W5 ships a
  // dedicated cafeteria asset.
  meeting_room: { url: 'sprites/backgrounds/meeting_room.png' },
  hallway: { url: 'sprites/backgrounds/hallway.png' },
  reception: { url: 'sprites/backgrounds/hallway.png' },
  // Boss office (王总监 1-on-1 / push-down scenes).
  boss_office: { url: 'sprites/backgrounds/boss_office.png' },
  monitor_modal: { url: 'sprites/backgrounds/kpi_review.png' },
  endgame: { url: 'sprites/backgrounds/mom_kitchen_endgame.png' },
  home_phone: { url: 'sprites/backgrounds/mom_kitchen_endgame.png' },
};

const FADE_MS = 200;
const CANVAS_W = 640;
const CANVAS_H = 360;

class SceneRegistry {
  private parent: Container | null = null;
  private currentSprite: Sprite | null = null;
  private currentId: string | null = null;
  /** A black overlay used for the crossfade between BG sprites. Lives
   * above the BG layer so the fade-out side covers the old sprite
   * while the new one mounts beneath. */
  private fadeLayer: Graphics | null = null;
  private inFlight: Promise<void> | null = null;

  attach(parent: Container): void {
    this.parent = parent;
    if (!this.fadeLayer) {
      const g = new Graphics();
      g.rect(0, 0, CANVAS_W, CANVAS_H);
      g.fill({ color: 0x000000, alpha: 1 });
      g.alpha = 0; // start transparent
      g.label = 'scene-fade';
      parent.addChild(g);
      this.fadeLayer = g;
    }
  }

  /** Initial mount — like transitionTo but skips the fade-out half so
   * the player sees the first BG as soon as boot completes. */
  async mountInitial(id: string): Promise<void> {
    if (!this.parent) return;
    const spec = SCENE_BG_TABLE[id];
    if (!spec) {
      console.warn('[scene-registry] no BG for initial scene:', id);
      return;
    }
    const sprite = await this.loadBgSprite(spec);
    this.parent.addChildAt(sprite, 0);
    this.currentSprite = sprite;
    this.currentId = id;
  }

  /** Crossfade to the BG for `id`. No-op if id matches the current
   * scene. Concurrent calls coalesce — the latest target wins. */
  async transitionTo(id: string): Promise<void> {
    if (!this.parent) return;
    if (this.currentId === id) return;
    const spec = SCENE_BG_TABLE[id];
    if (!spec) {
      console.warn('[scene-registry] no BG registered for scene:', id);
      return;
    }
    // Serialize transitions so a rapid-fire `# scene:` chain doesn't
    // overlap fades. Each call awaits the prior one; the registry
    // never races with itself.
    const prior = this.inFlight ?? Promise.resolve();
    this.inFlight = (async () => {
      await prior;
      await this.runTransition(id, spec);
    })();
    return this.inFlight;
  }

  private async runTransition(id: string, spec: SceneBgSpec): Promise<void> {
    if (!this.parent || !this.fadeLayer) return;
    // Phase 1: fade IN the black overlay (covers the old BG).
    await tweenAlpha(this.fadeLayer, 0, 1, FADE_MS);

    // Swap sprite under the cover.
    if (this.currentSprite) this.currentSprite.destroy();
    const sprite = await this.loadBgSprite(spec);
    this.parent.addChildAt(sprite, 0);
    this.currentSprite = sprite;
    this.currentId = id;

    // Phase 2: fade OUT the cover.
    await tweenAlpha(this.fadeLayer, 1, 0, FADE_MS);
  }

  private async loadBgSprite(spec: SceneBgSpec): Promise<Sprite> {
    const tex = await Assets.load(spec.url);
    tex.source.scaleMode = spec.scaleMode ?? 'linear';
    const sprite = new Sprite(tex);
    sprite.label = 'scene-bg';
    sprite.anchor.set(0.5);
    sprite.x = CANVAS_W / 2;
    sprite.y = CANVAS_H / 2;
    const sx = CANVAS_W / sprite.texture.width;
    const sy = CANVAS_H / sprite.texture.height;
    sprite.scale.set(Math.max(sx, sy));
    return sprite;
  }

  detach(): void {
    if (this.currentSprite) {
      this.currentSprite.destroy();
      this.currentSprite = null;
    }
    if (this.fadeLayer) {
      this.fadeLayer.destroy();
      this.fadeLayer = null;
    }
    this.currentId = null;
    this.parent = null;
  }
}

export const sceneRegistry = new SceneRegistry();

/** Promise-based linear alpha tween over `durationMs`. Resolves when
 * the target alpha is reached. Uses requestAnimationFrame; no Pixi
 * ticker dependency so the registry stays decoupled from the app. */
function tweenAlpha(
  node: { alpha: number },
  from: number,
  to: number,
  durationMs: number,
): Promise<void> {
  return new Promise((resolve) => {
    const start = performance.now();
    const tick = (now: number) => {
      const t = Math.min(1, (now - start) / durationMs);
      node.alpha = from + (to - from) * t;
      if (t < 1) {
        requestAnimationFrame(tick);
      } else {
        node.alpha = to;
        resolve();
      }
    };
    requestAnimationFrame(tick);
  });
}
