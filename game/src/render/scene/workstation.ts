import { resetPlayedThisDay } from '@/card/play';
import { ap } from '@/economy/ap';
import { kpi } from '@/economy/kpi';
import type { SceneState } from '@/flow/scene-state';
import { mountCardHand } from '@/render/cards/hand';
import { Assets, Container, Graphics, Sprite, Text } from 'pixi.js';
import type { StageContext } from '../stage';

// Layout constants (640×360 logical canvas).
const STICKY_X = 480;
const STICKY_Y = 36;
const STICKY_SIZE = 12;
const STICKY_GAP = 4;

interface PropSpec {
  url: string;
  x: number;
  y: number;
  scale: number;
  label: string;
}

const STATIC_PROPS: ReadonlyArray<PropSpec> = [
  // Calendar — top-left wall mount
  { url: 'sprites/hud/calendar_month_day_1.png', x: 50, y: 50, scale: 0.12, label: 'calendar' },
  // Sticky note — to the right of monitor (decorative; AP slot row drawn separately)
  { url: 'sprites/hud/sticky_blank.png', x: 470, y: 200, scale: 0.1, label: 'sticky' },
  // Mug — bottom-left of desk. Static in P2 (energy not implemented; still
  // shows coffee_full.png placeholder per P1).
  { url: 'sprites/hud/coffee_full.png', x: 130, y: 260, scale: 0.1, label: 'mug' },
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

  // ── Static props ────────────────────────────────────────────────────────
  for (const spec of STATIC_PROPS) {
    const tex = await Assets.load(spec.url);
    tex.source.scaleMode = 'nearest';
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
    tex.source.scaleMode = 'nearest';
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

  // ── Sticky-note AP row (code-drawn, 8 slots) ────────────────────────────
  const apRow = new Container();
  apRow.label = 'ap-row';
  apRow.x = STICKY_X;
  apRow.y = STICKY_Y;
  ctx.worldLayer.addChild(apRow);

  const apLabel = new Text({
    text: 'AP',
    style: {
      fontFamily: 'PingFang SC, -apple-system, sans-serif',
      fontSize: 10,
      fill: 0xe8e0cc,
    },
  });
  apLabel.anchor.set(1, 0.5);
  apLabel.x = -6;
  apLabel.y = STICKY_SIZE / 2;
  apRow.addChild(apLabel);

  const slots: Graphics[] = [];
  for (let i = 0; i < ap.max; i++) {
    const g = new Graphics();
    g.x = i * (STICKY_SIZE + STICKY_GAP);
    apRow.addChild(g);
    slots.push(g);
  }

  const drawSlots = () => {
    for (let i = 0; i < slots.length; i++) {
      const g = slots[i];
      if (!g) continue;
      const filled = i < ap.current;
      g.clear();
      g.rect(0, 0, STICKY_SIZE, STICKY_SIZE);
      g.fill(filled ? 0xc8a85a : 0x1a1d22);
      g.stroke({ color: 0x5a7080, width: 1 });
      if (!filled) {
        // Spent slots get a crossed-out diagonal (red ✗)
        g.moveTo(2, 2);
        g.lineTo(STICKY_SIZE - 2, STICKY_SIZE - 2);
        g.moveTo(STICKY_SIZE - 2, 2);
        g.lineTo(2, STICKY_SIZE - 2);
        g.stroke({ color: 0xc83428, width: 1 });
      }
    }
  };
  const unsubAp = ap.onChanged(() => drawSlots());
  drawSlots();
  teardowns.push(() => {
    unsubAp();
    apRow.destroy({ children: true });
  });

  // ── KPI numeric readout (small text under the monitor for debug/clarity) ─
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

  // ── Card hand (code-drawn UI; loads its own face sprites) ───────────────
  const handHandles = await mountCardHand(ctx.worldLayer, ctx.app);
  teardowns.push(() => handHandles.destroy());

  // ── Day-end auto-advance ────────────────────────────────────────────────
  // When AP drops to 0, surface a 「结束今日」 prompt (drawn as a Text node
  // above the cards). Click anywhere on the canvas (or the prompt) to
  // advance: AP refills, playedThisDay clears, day increments. P3 inserts
  // a KPI Review screen between these steps; P2 keeps it instant.
  const endDayPrompt = new Text({
    text: '点击屏幕进入下一天',
    style: {
      fontFamily: 'PingFang SC, -apple-system, sans-serif',
      fontSize: 14,
      fill: 0xc8a85a,
      fontWeight: '700',
    },
  });
  endDayPrompt.anchor.set(0.5);
  endDayPrompt.x = 320;
  endDayPrompt.y = 230;
  endDayPrompt.visible = false;
  ctx.worldLayer.addChild(endDayPrompt);

  const advanceDay = (): void => {
    resetPlayedThisDay();
    ap.resetForNewDay();
    endDayPrompt.visible = false;
    // P3+: increment day in flow state via flow.request(action_day, day+1).
    // For P2 we leave the FSM at day=1 — visual loop still closes because
    // AP refills + cards re-enable.
  };

  // Only react to background clicks AFTER AP=0; cards still take priority
  // because their eventMode is 'static' and they bubble first.
  ctx.app.stage.eventMode = 'static';
  const onStageClick = () => {
    if (ap.current === 0) advanceDay();
  };
  ctx.app.stage.on('pointertap', onStageClick);

  const unsubApForPrompt = ap.onChanged((current) => {
    endDayPrompt.visible = current === 0;
  });

  teardowns.push(() => {
    ctx.app.stage.off('pointertap', onStageClick);
    unsubApForPrompt();
    endDayPrompt.destroy();
  });

  return () => {
    for (const t of teardowns) t();
  };
}
