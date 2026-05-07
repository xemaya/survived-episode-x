// Q-S (avg-architecture.md §2.2): weekly meter modal — week_start
// (周一 morning) and week_end (周五 evening) progress check-in.
//
// Carries the daily-pressure half of the post-AP design. Player
// dismisses with a single click; auto-progress timer (3s default)
// fires the same path so the modal doesn't block too long.
//
// Numbers are read from ink VARs (kpi/money/state/sick_count) — the
// design's narrative source of truth — not the engine modules. This
// keeps the meter aligned with what the .ink content has been
// emitting via `~ kpi += N` etc., even if engine state is stale.

import { calendar } from '@/flow/calendar';
import { dayCycle } from '@/flow/day-cycle';
import type { WeeklyMeterPhase } from '@/flow/scene-state';
import { ink } from '@/ink/runtime';
import { useEffect, useState } from 'preact/hooks';

interface Props {
  phase: WeeklyMeterPhase;
}

const AUTO_PROGRESS_MS = 6_000;

const KPI_THRESHOLD_FALLBACK = 200;
const SICK_CAP = 6;

function readVar(name: 'kpi' | 'money' | 'state' | 'sick_count'): number {
  if (!ink.isLoaded) return 0;
  const v = ink.getVar<number>(name);
  return typeof v === 'number' ? v : 0;
}

function bar(filled: number, total: number, cells = 10): string {
  const ratio = Math.max(0, Math.min(1, total === 0 ? 0 : filled / total));
  const full = Math.round(ratio * cells);
  return '▓'.repeat(full) + '░'.repeat(cells - full);
}

function sickCells(used: number): string {
  // 6 cells, red square per sick day used, gray empty otherwise.
  const out: string[] = [];
  for (let i = 0; i < SICK_CAP; i++) {
    out.push(i < used ? '■' : '□');
  }
  return out.join(' ');
}

export function WeeklyMeter({ phase }: Props): preact.JSX.Element {
  const [secondsLeft, setSecondsLeft] = useState(Math.floor(AUTO_PROGRESS_MS / 1000));
  const kpi = readVar('kpi');
  const money = readVar('money');
  const state = readVar('state');
  const sick = readVar('sick_count');

  const dismiss = (): void => {
    dayCycle.confirmWeeklyMeter();
  };

  useEffect(() => {
    const tickId = window.setInterval(() => {
      setSecondsLeft((s) => Math.max(0, s - 1));
    }, 1000);
    const progressId = window.setTimeout(() => {
      dayCycle.confirmWeeklyMeter();
    }, AUTO_PROGRESS_MS);
    return () => {
      window.clearInterval(tickId);
      window.clearTimeout(progressId);
    };
  }, []);

  const headerLabel =
    phase === 'week_start'
      ? `第 ${calendar.monthIndex} 月 · 第 ${Math.ceil(calendar.currentDay / 7)} 周 · 周一 morning`
      : `第 ${calendar.monthIndex} 月 · 第 ${Math.ceil(calendar.currentDay / 7)} 周 · 周五 evening`;

  return (
    <div class="menu-root menu-root--weekly-meter">
      <h2 class="menu-title menu-title--small">{headerLabel}</h2>
      <div class="recap-rows">
        <div class="recap-row">
          <span class="recap-label">本月 KPI 累积</span>
          <span class="recap-value">
            {bar(kpi, KPI_THRESHOLD_FALLBACK)} {kpi} / {KPI_THRESHOLD_FALLBACK}
          </span>
        </div>
        <div class="recap-row">
          <span class="recap-label">钱</span>
          <span class="recap-value">
            {bar(money - 2000, 13000)} ¥{money.toLocaleString('en-US')}
          </span>
        </div>
        <div class="recap-row">
          <span class="recap-label">状态</span>
          <span class="recap-value">
            {bar(state, 100)} {state} / 100
          </span>
        </div>
        <div class="recap-row recap-row--separator">
          <span class="recap-label">病倒次数</span>
          <span class="recap-value">
            {sickCells(sick)} {sick} / {SICK_CAP}
          </span>
        </div>
      </div>
      <div class="menu-buttons">
        <button type="button" class="menu-button menu-button--primary" onClick={dismiss}>
          {phase === 'week_start' ? '开始本周' : '收工回家'}
        </button>
      </div>
      <p class="recap-hint">{secondsLeft} 秒后自动继续</p>
    </div>
  );
}
