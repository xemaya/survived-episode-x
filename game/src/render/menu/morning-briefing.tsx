import { energy } from '@/economy/energy';
import { kpi } from '@/economy/kpi';
import { calendar } from '@/flow/calendar';
import { dayCycle } from '@/flow/day-cycle';

interface Props {
  day: number;
}

const WEEKDAY_NAMES = ['一', '二', '三', '四', '五', '六', '日'];

export function MorningBriefing({ day }: Props): preact.JSX.Element {
  const goAction = (): void => {
    void dayCycle.confirmMorningBriefing();
  };

  return (
    <div class="menu-root menu-root--briefing">
      <h2 class="menu-title menu-title--small">
        第 {kpi.month} 个月 · Day {day} · 周{WEEKDAY_NAMES[calendar.currentWeekday - 1] ?? '?'}
      </h2>
      <p class="menu-subtitle">早晨 8:00 — 又一个工作日开始了</p>
      <div class="briefing-status">
        <div class="briefing-row">
          <span class="briefing-label">本月 KPI</span>
          <span class="briefing-value">
            {kpi.actualKpi} / {kpi.monthlyThreshold}
          </span>
        </div>
        <div class="briefing-row">
          <span class="briefing-label">精力</span>
          <span class="briefing-value">
            {energy.current} / {energy.max}
            {energy.burnoutFlag ? ' ⚠ 倦怠' : ''}
          </span>
        </div>
      </div>
      <div class="menu-buttons">
        <button type="button" class="menu-button menu-button--primary" onClick={goAction}>
          开始今日
        </button>
      </div>
    </div>
  );
}
