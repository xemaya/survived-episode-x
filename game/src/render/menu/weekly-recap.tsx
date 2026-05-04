import { kpi } from '@/economy/kpi';
import { dayCycle } from '@/flow/day-cycle';
import { useEffect, useState } from 'preact/hooks';

interface Props {
  day: number;
}

// design/gdd/daily-weekly-recap-ui.md: Friday upgrade. Shows 7-day summary
// + effort 3-dimension stub + KPI hint (待月末结算). Same skip/timer
// mechanics as daily.

const AUTO_PROGRESS_MS = 90_000;

export function WeeklyRecap({ day }: Props): preact.JSX.Element {
  const [secondsLeft, setSecondsLeft] = useState(Math.floor(AUTO_PROGRESS_MS / 1000));

  useEffect(() => {
    const tickId = window.setInterval(() => setSecondsLeft((s) => Math.max(0, s - 1)), 1000);
    const progressId = window.setTimeout(() => dayCycle.confirmRecap(), AUTO_PROGRESS_MS);
    return () => {
      window.clearInterval(tickId);
      window.clearTimeout(progressId);
    };
  }, []);

  return (
    <div class="menu-root menu-root--recap">
      <h2 class="menu-title menu-title--small">Day {day} · Friday — 周报</h2>
      <p class="menu-subtitle">本周三维考核登记</p>
      <div class="recap-rows">
        <div class="recap-row">
          <span class="recap-label">积极性</span>
          <span class="recap-value">已登记</span>
        </div>
        <div class="recap-row">
          <span class="recap-label">超额贡献</span>
          <span class="recap-value">已归档</span>
        </div>
        <div class="recap-row">
          <span class="recap-label">产出记录</span>
          <span class="recap-value">存档</span>
        </div>
        <div class="recap-row recap-row--separator">
          <span class="recap-label">本月 KPI 进度</span>
          <span class="recap-value">
            {kpi.actualKpi} / {kpi.monthlyThreshold} <em>(待月末结算)</em>
          </span>
        </div>
      </div>
      <div class="menu-buttons">
        <button
          type="button"
          class="menu-button menu-button--primary"
          onClick={() => dayCycle.confirmRecap()}
        >
          进入周末
        </button>
      </div>
      <p class="recap-hint">{secondsLeft} 秒后自动进入下一天</p>
    </div>
  );
}
