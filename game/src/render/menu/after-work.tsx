import { ENERGY_OT_BASE } from '@/economy/constants';
import { energy } from '@/economy/energy';
import { dayCycle } from '@/flow/day-cycle';

interface Props {
  day: number;
}

// P0-P4 holdover overlay. Bug #7 (designer scope) is still discussing
// whether 提前下班 lives here or stays an ink choice; until that lands
// we keep the overlay but with the AP messaging removed (Bug #27 — AP
// system deleted; only effort/energy still apply for overtime).
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
          申报加班 (-{ENERGY_OT_BASE} 精力)
        </button>
        <button type="button" class="menu-button menu-button--primary" onClick={goEnd}>
          按时下班
        </button>
      </div>
    </div>
  );
}
