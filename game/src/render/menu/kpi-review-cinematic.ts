// Q-Q (Bug #31): pure helpers + tag-driven path state for the KPI
// Review cinematic. Captures the latest `# kpi_review_path_<a-e>`
// tag emission so the KpiReview component can render the matching
// HR-speak block. Also exposes pacing math (tick-up timing) so the
// component stays declarative.
//
// Spec: avg-architecture.md §2.5 + p5-qa-bug-reports.md Bug #31.
//
// 5 path keys (designer convention):
//   a — 高产能 (KPI ≥ threshold * 1.2, no over-threshold)
//   b — 压线通过 (KPI in [threshold, threshold*1.2))
//   c — 不及格 (KPI in [threshold*0.5, threshold))
//   d — 晋升候选 (cumulative_over_count ≥ 3 — separate from a/b)
//   e — 红线 (KPI < threshold * 0.5, dismissal_severe imminent)
//
// W3 authors the canonical HR-speak phrases per path inside the
// .ink content via `# kpi_review_path_X` tags emitted from the
// month-end stitch. Engine fallback below is generic and OK for
// playtest until W3 lands.

import { tagDispatcher } from '@/ink/tag-interceptors';

export type KpiReviewPath = 'a' | 'b' | 'c' | 'd' | 'e';

const VALID_PATHS: ReadonlySet<string> = new Set(['a', 'b', 'c', 'd', 'e']);

export const HR_SPEAK_FALLBACK: Readonly<Record<KpiReviewPath, string>> = {
  a: '您的全月输出超出预期。已纳入下月加压档。继续保持。',
  b: '您勉强通过。下月需要更进一步——产能还在窗口期。',
  c: '本月业绩低于预期。已为您安排"潜力对齐谈话"。',
  d: '您的累积表现进入晋升候选评估。请保持当前节奏。',
  e: '您的指标已触及离职红线。下月若不能回升，将启动评估流程。',
};

/** Singleton state — mutated by tag dispatcher, read by KpiReview. */
class KpiReviewCinematicState {
  private _path: KpiReviewPath | null = null;

  /** Latest path captured from a `# kpi_review_path_<X>` tag. Cleared
   * on `confirmKpiReview` so the next month-end starts fresh. */
  get path(): KpiReviewPath | null {
    return this._path;
  }

  setPath(value: string): void {
    const v = value.trim().toLowerCase();
    if (VALID_PATHS.has(v)) {
      this._path = v as KpiReviewPath;
    } else {
      console.warn('[kpi-review-cinematic] unknown path:', value);
    }
  }

  reset(): void {
    this._path = null;
  }

  /** Render-side fallback when ink hasn't fired a path tag (W3 not
   * yet authoring this episode's path text). Returns generic
   * HR-speak prose tuned to whichever path the cinematic would
   * have lit — caller infers the right fallback path from KPI math
   * via `inferPathFromKpi`. */
  fallback(path: KpiReviewPath): string {
    return HR_SPEAK_FALLBACK[path];
  }
}

export const kpiReviewCinematic = new KpiReviewCinematicState();

/** Infer which path the cinematic should show based on KPI math.
 * Used by KpiReview when `# kpi_review_path` tag wasn't fired. */
export function inferPathFromKpi(
  actualKpi: number,
  monthlyThreshold: number,
  promotionCandidateCount: number,
): KpiReviewPath {
  if (promotionCandidateCount >= 3) return 'd';
  const ratio = monthlyThreshold > 0 ? actualKpi / monthlyThreshold : 0;
  if (ratio < 0.5) return 'e';
  if (ratio < 1.0) return 'c';
  if (ratio < 1.2) return 'b';
  return 'a';
}

// Tag plumbing: `# kpi_review_path_<a-e>` → cinematic.setPath. Single
// listener installed at module load; the singleton state survives
// across reviews (caller resets via `confirmKpiReview` flow).
tagDispatcher.on('kpi_review_path', (t) => {
  kpiReviewCinematic.setPath(t.value);
});

/** Cinematic timing constants (ms). 1.5 s pre-reveal pause + 4-row
 * tick-up at 1.2 s each = ~6.3 s total before player can confirm.
 * Skip button still possible — Confirm 按钮 tied to last reveal. */
export const PRE_REVEAL_MS = 1500;
export const REVEAL_ROW_MS = 1200;
export const REVEAL_ROWS = 4; // KPI / 阈值 / ratio / 下月 bar
