// Q-U (Bug #26): programmatic Pixi calendar widget.
//
// Replaces the legacy 4-frame calendar sprite mount in workstation.ts.
// The sprite assets were low-fidelity AND didn't track currentDay; this
// widget draws a desk-calendar-style grid with Graphics + Text, redraws
// itself on every `calendar.onDateChanged` fire, and highlights the
// current day cell with a red outline (mimicking a real flip-page
// calendar where the active date is circled).
//
// Visual design (per p5-qa-bug-reports.md Bug #26 spec):
//   - Top banner: month label "5 月 / MAY" + 2 binding rings (公文-ish
//     office aesthetic, art-bible §3.3 直角矩形 + 1 px border)
//   - Grid: 7 cols × 5 rows. Day-of-month 1-30 fills cells in
//     left-to-right, top-to-bottom order starting at column 1 (Monday)
//     since CalendarSystem uses Monday=1 ordering.
//   - Weekend cols (Sa=6, Su=7) render the date number in red.
//   - Past days: light gray. Current day: red ring outline. Future
//     days: standard ink color.

import { MONTH_DAYS } from '@/economy/constants';
import { calendar } from '@/flow/calendar';
import { Container, Graphics, Text } from 'pixi.js';

export interface CalendarWidgetHandle {
  container: Container;
  destroy: () => void;
}

const WIDGET_W = 80;
const WIDGET_H = 80;
const BANNER_H = 16;
const GRID_PAD_X = 4;
const GRID_PAD_TOP = BANNER_H + 4;
const GRID_PAD_BOTTOM = 4;
const GRID_COLS = 7;
const GRID_ROWS = 5;

const CELL_W = (WIDGET_W - 2 * GRID_PAD_X) / GRID_COLS;
const CELL_H = (WIDGET_H - GRID_PAD_TOP - GRID_PAD_BOTTOM) / GRID_ROWS;

const PAPER_COLOR = 0xefe6d2; // 暖米色台历纸
const PAPER_ALPHA = 0.98;
const BANNER_COLOR = 0x8a4a3a; // 暗红装订色
const BORDER_COLOR = 0x2a1f14;
const BINDING_RING_COLOR = 0x5a4030;
const TEXT_COLOR = 0x2a1f14;
const PAST_DAY_COLOR = 0xb8a890;
const WEEKEND_COLOR = 0xc83428;
const CURRENT_RING_COLOR = 0xc83428;

const FONT = 'PingFang SC, -apple-system, sans-serif';

const MONTH_NAMES_EN: ReadonlyArray<string> = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC',
];

function monthEnglish(monthIndex: number): string {
  return MONTH_NAMES_EN[(monthIndex - 1) % 12] ?? 'MAY';
}

/** Draws the static banner (month label + binding rings) into `g`.
 * Pure Graphics — caller calls `g.clear()` before invoking, then
 * recreates the children Texts since style props can change. */
function drawBanner(g: Graphics): void {
  // Banner BG strip.
  g.rect(0, 0, WIDGET_W, BANNER_H);
  g.fill({ color: BANNER_COLOR, alpha: PAPER_ALPHA });
  // Bottom divider line.
  g.moveTo(0, BANNER_H);
  g.lineTo(WIDGET_W, BANNER_H);
  g.stroke({ color: BORDER_COLOR, width: 1 });
  // Two binding rings poking through the top edge.
  for (const ringX of [WIDGET_W * 0.28, WIDGET_W * 0.72]) {
    g.circle(ringX, 1, 2);
    g.fill({ color: BINDING_RING_COLOR });
  }
}

/** Mount a programmatic calendar widget at a parent's coordinate. The
 * widget's container is positioned so that (x, y) is the top-left of
 * the widget rect (NOT centered). It self-subscribes to
 * `calendar.onDateChanged` and tears down on destroy(). */
export function mountCalendarWidget(
  parent: Container,
  opts: { x: number; y: number },
): CalendarWidgetHandle {
  const container = new Container();
  container.label = 'calendar-widget';
  container.x = opts.x;
  container.y = opts.y;
  parent.addChild(container);

  // Layer 1: paper BG (one-time draw).
  const paper = new Graphics();
  paper.rect(0, 0, WIDGET_W, WIDGET_H);
  paper.fill({ color: PAPER_COLOR, alpha: PAPER_ALPHA });
  paper.stroke({ color: BORDER_COLOR, width: 1 });
  container.addChild(paper);

  // Layer 2: banner (one-time draw of strip + rings; label updates).
  const bannerGfx = new Graphics();
  drawBanner(bannerGfx);
  container.addChild(bannerGfx);

  const bannerLabel = new Text({
    text: '',
    style: {
      fontFamily: FONT,
      fontSize: 8,
      fill: 0xefe6d2,
      align: 'center',
    },
  });
  bannerLabel.anchor.set(0.5);
  bannerLabel.x = WIDGET_W / 2;
  bannerLabel.y = BANNER_H / 2 + 1;
  container.addChild(bannerLabel);

  // Layer 3: cell grid + current-day ring (redrawn every refresh).
  const gridLayer = new Container();
  gridLayer.label = 'calendar-grid';
  container.addChild(gridLayer);

  const refresh = () => {
    bannerLabel.text = `${calendar.monthIndex} 月 · ${monthEnglish(calendar.monthIndex)}`;

    gridLayer.removeChildren();

    const ring = new Graphics();
    gridLayer.addChild(ring);

    for (let day = 1; day <= MONTH_DAYS; day++) {
      const idx = day - 1;
      const col = idx % GRID_COLS;
      const row = Math.floor(idx / GRID_COLS);
      if (row >= GRID_ROWS) break;

      const cellX = GRID_PAD_X + col * CELL_W;
      const cellY = GRID_PAD_TOP + row * CELL_H;
      const cellCx = cellX + CELL_W / 2;
      const cellCy = cellY + CELL_H / 2;

      const isWeekend = col === 5 || col === 6; // Sa=col 5 (idx), Su=col 6
      const isPast = day < calendar.currentDay;
      const isCurrent = day === calendar.currentDay;

      const fill = isCurrent
        ? CURRENT_RING_COLOR
        : isPast
          ? PAST_DAY_COLOR
          : isWeekend
            ? WEEKEND_COLOR
            : TEXT_COLOR;

      const dateText = new Text({
        text: String(day),
        style: {
          fontFamily: FONT,
          fontSize: 7,
          fill,
        },
      });
      dateText.anchor.set(0.5);
      dateText.x = cellCx;
      dateText.y = cellCy;
      gridLayer.addChild(dateText);

      if (isCurrent) {
        ring.circle(cellCx, cellCy, Math.min(CELL_W, CELL_H) / 2 - 0.5);
        ring.stroke({ color: CURRENT_RING_COLOR, width: 1 });
      }
    }
  };

  refresh();
  const unsub = calendar.onDateChanged(() => refresh());

  return {
    container,
    destroy: () => {
      unsub();
      container.destroy({ children: true });
    },
  };
}
