// Round 6 driver — verify Bug #18 fix (speech bubble teardown on deferred-
// choices flush). Latest commits:
//   - a576f7a fix(qa-bug-18): tear down speech bubble + monologue on deferred-choices flush
//   - 63931dc fix(qa-bug-13): defer sticky rack behind ▼ click; header band for short prompts

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

async function listAllStageLabels(page: Page): Promise<string[]> {
  return page.evaluate(() => {
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const app = window.__qa?.app as any;
    if (!app?.stage) return [];
    const out: string[] = [];
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const walk = (n: any) => {
      if (typeof n.label === 'string' && n.label.length > 0) out.push(n.label);
      for (const c of n.children ?? []) walk(c);
    };
    walk(app.stage);
    return out;
  });
}

/** Read ALL Text node values inside speech-bubble containers (if any). */
async function readSpeechBubbleText(page: Page): Promise<string[]> {
  return page.evaluate(() => {
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const app = window.__qa?.app as any;
    if (!app?.stage) return [];
    const out: string[] = [];
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const walkBubble = (n: any) => {
      if (typeof n.text === 'string' && n.text.length > 0) out.push(n.text);
      for (const c of n.children ?? []) walkBubble(c);
    };
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const findBubbles = (n: any): void => {
      if (n.label === 'speech-bubble') walkBubble(n);
      for (const c of n.children ?? []) findBubbles(c);
    };
    findBubbles(app.stage);
    return out;
  });
}

async function advanceToChoices(page: Page, maxTaps = 8): Promise<number> {
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

test.describe('P5 demo · Round 6 (verify Bug #18 fix + Bug #13 commit)', () => {
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

  test('Bug #18 verify: Lisa stale bubble does NOT persist into Day 2 Event 2.3', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了 → day_1
    await pickChoiceAndAdvance(page, 0); // 开始今日 → 1.2
    await pickChoiceAndAdvance(page, 0); // 让Lisa先 → 1.3
    await pickChoiceAndAdvance(page, 0); // 还行你呢 → 1.4-1.6 + after_work
    let labels = await listChoiceLabels(page);
    const onTimeIdx = labels.findIndex((l) => l.includes('按时下班'));
    await pickChoiceAndAdvance(page, onTimeIdx);
    labels = await listChoiceLabels(page);
    if (labels[0]?.includes('开始今日')) await pickChoiceAndAdvance(page, 0);

    // Day 2 Event 2.1 — pick [一起] which mounts Lisa "你喝什么?" bubble
    const ev21 = await listChoiceLabels(page);
    console.log('[r6-bug18] Day 2 Event 2.1:', ev21);
    expect(ev21.length).toBe(3);
    await pickChoiceAndAdvance(page, 0); // 一起

    // Now at Day 2 Event 2.3 (老周凉茶) — sticky rack visible
    const ev23 = await listChoiceLabels(page);
    console.log('[r6-bug18] Day 2 Event 2.3:', ev23);
    expect(ev23.length).toBe(3);
    expect(ev23[0]).toContain('偷喝那杯');

    // Bug #18 fix: speech bubble from Event 2.1 should be GONE.
    const allLabels = await listAllStageLabels(page);
    const speechBubbles = allLabels.filter((l) => l === 'speech-bubble');
    console.log('[r6-bug18] speech-bubble count at Event 2.3:', speechBubbles.length);

    const bubbleText = await readSpeechBubbleText(page);
    console.log('[r6-bug18] speech-bubble text content at Event 2.3:', bubbleText);
    expect(bubbleText.some((t) => t.includes('你喝什么'))).toBe(false); // Bug #18 fix: stale bubble cleared

    await page.screenshot({ path: 'qa/output/r6-01-event-2-3-no-stale-bubble.png' });
    expect(pageErrors.length).toBe(0);
  });

  test('Bug #13 commit verify: choice presentation is gated by ▼ for long narration', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了 → day_1

    // Click [开始今日] — but DON'T use pickChoiceAndAdvance since deferred-choices
    // means we want to inspect the intermediate state.
    await clickChoiceByIndex(page, 0);
    await page.waitForTimeout(500);

    // Bug #13 fix: long narration (Event 1.1 + 1.2 blob > 60 chars) should be in
    // deferred-choices phase: panel + ▼ visible, sticky rack NOT yet mounted.
    const labelsImm = await listChoiceLabels(page);
    console.log('[r6-bug13] labels right after [开始今日]:', labelsImm);

    // Sticky rack should not be there yet (deferred-choices phase).
    expect(labelsImm.length).toBe(0); // panel + ▼ phase, no sticky yet

    // Click panel to flush — sticky rack should now appear
    await clickPanelToContinue(page);
    await page.waitForTimeout(500);
    const labelsAfterFlush = await listChoiceLabels(page);
    console.log('[r6-bug13] labels after panel ▼ flush:', labelsAfterFlush);
    expect(labelsAfterFlush.length).toBe(3);

    await page.screenshot({ path: 'qa/output/r6-02-event-1-2-after-flush.png' });
  });

  test('Re-verify Bug #3 + Bug #6 + earlier (no regressions)', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了
    await pickChoiceAndAdvance(page, 0); // 开始今日
    await pickChoiceAndAdvance(page, 0); // 让Lisa先
    await pickChoiceAndAdvance(page, 0); // 还行你呢
    let labels = await listChoiceLabels(page);
    const onTimeIdx = labels.findIndex((l) => l.includes('按时下班'));
    await pickChoiceAndAdvance(page, onTimeIdx);
    labels = await listChoiceLabels(page);
    if (labels[0]?.includes('开始今日')) await pickChoiceAndAdvance(page, 0);
    const ev21 = await listChoiceLabels(page);
    if (ev21.length) await pickChoiceAndAdvance(page, 0);

    const ev23 = await listChoiceLabels(page);
    expect(ev23.length).toBe(3);
    const longChoice = ev23.find((l) => l.includes('主动跟老周说'));
    expect(longChoice).toBeDefined();
    expect(longChoice?.includes('…')).toBe(true);

    // Bug #1 verify: pick [偷喝那杯，再走] → no crash
    const errBefore = pageErrors.length;
    await clickChoiceByIndex(page, 0);
    await page.waitForTimeout(800);
    expect(pageErrors.length).toBe(errBefore);
    expect(pageErrors.length).toBe(0);
  });
});
