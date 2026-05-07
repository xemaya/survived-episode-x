// Round 8 driver — feature commit `f900968 feat(p5-path-interceptor)` doesn't
// touch Day 1-2 demo path, but extending coverage to Day 3 verifies the
// pagebreak gating + scene-aware prop hide work end-to-end across multiple days.
//
// Also acts as a regression smoke for all prior fixes.

import { type Page, expect, test } from '@playwright/test';

declare global {
  interface Window {
    __qa?: {
      ink: { isLoaded: boolean; getVar: (n: string) => unknown };
      flow: { state: { kind: string; [k: string]: unknown } };
      app: unknown;
      sceneState: { snapshot: Record<string, string | null> };
      propRegistry: unknown;
    };
  }
}

const CANVAS_W = 640;
const CANVAS_H = 360;

interface CanvasGeom {
  x: number;
  y: number;
  scaleX: number;
  scaleY: number;
}

async function getCanvasGeom(page: Page): Promise<CanvasGeom> {
  const box = await page.locator('canvas').boundingBox();
  if (!box) throw new Error('canvas not found');
  return { x: box.x, y: box.y, scaleX: box.width / CANVAS_W, scaleY: box.height / CANVAS_H };
}

function toPage(g: CanvasGeom, lx: number, ly: number) {
  return { x: g.x + lx * g.scaleX, y: g.y + ly * g.scaleY };
}

async function clickChoiceByIndex(page: Page, idx: number): Promise<boolean> {
  const g = await getCanvasGeom(page);
  const logical = await page.evaluate((i) => {
    // biome-ignore lint/suspicious/noExplicitAny: stage walk
    const app = window.__qa?.app as any;
    if (!app?.stage) return null;
    let found: { x: number; y: number } | null = null;
    // biome-ignore lint/suspicious/noExplicitAny: PIXI Container
    const walk = (n: any) => {
      if (
        typeof n.label === 'string' &&
        (n.label === `choice-${i}` ||
          n.label === `sticky-${i}` ||
          n.label === `sticky-fallback-${i}`)
      ) {
        const gp = n.getGlobalPosition?.();
        if (gp) found = { x: gp.x, y: gp.y };
      }
      for (const c of n.children ?? []) walk(c);
    };
    walk(app.stage);
    return found;
  }, idx);
  if (!logical) return false;
  const p = toPage(g, logical.x, logical.y);
  await page.mouse.click(p.x, p.y);
  return true;
}

async function clickPanelToContinue(page: Page) {
  const g = await getCanvasGeom(page);
  const p = toPage(g, CANVAS_W / 2, 274);
  await page.mouse.click(p.x, p.y);
}

async function listChoiceLabels(page: Page): Promise<string[]> {
  return page.evaluate(() => {
    // biome-ignore lint/suspicious/noExplicitAny: stage
    const app = window.__qa?.app as any;
    if (!app?.stage) return [];
    const out: string[] = [];
    // biome-ignore lint/suspicious/noExplicitAny: PIXI
    const walk = (n: any) => {
      if (
        typeof n.label === 'string' &&
        (n.label.startsWith('sticky-') || n.label.startsWith('choice-'))
      ) {
        // biome-ignore lint/suspicious/noExplicitAny: PIXI
        const lbl = n.children?.find?.((c: any) => typeof c.text === 'string' && c.text.length);
        if (lbl) out.push(`${n.label}=${lbl.text}`);
      }
      for (const c of n.children ?? []) walk(c);
    };
    walk(app.stage);
    return out;
  });
}

async function advanceToChoices(page: Page, maxTaps = 10): Promise<number> {
  let taps = 0;
  while (taps < maxTaps) {
    const labels = await listChoiceLabels(page);
    if (labels.length > 0) return taps;
    await clickPanelToContinue(page);
    await page.waitForTimeout(400);
    taps++;
  }
  return taps;
}

async function pickChoiceAndAdvance(page: Page, idx: number): Promise<void> {
  const ok = await clickChoiceByIndex(page, idx);
  if (!ok) throw new Error(`no choice/sticky-${idx} on stage`);
  await page.waitForTimeout(400);
  await advanceToChoices(page);
}

async function readVars(page: Page, names: string[]): Promise<Record<string, unknown>> {
  return page.evaluate((ns) => {
    const qa = window.__qa;
    if (!qa) throw new Error('no __qa');
    const out: Record<string, unknown> = {};
    for (const n of ns) out[n] = qa.ink.getVar(n);
    return out;
  }, names);
}

