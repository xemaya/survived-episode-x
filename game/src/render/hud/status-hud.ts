// Q-AA (Bug #40, 2026-05-07) rebuild: 3-bar + 3-icon HUD per user
// "no numbers, three same-size icons, three bars" calibration.
// Replaces the Q-N text-row readout entirely.
//
// Layout: 80×56 container at (canvas.W - 84, 16) = (556, 16). 3 rows
// stacked vertically (3 px gap). Each row = [12×12 icon] [60×12 bar].
//   - Row 1 KPI: ratio actualKpi/monthlyThreshold clamped 0-1.4 (handle
//     处刑 over-threshold). Fill `#C8A85A` 打工人黄; red `#C83428`
//     highlight when ratio > 1.0 (over-cap warning).
//   - Row 2 钱: ratio (money - 2000) / (15000 - 2000) clamped 0-1.
//     Fill `#E0B050` 老板金.
//   - Row 3 状态: state/100. Fill `#5A7080` 灰蓝; red highlight when
//     < 0.2 (病倒 imminent).
//
// Reads ink VARs `kpi/money/state`. Engine kpi/energy modules track
// FSM state separately; ink VARs are the design's narrative source
// of truth. KPI's monthlyThreshold is engine-side though, so we read
// it from `kpi.monthlyThreshold` for the ratio denominator.
//
// Refresh is driven externally — `mountInkDialog` receives an
// `onAfterAdvance` callback that calls `hud.refresh()` after every
// step()/selectChoice(). Internal Pixi ticker handles bar tween and
// flash decay.

import { kpi as kpiSystem } from '@/economy/kpi';
import { ink } from '@/ink/runtime';
import type { Application } from 'pixi.js';
import { Container, Graphics, Text } from 'pixi.js';

export interface StatusHudHandle {
  container: Container;
  refresh: () => void;
  destroy: () => void;
}

const HUD_W = 80;
const HUD_H = 56;
const HUD_BG = 0x1a2a38;
const HUD_BG_ALPHA = 0.85;
const HUD_BORDER = 0x2a1f14;

const ICON_SIZE = 12;
const BAR_W = 60;
const BAR_H = 12;
const ROW_GAP = 3;
const PAD_X = 4;
const PAD_TOP = 4;
const ICON_BAR_GAP = 4;

// Position constants per row.
const ROW_Y = [PAD_TOP, PAD_TOP + (BAR_H + ROW_GAP), PAD_TOP + 2 * (BAR_H + ROW_GAP)] as const;
const ICON_X = PAD_X;
const BAR_X = PAD_X + ICON_SIZE + ICON_BAR_GAP;

const ICON_COLOR = 0xe8e0cc;
const BAR_BG_COLOR = 0xd8d2c0; // 灰白 empty bar
const BAR_BG_ALPHA = 0.4;
const BAR_FILL_KPI = 0xc8a85a;
const BAR_FILL_MONEY = 0xe0b050;
const BAR_FILL_STATE = 0x5a7080;
const BAR_FILL_WARNING = 0xc83428;

const FLASH_DURATION_MS = 300;
const TWEEN_EASE = 0.18;

const MONEY_LOW = 2000; // 房贷扣款下限
const MONEY_HIGH = 15000; // 充裕
const KPI_BAR_MAX_RATIO = 1.4; // 处刑 zone

interface RowState {
  varName: 'kpi' | 'money' | 'state';
  fillColor: number;
  /** Last-read ratio (0..1, occasionally up to 1.4 for KPI 处刑 zone). */
  target: number;
  /** Eased displayed ratio. */
  current: number;
  /** Whether this row is in its "warning" zone (red highlight). */
  warning: boolean;
  flashRemainMs: number;
}

function readRatio(varName: 'kpi' | 'money' | 'state'): { ratio: number; warning: boolean } {
  if (!ink.isLoaded) return { ratio: 0, warning: false };
  const raw = ink.getVar<number>(varName);
  if (typeof raw !== 'number') return { ratio: 0, warning: false };
  if (varName === 'kpi') {
    const threshold = Math.max(1, kpiSystem.monthlyThreshold);
    const ratio = Math.max(0, Math.min(KPI_BAR_MAX_RATIO, raw / threshold));
    return { ratio, warning: ratio > 1.0 };
  }
  if (varName === 'money') {
    const ratio = Math.max(0, Math.min(1, (raw - MONEY_LOW) / (MONEY_HIGH - MONEY_LOW)));
    return { ratio, warning: false };
  }
  // state
  const ratio = Math.max(0, Math.min(1, raw / 100));
  return { ratio, warning: ratio < 0.2 };
}

/** Draw a 12×12 procedural icon for the given row at (cx, cy) origin
 * (top-left of the icon box). All three icons share the same size and
 * the same cream tint per art-bible §3.3 公文格式 spirit. */
function drawIconKpi(g: Graphics, cx: number, cy: number): void {
  // Three stacked horizontal lines (表格 motif): y=cy+3 / +6 / +9, x cy+2..cx+10.
  for (const yOff of [3, 6, 9]) {
    g.moveTo(cx + 2, cy + yOff);
    g.lineTo(cx + 10, cy + yOff);
  }
  g.stroke({ color: ICON_COLOR, width: 1 });
}

// ¥ glyph for the money row is rendered as a Text node inline below
// (Graphics-only ¥ at 12 px is awkward). All other icons go through
// these procedural Graphics draws.

