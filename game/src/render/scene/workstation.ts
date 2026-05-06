import { energy } from '@/economy/energy';
import { kpi } from '@/economy/kpi';
import { flow } from '@/flow/dispatcher';
import type { SceneState } from '@/flow/scene-state';
import { mountInkDialog } from '@/render/dialog/ink-dialog';
import { mountCalendarWidget } from '@/render/diegetic/calendar-widget';
import { createPropEntity } from '@/render/diegetic/prop-entity';
import { propRegistry } from '@/render/diegetic/prop-registry';
import { installPropTagHandler } from '@/render/diegetic/prop-tag-handler';
import { installSceneStateTagHandler, sceneState } from '@/scene/scene-state-mirror';
import { Assets, Container, Graphics, Sprite, Text } from 'pixi.js';
import type { StageContext } from '../stage';

// P5 demo flag: hide P0-P4 legacy HUD elements (KPI text, 下班 button).
// These were the card-era debug surfaces. New diegetic UI per concept
// images will reintroduce equivalents (mug = state, banking app = money
// etc) in P6. Toggle to true to bring them back for debugging.
// Bug #27: the AP-slot row is gone (AP system deleted).
const SHOW_LEGACY_HUD = false;

// Layout constants (640×360 logical canvas).
// Layout constants for the (now-removed) AP-slot HUD row are gone with
// Bug #27. STICKY_X / STICKY_Y / STICKY_SIZE / STICKY_GAP only had
// meaning while the slot row was alive.

interface PropSpec {
  url: string;
  x: number;
  y: number;
  scale: number;
  label: string;
}

const STATIC_PROPS: ReadonlyArray<PropSpec> = [
  // Sticky note — to the right of monitor (decorative; AP slot row drawn separately)
  { url: 'sprites/hud/sticky_blank.png', x: 470, y: 200, scale: 0.1, label: 'sticky' },
  // Mug removed from STATIC_PROPS — now a dynamic 5-frame energy binding below.
];

// Monitor KPI states. The 5th (gameover grey) is achieved via tint on
// monitor_critical, not a separate sprite.
const MONITOR_FRAMES = {
  idle: 'sprites/hud/monitor_idle.png',
  working: 'sprites/hud/monitor_working.png',
  warning: 'sprites/hud/monitor_warning.png',
  critical: 'sprites/hud/monitor_critical.png',
} as const;

function pickMonitorFrame(actualKpi: number, threshold: number): keyof typeof MONITOR_FRAMES {
  const ratio = actualKpi / threshold;
  if (ratio < 0.5) return 'idle';
  if (ratio < 1.0) return 'working';
  if (ratio < 1.5) return 'warning';
  return 'critical';
}

