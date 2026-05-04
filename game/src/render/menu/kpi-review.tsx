import {
  KPI_EFFORT_WEIGHT,
  KPI_POTENTIAL_WEIGHT,
  KPI_TENURE_WEIGHT,
  POTENTIAL_CLAMP_MAX,
  POTENTIAL_CLAMP_MIN,
} from '@/economy/constants';
import { kpi } from '@/economy/kpi';
import { dayCycle } from '@/flow/day-cycle';

interface Props {
  monthIndex: number;
}

// design/gdd/kpi-review-game-over-ui.md: 3-row HR-tone breakdown of
// next-month threshold contributions (effort / potential / tenure %),
// plus a single capacity-vs-threshold comparison line. Confirm dismiss.
// SFX anchors at 800ms (PUNCH_CLOCK) + 1000ms (RECEIPT_HISS) deferred —
// audio is P4+ scope.

export function KpiReview({ monthIndex }: Props): preact.JSX.Element {
  // P3 only the potential term contributes meaningfully (effort_norm = 0,
  // tenure γ_effective = 0 in month 1). Compute the contribution % each
  // dimension WOULD add to the next threshold.
  const rawPotential = (kpi.actualKpi - kpi.monthlyThreshold) / kpi.monthlyThreshold;
  const potentialClamped = Math.max(
    POTENTIAL_CLAMP_MIN,
    Math.min(POTENTIAL_CLAMP_MAX, rawPotential),
  );

  const effortPct = (KPI_EFFORT_WEIGHT * 0 * 100).toFixed(1); // P3: 0
  const potentialPct = (KPI_POTENTIAL_WEIGHT * potentialClamped * 100).toFixed(1);
  const tenureGammaEff = monthIndex <= 1 ? 0 : KPI_TENURE_WEIGHT;
  const tenurePct = (tenureGammaEff * monthIndex * 100).toFixed(1);

  const tenureDisplay = monthIndex <= 1 ? '— (新人豁免)' : `${tenurePct}%`;

  return (
    <div class="menu-root menu-root--review">
      <h2 class="menu-title menu-title--small">月末考核 · 第 {monthIndex} 月</h2>
      <p class="menu-subtitle">下月 KPI 阈值贡献率</p>
      <div class="recap-rows">
        <div class="recap-row">
          <span class="recap-label">积极性贡献</span>
          <span class="recap-value">{effortPct}%</span>
        </div>
        <div class="recap-row">
          <span class="recap-label">潜力贡献</span>
          <span class="recap-value">{potentialPct}%</span>
        </div>
        <div class="recap-row">
          <span class="recap-label">资历贡献</span>
          <span class="recap-value">{tenureDisplay}</span>
        </div>
        <div class="recap-row recap-row--separator">
          <span class="recap-label">产能余量</span>
          <span class="recap-value">{Math.round(kpi.capacityNow)} → 下月阈值待结算</span>
        </div>
      </div>
      <div class="menu-buttons">
        <button
          type="button"
          class="menu-button menu-button--primary"
          onClick={() => dayCycle.confirmKpiReview()}
        >
          确认归档
        </button>
      </div>
    </div>
  );
}