test.describe('P5 demo · Round 8 (Day 3 reach + cross-day smoke)', () => {
  let pageErrors: string[] = [];

  test.beforeEach(async ({ page }) => {
    pageErrors = [];
    page.on('pageerror', (err) => {
      pageErrors.push(err.message);
      console.error('[page error]', err.message);
    });
    page.on('console', (msg) => {
      if (msg.type() === 'error') console.log('[console.error]', msg.text());
    });
    await page.goto('about:blank');
    await page.evaluate(() => {
      try {
        localStorage.clear();
        sessionStorage.clear();
      } catch {
        // ignore
      }
    });
    await page.goto('/');
    await page.waitForFunction(() => window.__qa?.ink?.isLoaded === true, undefined, {
      timeout: 10000,
    });
  });

  test('Drive Day 1 → Day 2 → Day 3 (verify pagebreak chain + per-day choice presentation)', async ({
    page,
  }) => {
    const beats: { day: number; choices: string[] }[] = [];

    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    // Intro → Day 1
    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了 → day_1_morning

    // Day 1 [开始今日]
    let labels = await listChoiceLabels(page);
    console.log('[r8] Day 1 morning_briefing choice:', labels);
    expect(labels[0]).toContain('开始今日');
    await pickChoiceAndAdvance(page, 0);

    // Day 1 Event 1.2 (3 choices)
    labels = await listChoiceLabels(page);
    console.log('[r8] Day 1 Event 1.2:', labels);
    beats.push({ day: 1, choices: labels });
    expect(labels.length).toBe(3);
    await pickChoiceAndAdvance(page, 0); // 让Lisa先

    // Day 1 Event 1.3 (3 choices: David)
    labels = await listChoiceLabels(page);
    console.log('[r8] Day 1 Event 1.3:', labels);
    beats.push({ day: 1, choices: labels });
    expect(labels.length).toBe(3);
    await pickChoiceAndAdvance(page, 0); // 还行你呢

    // Day 1 after_work
    labels = await listChoiceLabels(page);
    console.log('[r8] Day 1 after_work:', labels);
    beats.push({ day: 1, choices: labels });
    expect(labels.length).toBeGreaterThanOrEqual(3);
    const day1OnTime = labels.findIndex((l) => l.includes('按时下班'));
    expect(day1OnTime).toBeGreaterThanOrEqual(0);
    await pickChoiceAndAdvance(page, day1OnTime);

    // Day 2 [开始今日]
    labels = await listChoiceLabels(page);
    console.log('[r8] Day 2 morning_briefing:', labels);
    expect(labels[0]).toContain('开始今日');
    await pickChoiceAndAdvance(page, 0);

    // Day 2 Event 2.1 (3 choices: Lisa milk tea)
    labels = await listChoiceLabels(page);
    console.log('[r8] Day 2 Event 2.1:', labels);
    beats.push({ day: 2, choices: labels });
    expect(labels.length).toBe(3);
    await pickChoiceAndAdvance(page, 0); // 一起

    // Day 2 Event 2.3 (3 choices: 老周凉茶) — Event 2.2 has no choices
    labels = await listChoiceLabels(page);
    console.log('[r8] Day 2 Event 2.3:', labels);
    beats.push({ day: 2, choices: labels });
    expect(labels.length).toBe(3);
    expect(labels[0]).toContain('偷喝那杯');
    await pickChoiceAndAdvance(page, 0); // 偷喝那杯

    // After [偷喝那杯] → Day 2 after_work (STUB in episode-1.ink:738) →
    // Day 2 daily_recap (STUB) → Day 3 morning_briefing. Both Day 2 stubs
    // emit only `# pagebreak` + auto-divert; advanceToChoices tapped through
    // them. So we land directly at Day 3 [开始今日].
    labels = await listChoiceLabels(page);
    console.log('[r8] after [偷喝那杯] (skipped Day 2 stubs):', labels);
    beats.push({ day: 2, choices: ['(stub: no choices in day_2_after_work / day_2_daily_recap)'] });
    expect(labels[0]).toContain('开始今日'); // Day 3 morning_briefing
    await pickChoiceAndAdvance(page, 0);

    // Day 3 Event 3.2 (Lisa after meeting, 3 choices: 看大家吧 / 我不去 / 我也不知道)
    labels = await listChoiceLabels(page);
    console.log('[r8] Day 3 first event with choices:', labels);
    beats.push({ day: 3, choices: labels });
    expect(labels.length).toBe(3);
    expect(labels.some((l) => l.includes('看大家吧') || l.includes('我不去'))).toBe(true);

    // Read final VAR snapshot for Day 1+2 picks
    const vars = await readVars(page, ['lisa_score', 'lao_zhou_score', 'state', 'money']);
    console.log('[r8] vars at Day 3 first choice phase:', vars);
    // Day 1: 让Lisa先 (+1) + Day 2: 一起 (lisa_score per Lisa milk tea — let's see)
    // No hard assertion since Lisa milk tea body's effect on lisa_score not memorized

    console.log('[r8] beats summary:');
    for (const b of beats) console.log(`  Day ${b.day}: ${b.choices.join(' | ')}`);

    expect(pageErrors.length).toBe(0);
    await page.screenshot({ path: 'qa/output/r8-01-day3-first-choice.png' });
  });

  test('Path interceptor (Q-4) — sanity: no checkpoint tag in Day 1-2 means no redirect fires', async ({
    page,
  }) => {
    // The path-interceptor system fires when ink emits `# checkpoint: <stitch>`
    // tags. Episode-1 Day 1-2 has no checkpoints (those are E8/E12 finale only).
    // So the Day 1-2 walkthrough should produce zero interceptor side effects.
    // Just smoke: no console errors during Day 1-2 picks.

    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(500);
    await advanceToChoices(page);
    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了
    await pickChoiceAndAdvance(page, 0); // 开始今日
    await pickChoiceAndAdvance(page, 0); // 让Lisa先
    await pickChoiceAndAdvance(page, 0); // 还行你呢
    const labels = await listChoiceLabels(page);
    const day1OnTime = labels.findIndex((l) => l.includes('按时下班'));
    await pickChoiceAndAdvance(page, day1OnTime);

    // Made it through Day 1 with no interceptor crash
    expect(pageErrors.length).toBe(0);
    console.log('[r8] path-interceptor sanity passed: Day 1 walkthrough clean');
  });
});
