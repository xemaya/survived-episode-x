// Q-N (Bug #29 revived): always-visible Status HUD top-right, per
// avg-architecture.md §2.4 v2.
//
// 3 rows of KPI / 钱 / 状态 read from ink VARs (the design source of
// truth — engine's kpi/energy modules track FSM state separately).
// On refresh(), snapshots the VAR values and tweens the displayed
// numbers toward the new targets while flashing a `+N`/`-N` badge
// next to the changed row for 0.8s.
//
// Layout: 80×72 container at (canvas.W - 100, 16) = (540, 16). BG
// `#1A2A38` (system-overlay 屏幕蓝光加深, art-bible §4.4) + alpha 0.85
// + 1 px border `#2A1F14` (公文格式框 spirit). Cream `#E8E0CC` 10 pt
// 思源黑体 / 公文宋 fallback.
//
// Refresh is driven externally — `mountInkDialog` receives an
// `onAfterAdvance` callback that hits `hud.refresh()` after every
// step()/selectChoice(). Internal RAF tick handles the easing.

import { ink } from '@/ink/runtime';
import type { Application } from 'pixi.js';
import { Container, Graphics, Text } from 'pixi.js';

export interface StatusHudHandle {
  container: Container;
  refresh: () => void;
  destroy: () => void;
}

const HUD_W = 80;
const HUD_H = 72;
const HUD_BG = 0x1a2a38;
const HUD_BG_ALPHA = 0.85;
const HUD_BORDER = 0x2a1f14;
const TEXT_COLOR = 0xe8e0cc;
const FLASH_POSITIVE_COLOR = 0xc8a85a; // 打工人黄
const FLASH_NEGATIVE_COLOR = 0xc83428;
const FLASH_DURATION_MS = 800;
const TWEEN_EASE = 0.18; // per-frame lerp factor
const ROW_Y = [10, 30, 50] as const;
const FONT_FAMILY = 'PingFang SC, -apple-system, sans-serif';
const KPI_THRESHOLD_FALLBACK = 200; // shown next to KPI as `KPI: X / 200`

interface RowState {
  label: string;
  // ink VAR name to read.
  varName: 'kpi' | 'money' | 'state';
  formatValue: (raw: number) => string;
  current: number; // displayed (eased)
  target: number; // last-read VAR value
  flashText: string; // '+N' / '-N' / ''
  flashRemainMs: number;
  flashColor: number;
}

function readVar(name: 'kpi' | 'money' | 'state'): number {
  const v = ink.isLoaded ? ink.getVar<number>(name) : null;
  return typeof v === 'number' ? v : 0;
}

export interface MountStatusHudOpts {
  app: Application;
  x?: number;
  y?: number;
}

export function mountStatusHud(parent: Container, opts: MountStatusHudOpts): StatusHudHandle {
  const container = new Container();
  container.label = 'status-hud';
  container.x = opts.x ?? 640 - HUD_W - 20;
  container.y = opts.y ?? 16;
  parent.addChild(container);

  const bg = new Graphics();
  bg.rect(0, 0, HUD_W, HUD_H);
  bg.fill({ color: HUD_BG, alpha: HUD_BG_ALPHA });
  bg.stroke({ color: HUD_BORDER, width: 1 });
  container.addChild(bg);

  const rows: RowState[] = [
    {
      label: 'KPI',
      varName: 'kpi',
      formatValue: (n) => `KPI ${n} / ${KPI_THRESHOLD_FALLBACK}`,
      current: 0,
      target: 0,
      flashText: '',
      flashRemainMs: 0,
      flashColor: TEXT_COLOR,
    },
    {
      label: '钱',
      varName: 'money',
      formatValue: (n) => `钱 ¥${n.toLocaleString('en-US')}`,
      current: 0,
      target: 0,
      flashText: '',
      flashRemainMs: 0,
      flashColor: TEXT_COLOR,
    },
    {
      label: '状态',
      varName: 'state',
      formatValue: (n) => `状态 ${n} / 100`,
      current: 0,
      target: 0,
      flashText: '',
      flashRemainMs: 0,
      flashColor: TEXT_COLOR,
    },
  ];

  // Initial seeding: skip animation on first read so the HUD doesn't
  // tween from 0 → 5500 on boot.
  const valueTexts: Text[] = [];
  const flashTexts: Text[] = [];
  for (let i = 0; i < rows.length; i++) {
    const row = rows[i]!;
    row.target = readVar(row.varName);
    row.current = row.target;

    const valueText = new Text({
      text: row.formatValue(Math.round(row.current)),
      style: {
        fontFamily: FONT_FAMILY,
        fontSize: 10,
        fill: TEXT_COLOR,
      },
    });
    valueText.x = 6;
    valueText.y = ROW_Y[i] ?? 10;
    container.addChild(valueText);
    valueTexts.push(valueText);

    const flashText = new Text({
      text: '',
      style: {
        fontFamily: FONT_FAMILY,
        fontSize: 10,
        fill: TEXT_COLOR,
      },
    });
    flashText.anchor.set(1, 0);
    flashText.x = HUD_W - 6;
    flashText.y = ROW_Y[i] ?? 10;
    container.addChild(flashText);
    flashTexts.push(flashText);
  }

  const refresh = (): void => {
    for (const row of rows) {
      const next = readVar(row.varName);
      if (next !== row.target) {
        const delta = next - row.target;
        row.flashText = `${delta > 0 ? '+' : ''}${delta}`;
        row.flashRemainMs = FLASH_DURATION_MS;
        row.flashColor = delta > 0 ? FLASH_POSITIVE_COLOR : FLASH_NEGATIVE_COLOR;
        row.target = next;
      }
    }
  };

  // RAF tick — ease displayed values toward target + decay flash badge.
  const onTick = () => {
    const dtMs = (1 / 60) * 1000; // approximate; pixi ticker.deltaMS would be ideal
    for (let i = 0; i < rows.length; i++) {
      const row = rows[i]!;
      // Ease current toward target.
      if (row.current !== row.target) {
        const diff = row.target - row.current;
        if (Math.abs(diff) < 0.5) {
          row.current = row.target;
        } else {
          row.current += diff * TWEEN_EASE;
        }
        const valueText = valueTexts[i];
        if (valueText) valueText.text = row.formatValue(Math.round(row.current));
      }
      // Decay flash badge.
      if (row.flashRemainMs > 0) {
        row.flashRemainMs -= dtMs;
        const ft = flashTexts[i];
        if (ft) {
          if (row.flashRemainMs <= 0) {
            row.flashRemainMs = 0;
            row.flashText = '';
            ft.text = '';
          } else {
            ft.text = row.flashText;
            ft.style.fill = row.flashColor;
            // Fade alpha over remaining time.
            ft.alpha = Math.min(1, row.flashRemainMs / FLASH_DURATION_MS + 0.2);
          }
        }
      }
    }
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
