// Q-Q (Bug #31, avg-architecture.md §2.5): KPI Review cinematic.
//
// Pacing per spec:
//   1. PRE_REVEAL_MS pause — 静音 anticipation, no numbers visible
//   2. Reveal 4 rows in sequence with tick-up animation (REVEAL_ROW_MS each):
//      - 本月 KPI (tick from 0 → actualKpi)
//      - 当月阈值 (static)
//      - 比率 (computed from above)
//      - 下月阈值 prediction bar
//   3. HR-speak block (5 paths a-e — ink-driven via `# kpi_review_path_X`
//      tag, captured by `kpi-review-cinematic.ts`'s tag listener;
//      fallback to engine prose when ink hasn't authored the line)
//   4. Attribution line "——这是您的 reward"
//   5. Confirm button — flushes state via dayCycle.confirmKpiReview

import { kpi } from '@/economy/kpi';
import { dayCycle } from '@/flow/day-cycle';
import { ink } from '@/ink/runtime';
import { useEffect, useState } from 'preact/hooks';
import {
  type KpiReviewPath,
  PRE_REVEAL_MS,
  REVEAL_ROWS,
  REVEAL_ROW_MS,
  inferPathFromKpi,
  kpiReviewCinematic,
} from './kpi-review-cinematic';

interface Props {
  monthIndex: number;
}

const PROMOTION_VAR = 'promotion_candidate_count';

function readPromotionCount(): number {
  if (!ink.isLoaded) return 0;
  const v = ink.getVar<number>(PROMOTION_VAR);
  return typeof v === 'number' ? v : 0;
}

function tickUp(target: number, progress: number): number {
  return Math.round(target * Math.min(1, Math.max(0, progress)));
}

export function KpiReview({ monthIndex }: Props): preact.JSX.Element {
  const actualKpi = kpi.actualKpi;
  const threshold = kpi.monthlyThreshold;
  const ratio = threshold > 0 ? actualKpi / threshold : 0;
  const capacityNow = Math.round(kpi.capacityNow);
  const promotionCount = readPromotionCount();
  const path: KpiReviewPath =
    kpiReviewCinematic.path ?? inferPathFromKpi(actualKpi, threshold, promotionCount);
  const hrSpeak = kpiReviewCinematic.fallback(path);

  // 0 = pre-reveal pause, 1-4 = each row revealed, REVEAL_ROWS = all done.
  const [revealStage, setRevealStage] = useState(0);
  // Per-row tick-up progress 0..1 — used for KPI row only.
  const [kpiTick, setKpiTick] = useState(0);

  useEffect(() => {
    let cancelled = false;
    const timeouts: number[] = [];

    // Pre-reveal pause.
    timeouts.push(
      window.setTimeout(() => {
        if (cancelled) return;
        setRevealStage(1);
        // Animate KPI tick-up over the row's reveal window.
        const start = performance.now();
        const tickFrame = () => {
          if (cancelled) return;
          const dt = performance.now() - start;
          const p = Math.min(1, dt / REVEAL_ROW_MS);
          setKpiTick(p);
          if (p < 1) requestAnimationFrame(tickFrame);
        };
        requestAnimationFrame(tickFrame);
      }, PRE_REVEAL_MS),
    );

    // Stage 2-4 (threshold, ratio, capacity bar).
    for (let i = 2; i <= REVEAL_ROWS; i++) {
      const stageIndex = i;
      timeouts.push(
        window.setTimeout(
          () => {
            if (cancelled) return;
            setRevealStage(stageIndex);
          },
          PRE_REVEAL_MS + (i - 1) * REVEAL_ROW_MS,
        ),
      );
    }

    return () => {
      cancelled = true;
      for (const id of timeouts) window.clearTimeout(id);
    };
  }, []);

  const confirm = (): void => {
    kpiReviewCinematic.reset();
    void dayCycle.confirmKpiReview();
  };

  const allRevealed = revealStage >= REVEAL_ROWS;
  const displayKpi = revealStage >= 1 ? tickUp(actualKpi, kpiTick) : 0;
  const displayThreshold = revealStage >= 2 ? threshold : null;
  const displayRatio = revealStage >= 3 ? `${(ratio * 100).toFixed(0)}%` : null;
  const displayCapacity = revealStage >= 4 ? capacityNow : null;

  return (
    <div class="menu-root menu-root--review">
      <h2 class="menu-title menu-title--small">月末考核 · 第 {monthIndex} 月</h2>
      <p class="menu-subtitle">{revealStage === 0 ? '审核中…' : '——这是您的 reward'}</p>
      <div class="recap-rows">
        <div class="recap-row">
          <span class="recap-label">本月 KPI</span>
          <span class="recap-value">{revealStage >= 1 ? displayKpi : '—'}</span>
        </div>
        <div class="recap-row">
          <span class="recap-label">当月阈值</span>
          <span class="recap-value">{displayThreshold ?? '—'}</span>
        </div>
        <div class="recap-row">
          <span class="recap-label">完成率</span>
          <span class="recap-value">{displayRatio ?? '—'}</span>
        </div>
        <div class="recap-row recap-row--separator">
          <span class="recap-label">下月产能余量</span>
          <span class="recap-value">{displayCapacity ?? '—'}</span>
        </div>
      </div>
      {allRevealed && (
        <p class="menu-subtitle" style={{ maxWidth: '480px' }}>
          {hrSpeak}
        </p>
      )}
      <div class="menu-buttons">
        <button
          type="button"
          class="menu-button menu-button--primary"
          onClick={confirm}
          disabled={!allRevealed}
          style={{
            opacity: allRevealed ? 1 : 0.4,
            cursor: allRevealed ? 'pointer' : 'not-allowed',
          }}
        >
          确认归档
        </button>
      </div>
    </div>
  );
}
