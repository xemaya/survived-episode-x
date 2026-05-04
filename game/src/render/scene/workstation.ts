import { ap } from '@/economy/ap';
import { BASE_AP_PER_DAY, OVERTIME_BONUS_AP } from '@/economy/constants';
import { energy } from '@/economy/energy';
import { kpi } from '@/economy/kpi';
import { calendar } from '@/flow/calendar';
import { dayCycle } from '@/flow/day-cycle';
import type { SceneState } from '@/flow/scene-state';
import { mountCardHand } from '@/render/cards/hand';
import { Assets, Container, Graphics, Sprite, Text } from 'pixi.js';
import type { StageContext } from '../stage';

// Maximum AP slots to render — covers base (8) + overtime bonus (2) = 10.
const AP_SLOT_COUNT = BASE_AP_PER_DAY + OVERTIME_BONUS_AP;

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

  // ── Calendar (date binding, swappable sprite) ───────────────────────────
  // Subscribes to calendar.onDateChanged. P3 has 4 calendar sprites
  // available; map currentDay → nearest available frame.
  const calendarContainer = new Container();
  calendarContainer.label = 'calendar';
  calendarContainer.x = 70;
  calendarContainer.y = 60;
  ctx.worldLayer.addChild(calendarContainer);

  const CALENDAR_FRAMES = {
    start: 'sprites/hud/calendar_month_day_1.png',
    mid: 'sprites/hud/calendar_mid_week.png',
    weekend: 'sprites/hud/calendar_weekend_marked.png',
    end: 'sprites/hud/calendar_month_end.png',
  } as const;

  function pickCalendarFrame(day: number): string {
    if (day <= 1) return CALENDAR_FRAMES.start;
    if (day <= 4) return CALENDAR_FRAMES.mid;
    if (day <= 6) return CALENDAR_FRAMES.weekend;
    return CALENDAR_FRAMES.end; // day 7 = month end
  }

  let currentCalendarSprite: Sprite | null = null;
  const swapCalendarTo = async (url: string) => {
    const tex = await Assets.load(url);
    tex.source.scaleMode = 'linear';
    if (currentCalendarSprite) currentCalendarSprite.destroy();
    const s = new Sprite(tex);
    s.anchor.set(0.5);
    s.scale.set(0.25);
    calendarContainer.addChild(s);
    currentCalendarSprite = s;
  };
  await swapCalendarTo(pickCalendarFrame(calendar.currentDay));

  const unsubCalendar = calendar.onDateChanged(() => {
    void swapCalendarTo(pickCalendarFrame(calendar.currentDay));
  });
  teardowns.push(() => {
    unsubCalendar();
    calendarContainer.destroy({ children: true });
  });

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

  // Always render AP_SLOT_COUNT (10) slots so the row doesn't resize when
  // overtime grants push ap.current above the base 8. Slots beyond ap.current
  // draw as empty/spent; slots beyond BASE_AP_PER_DAY only light up during
  // action_overtime when ap.current can legitimately exceed 8.
  const slots: Graphics[] = [];
  for (let i = 0; i < AP_SLOT_COUNT; i++) {
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

  // ── Early-leave 「下班」 button (top-right corner, above AP row) ─────────
  // GDD: day ends when AP=0 OR player chooses to leave early. With only 4
  // P2 placeholder cards (sum 7 AP), the AP=0 path is unreachable —
  // player would otherwise be stuck. P3 surfaces early-leave so the
  // loop always closes.
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
    dayCycle.endDayEarly();
  });
  teardowns.push(() => earlyLeaveBtn.destroy({ children: true }));

  return () => {
    for (const t of teardowns) t();
  };
}