export async function mountWorkstation(_state: SceneState, ctx: StageContext): Promise<() => void> {
  const teardowns: Array<() => void> = [];

  // ── Workstation BG (full canvas, mounted first so everything else layers on top) ──
  try {
    const bgTex = await Assets.load('sprites/backgrounds/workstation_closeup.png');
    bgTex.source.scaleMode = 'linear';
    const bg = new Sprite(bgTex);
    bg.label = 'workstation-bg';
    bg.anchor.set(0.5);
    bg.x = 320;
    bg.y = 180;
    // Scale to cover 640×360 canvas
    const sx = 640 / bg.texture.width;
    const sy = 360 / bg.texture.height;
    bg.scale.set(Math.max(sx, sy));
    ctx.worldLayer.addChild(bg);
    teardowns.push(() => bg.destroy());
  } catch (err) {
    console.warn('[workstation] BG load failed; falling back to dark canvas:', err);
  }

  // ── Static props ────────────────────────────────────────────────────────
  for (const spec of STATIC_PROPS) {
    const tex = await Assets.load(spec.url);
    tex.source.scaleMode = 'linear';
    const sprite = new Sprite(tex);
    sprite.label = spec.label;
    sprite.anchor.set(0.5);
    sprite.x = spec.x;
    sprite.y = spec.y;
    sprite.scale.set(spec.scale);
    ctx.worldLayer.addChild(sprite);
    teardowns.push(() => sprite.destroy());
  }

  // ── Monitor (KPI binding, swappable sprite) ─────────────────────────────
  const monitorContainer = new Container();
  monitorContainer.label = 'monitor';
  monitorContainer.x = 320;
  monitorContainer.y = 160;
  ctx.worldLayer.addChild(monitorContainer);

  let currentMonitorSprite: Sprite | null = null;
  const swapMonitorTo = async (key: keyof typeof MONITOR_FRAMES) => {
    const tex = await Assets.load(MONITOR_FRAMES[key]);
    tex.source.scaleMode = 'linear';
    if (currentMonitorSprite) currentMonitorSprite.destroy();
    const s = new Sprite(tex);
    s.anchor.set(0.5);
    s.scale.set(0.18);
    monitorContainer.addChild(s);
    currentMonitorSprite = s;
  };
  await swapMonitorTo(pickMonitorFrame(kpi.actualKpi, kpi.monthlyThreshold));

  const unsubKpi = kpi.onChanged((actual) => {
    void swapMonitorTo(pickMonitorFrame(actual, kpi.monthlyThreshold));
  });
  teardowns.push(() => {
    unsubKpi();
    monitorContainer.destroy({ children: true });
  });

  // ── Calendar (Q-U Bug #26: programmatic Pixi widget) ────────────────────
  // Replaces the legacy 4-frame sprite mount. The widget self-binds to
  // calendar.onDateChanged and redraws when the day advances. Position
  // matches the prior sprite anchor (centered around (70, 60) → top-
  // left at (30, 20)). See calendar-widget.ts for the visual spec.
  const calendarHandle = mountCalendarWidget(ctx.worldLayer, { x: 30, y: 20 });
  teardowns.push(calendarHandle.destroy);

  // ── Mug (energy binding, swappable sprite) ──────────────────────────────
  // 5 tiers per energy level. tier = floor(energy / 20), clamped 0..4.
  // tier 4 = full (80-100), tier 0 = empty (0-19) + stain ring (P5).
  const mugContainer = new Container();
  mugContainer.label = 'mug';
  mugContainer.x = 130;
  mugContainer.y = 260;
  ctx.worldLayer.addChild(mugContainer);

  const MUG_FRAMES = [
    'sprites/hud/coffee_empty.png', // tier 0 [0-19]
    'sprites/hud/coffee_empty.png', // tier 1 [20-39] — placeholder; ideal coffee_quarter.png if present
    'sprites/hud/coffee_half.png', // tier 2 [40-59]
    'sprites/hud/coffee_three_quarter.png', // tier 3 [60-79]
    'sprites/hud/coffee_full.png', // tier 4 [80-100]
  ] as const;

  function pickMugFrame(value: number): string {
    const tier = Math.max(0, Math.min(4, Math.floor(value / 20)));
    return MUG_FRAMES[tier] ?? MUG_FRAMES[0];
  }

  let currentMugSprite: Sprite | null = null;
  const swapMugTo = async (url: string) => {
    const tex = await Assets.load(url);
    tex.source.scaleMode = 'linear';
    if (currentMugSprite) currentMugSprite.destroy();
    const s = new Sprite(tex);
    s.anchor.set(0.5);
    s.scale.set(0.1);
    mugContainer.addChild(s);
    currentMugSprite = s;
  };
  await swapMugTo(pickMugFrame(energy.current));

  const unsubEnergy = energy.onChanged((value) => {
    void swapMugTo(pickMugFrame(value));
  });
  teardowns.push(() => {
    unsubEnergy();
    mugContainer.destroy({ children: true });
  });

  // ── KPI HUD readout (P0-P4 legacy debug, gated by SHOW_LEGACY_HUD) ──────
  // Bug #27: the AP slot row is gone (AP system deleted). KPI text below
  // stays for debugging when the flag flips on.
  if (SHOW_LEGACY_HUD) {
    // KPI numeric readout (debug)
    const kpiText = new Text({
      text: '',
      style: {
        fontFamily: 'PingFang SC, -apple-system, sans-serif',
        fontSize: 10,
        fill: 0xe8e0cc,
      },
    });
    kpiText.anchor.set(0.5, 0);
    kpiText.x = 320;
    kpiText.y = 200;
    ctx.worldLayer.addChild(kpiText);

    const drawKpi = () => {
      kpiText.text = `KPI ${kpi.actualKpi} / ${kpi.monthlyThreshold} (cap ${Math.round(kpi.capacityNow)})`;
    };
    const unsubKpiText = kpi.onChanged(() => drawKpi());
    drawKpi();
    teardowns.push(() => {
      unsubKpiText();
      kpiText.destroy();
    });
  }

  // ── Tag-driven diegetic props (P5 T05-mini + T03-prop) ─────────────────
  // Register prop entities that respond to ink `# prop:` tags. The
  // existing P0-P4 binding-driven props (mug ← energy, monitor ← kpi,
  // calendar ← currentDay) keep their direct subscriptions above and
  // are NOT routed through the registry yet — migration to the registry
  // can happen incrementally once `# prop: mug_*` etc. land in ink.
  try {
    const fruitBowl = await createPropEntity(ctx.worldLayer, {
      id: 'fruit_bowl',
      states: {
        apple: 'sprites/hud/fruit_bowl_apple.png',
        strawberry: 'sprites/hud/fruit_bowl_strawberry.png',
        empty: 'sprites/hud/fruit_bowl_empty.png',
      },
      initialState: 'apple',
      x: 510,
      y: 250,
      scale: 0.12,
      // Bug #15 fix (Option C — Pixi-side crop): the source PNGs are
      // 341×844 with "Front" label baked at the top edge and a "9:00"
      // timestamp at the bottom. Symmetric ~80px crop top/bottom hides
      // both without shifting the visible content's vertical center
      // relative to the sprite's anchor (0.5, 0.5). Drop this field
      // when W5 lands Option A (re-cut sheets without labels).
      cropEdges: { top: 80, bottom: 80 },
    });
    propRegistry.register(fruitBowl);
    teardowns.push(() => {
      propRegistry.unregister(fruitBowl.id);
      fruitBowl.destroy();
    });

    const phone = await createPropEntity(ctx.worldLayer, {
      id: 'phone',
      states: {
        face_down: 'sprites/hud/phone_face_down.png',
        face_up: 'sprites/hud/phone_face_up.png',
        with_badge: 'sprites/hud/phone_with_badge.png',
      },
      initialState: 'face_down',
      x: 380,
      y: 252,
      scale: 0.1,
    });
    propRegistry.register(phone);
    teardowns.push(() => {
      propRegistry.unregister(phone.id);
      phone.destroy();
    });
  } catch (err) {
    console.warn('[workstation] prop registration failed:', err);
  }

  const teardownPropTags = installPropTagHandler();
  teardowns.push(teardownPropTags);

  // Scene / NPC / time / weather tag stubs (closes QA Bug #8 fully).
  // Cache the latest tag value in a shared mirror so future scene
  // composers (T04) and NPC sprite slots (T05/T06) can subscribe
  // without re-registering on the global TagDispatcher.
  const teardownSceneStateTags = installSceneStateTagHandler();
  teardowns.push(teardownSceneStateTags);

  // Bug #14 fix: when ink emits a different `# scene:` value, hide all
  // scope='scene' props. They auto-re-show via PropEntity.setState's
  // visible=true on the next `# prop:` tag emission. Permanent props
  // (mug/monitor/calendar bound to game state) are unaffected.
  const teardownSceneScopeHide = sceneState.on('scene', () => {
    propRegistry.hideScopedTo('scene');
  });
  teardowns.push(teardownSceneScopeHide);

  // ── Card hand removed (P5: replaced by ink-driven event/choice runtime) ──
  // Action_day no longer presents a card hand. Dialog + choices come from the
  // ink runtime via game/src/render/dialog/* and game/src/render/choice/*.

  // ── Ink dialog (P5 minimal demo) ────────────────────────────────────────
  // Mounts a center-screen text panel + choice buttons that read from the
  // ink runtime singleton. Production will replace with NPC-anchored speech
  // bubbles + diegetic choice props.
  const inkDialog = mountInkDialog(ctx.worldLayer);
  inkDialog.start();
  teardowns.push(inkDialog.destroy);

  // ── Q-Y (Bug #38) — pause hamburger button (top-right) ──────────────────
  // Always-visible 16×16 menu button so the player can return to main
  // menu without hitting Esc. Click → triggers the same pause SceneState
  // transition as the keyboard handler. Position top-right (614, 8) →
  // span (614-630, 8-24) so it doesn't collide with calendar widget
  // (left side, x≤110) and stays out of the panel/sticky region. Future
  // Q-N Status HUD will land at (540, 16) and may need to shift left
  // by ~40 px to clear; that retune is part of Q-N's scope.
  const hamburger = new Container();
  hamburger.label = 'pause-button';
  hamburger.x = 614;
  hamburger.y = 8;
  hamburger.eventMode = 'static';
  hamburger.cursor = 'pointer';
  ctx.worldLayer.addChild(hamburger);

  const hamburgerBg = new Graphics();
  hamburger.addChild(hamburgerBg);
  const hamburgerLines = new Graphics();
  hamburger.addChild(hamburgerLines);

  const drawHamburger = (hovering: boolean) => {
    hamburgerBg.clear();
    hamburgerBg.rect(0, 0, 16, 16);
    hamburgerBg.fill({ color: hovering ? 0xf3eed8 : 0xe8e0cc, alpha: 0.95 });
    hamburgerBg.stroke({ color: 0x2a1f14, width: 1 });
    hamburgerLines.clear();
    for (const y of [4, 8, 12]) {
      hamburgerLines.moveTo(3, y);
      hamburgerLines.lineTo(13, y);
    }
    hamburgerLines.stroke({ color: 0x2a1f14, width: 1 });
  };
  drawHamburger(false);
  hamburger.on('pointerover', () => drawHamburger(true));
  hamburger.on('pointerout', () => drawHamburger(false));
  hamburger.on('pointertap', () => {
    const cur = flow.state;
    if (cur.kind === 'action_day') {
      flow.request({ kind: 'pause', resumeTo: cur });
    }
  });
  teardowns.push(() => hamburger.destroy({ children: true }));

  // ── Early-leave 「下班」 button (P0-P4 legacy, gated by SHOW_LEGACY_HUD) ──
  // P5 plan: this becomes a diegetic prop in P6 (e.g. mug + chair animation
  // when player declines an event). For demo we just hide it.
  if (SHOW_LEGACY_HUD) {
    const earlyLeaveBtn = new Container();
    earlyLeaveBtn.label = 'early-leave';
    earlyLeaveBtn.x = 590;
    earlyLeaveBtn.y = 16;
    earlyLeaveBtn.eventMode = 'static';
    earlyLeaveBtn.cursor = 'pointer';
    ctx.worldLayer.addChild(earlyLeaveBtn);

    const earlyLeaveBg = new Graphics();
    earlyLeaveBtn.addChild(earlyLeaveBg);
    const earlyLeaveText = new Text({
      text: '下班',
      style: {
        fontFamily: 'PingFang SC, -apple-system, sans-serif',
        fontSize: 11,
        fill: 0xe8e0cc,
        letterSpacing: 2,
      },
    });
    earlyLeaveText.anchor.set(0.5);
    earlyLeaveBtn.addChild(earlyLeaveText);

    const drawEarlyLeave = (hovering: boolean) => {
      earlyLeaveBg.clear();
      earlyLeaveBg.rect(-22, -10, 44, 20);
      earlyLeaveBg.fill(hovering ? 0x3a5a82 : 0x2c4a6e);
      earlyLeaveBg.stroke({ color: 0x5a7080, width: 1 });
    };
    drawEarlyLeave(false);
    earlyLeaveBtn.on('pointerover', () => drawEarlyLeave(true));
    earlyLeaveBtn.on('pointerout', () => drawEarlyLeave(false));
    earlyLeaveBtn.on('pointertap', () => {
      // dayCycle.endDayEarly();  // requires dayCycle import; restore when re-enabling
    });
    teardowns.push(() => earlyLeaveBtn.destroy({ children: true }));
  }

  return () => {
    for (const t of teardowns) t();
  };
}