function drawIconState(g: Graphics, cx: number, cy: number): void {
  // Heart silhouette: 2 small circles for the lobes + triangle bottom.
  // Lobe centers at (cx+4, cy+5) and (cx+8, cy+5), radius 2.
  g.circle(cx + 4, cy + 5, 2);
  g.circle(cx + 8, cy + 5, 2);
  g.fill({ color: ICON_COLOR });
  // Triangle bottom: top edge spans the lobes' inner edges, point down.
  g.moveTo(cx + 2, cy + 6);
  g.lineTo(cx + 10, cy + 6);
  g.lineTo(cx + 6, cy + 11);
  g.lineTo(cx + 2, cy + 6);
  g.fill({ color: ICON_COLOR });
}

export interface MountStatusHudOpts {
  app: Application;
  x?: number;
  y?: number;
}

export function mountStatusHud(parent: Container, opts: MountStatusHudOpts): StatusHudHandle {
  const container = new Container();
  container.label = 'status-hud';
  container.x = opts.x ?? 640 - HUD_W - 4;
  container.y = opts.y ?? 16;
  parent.addChild(container);

  // Layer 1: HUD BG.
  const bg = new Graphics();
  bg.rect(0, 0, HUD_W, HUD_H);
  bg.fill({ color: HUD_BG, alpha: HUD_BG_ALPHA });
  bg.stroke({ color: HUD_BORDER, width: 1 });
  container.addChild(bg);

  // Layer 2: 3 row icons (one-time draw).
  const iconLayer = new Graphics();
  drawIconKpi(iconLayer, ICON_X, ROW_Y[0]);
  drawIconState(iconLayer, ICON_X, ROW_Y[2]);
  container.addChild(iconLayer);

  // ¥ icon as a Text node — Graphics-based ¥ at 12 px is messy.
  const moneyIcon = new Text({
    text: '¥',
    style: {
      fontFamily: 'PingFang SC, -apple-system, sans-serif',
      fontSize: 11,
      fill: ICON_COLOR,
      fontWeight: 'bold',
    },
  });
  moneyIcon.anchor.set(0.5, 0);
  moneyIcon.x = ICON_X + ICON_SIZE / 2;
  moneyIcon.y = ROW_Y[1] - 1;
  container.addChild(moneyIcon);

  // Layer 3: bar BGs (one-time draw — empty bar outlines).
  const barBg = new Graphics();
  for (const y of ROW_Y) {
    barBg.rect(BAR_X, y, BAR_W, BAR_H);
    barBg.fill({ color: BAR_BG_COLOR, alpha: BAR_BG_ALPHA });
    barBg.stroke({ color: HUD_BORDER, width: 1 });
  }
  container.addChild(barBg);

  // Layer 4: bar fills (redrawn each tick from row state).
  const barFills = new Graphics();
  container.addChild(barFills);

  const rows: RowState[] = [
    {
      varName: 'kpi',
      fillColor: BAR_FILL_KPI,
      target: 0,
      current: 0,
      warning: false,
      flashRemainMs: 0,
    },
    {
      varName: 'money',
      fillColor: BAR_FILL_MONEY,
      target: 0,
      current: 0,
      warning: false,
      flashRemainMs: 0,
    },
    {
      varName: 'state',
      fillColor: BAR_FILL_STATE,
      target: 0,
      current: 0,
      warning: false,
      flashRemainMs: 0,
    },
  ];

  // Initial seeding — skip animation so bars don't tween from 0 on boot.
  for (const row of rows) {
    const { ratio, warning } = readRatio(row.varName);
    row.target = ratio;
    row.current = ratio;
    row.warning = warning;
  }

  const drawBars = (): void => {
    barFills.clear();
    for (let i = 0; i < rows.length; i++) {
      const row = rows[i];
      const y = ROW_Y[i];
      if (!row || y === undefined) continue;
      // Inner fill area inside the 1 px border.
      const innerW = BAR_W - 2;
      const fillFrac = Math.min(1, row.current / 1.0); // bar capped at 1.0 visually
      const fillW = Math.max(0, innerW * fillFrac);
      if (fillW > 0) {
        const flashing = row.flashRemainMs > 0;
        const baseColor = row.warning ? BAR_FILL_WARNING : row.fillColor;
        // Brief lighten on flash — XOR 0x202020 brightens slightly.
        const color = flashing ? brighten(baseColor) : baseColor;
        barFills.rect(BAR_X + 1, y + 1, fillW, BAR_H - 2);
        barFills.fill({ color });
      }
    }
  };

  drawBars();

  const refresh = (): void => {
    for (const row of rows) {
      const { ratio, warning } = readRatio(row.varName);
      if (ratio !== row.target) {
        row.flashRemainMs = FLASH_DURATION_MS;
        row.target = ratio;
      }
      row.warning = warning;
    }
  };

  const onTick = () => {
    const dtMs = (1 / 60) * 1000;
    let dirty = false;
    for (const row of rows) {
      if (row.current !== row.target) {
        const diff = row.target - row.current;
        if (Math.abs(diff) < 0.005) {
          row.current = row.target;
        } else {
          row.current += diff * TWEEN_EASE;
        }
        dirty = true;
      }
      if (row.flashRemainMs > 0) {
        row.flashRemainMs = Math.max(0, row.flashRemainMs - dtMs);
        dirty = true;
      }
    }
    if (dirty) drawBars();
  };

  opts.app.ticker.add(onTick);

  return {
    container,
    refresh,
    destroy: () => {
      opts.app.ticker.remove(onTick);
      container.destroy({ children: true });
    },
  };
}

/** Lighten a 0xRRGGBB color by ~20% per channel for the flash effect. */
function brighten(color: number): number {
  const r = (color >> 16) & 0xff;
  const g = (color >> 8) & 0xff;
  const b = color & 0xff;
  const nr = Math.min(255, r + 40);
  const ng = Math.min(255, g + 40);
  const nb = Math.min(255, b + 40);
  return (nr << 16) | (ng << 8) | nb;
}
