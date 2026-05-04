import { ap } from '@/economy/ap';
import { ENERGY_OT_BASE, OVERTIME_BONUS_AP } from '@/economy/constants';
import { energy } from '@/economy/energy';
import { dayCycle } from '@/flow/day-cycle';

interface Props {
  day: number;
}

export function AfterWork({ day }: Props): preact.JSX.Element {
  const canOT = energy.canOvertime();
  const goOvertime = (): void => {
    if (!canOT) return;
    void dayCycle.confirmAfterWork('overtime');
  };
  const goEnd = (): void => {
    void dayCycle.confirmAfterWork('end_day');
  };

  return (
    <div class="menu-root menu-root--afterwork">
      <h2 class="menu-title menu-title--small">下班时间 · Day {day}</h2>
      <p class="menu-subtitle">
        {ap.current === 0 ? '今日 AP 已用完' : `今日还剩 ${ap.current} AP`}
      </p>
      <div class="briefing-status">
        <div class="briefing-row">
          <span class="briefing-label">当前精力</span>
          <span class="briefing-value">
            {energy.current} / {energy.max}
            {energy.burnoutFlag ? ' ⚠ 倦怠' : ''}
          </span>
        </div>
      </div>
      <div class="menu-buttons">
        <button
          type="button"
          class="menu-button"
          onClick={goOvertime}
          disabled={!canOT}
          style={{ opacity: canOT ? 1 : 0.4, cursor: canOT ? 'pointer' : 'not-allowed' }}
          title={
            !canOT
              ? energy.burnoutFlag
                ? '已倦怠，无法加班'
                : `精力不足（需要 ≥${ENERGY_OT_BASE}）`
              : undefined
          }
        >
          申报加班 (-{ENERGY_OT_BASE} 精力, +{OVERTIME_BONUS_AP} AP)
        </button>
        <button type="button" class="menu-button menu-button--primary" onClick={goEnd}>
          按时下班
        </button>
      </div>
    </div>
  );
}
