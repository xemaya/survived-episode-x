// Round 16 driver — verify Bug #25 (panel + sticky coexist, reverse Bug #13)
// + Bug #27 (AP system delete).
// Latest commits:
//   - 44f0b7a fix(qa-bug-25): panel + sticky coexist (reverse Bug #13 Option B)
//   - 51580f4 fix(qa-bug-27): delete AP system

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

async function getCanvasGeom(page: Page) {
  const box = await page.locator('canvas').boundingBox();
  if (!box) throw new Error('canvas not found');
  return { x: box.x, y: box.y, scaleX: box.width / CANVAS_W, scaleY: box.height / CANVAS_H };
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
  await page.mouse.click(g.x + logical.x * g.scaleX, g.y + logical.y * g.scaleY);
  return true;
}

async function clickPanelToContinue(page: Page) {
  const g = await getCanvasGeom(page);
  // Panel y range now is bottom 1/3 (per Bug #25: PANEL_H 156 → 96, panel at y=256-352)
  await page.mouse.click(g.x + (CANVAS_W / 2) * g.scaleX, g.y + 290 * g.scaleY);
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

async function readPanelText(page: Page): Promise<string> {
  return page.evaluate(() => {
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const app = window.__qa?.app as any;
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const walk = (n: any): string => {
      if (
        typeof n.label === 'string' &&
        (n.label.startsWith('sticky-') || n.label.startsWith('choice-'))
      ) {
        return '';
      }
      let out = '';
      if (typeof n.text === 'string' && n.text.length > 0) out += `${n.text} `;
      for (const c of n.children ?? []) out += walk(c);
      return out;
    };
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const dialog = app?.stage?.children
      ?.find?.((c: any) => c.label === 'world')
      // biome-ignore lint/suspicious/noExplicitAny: walk
      ?.children?.find?.((c: any) => c.label === 'ink-dialog');
    return dialog ? walk(dialog) : '';
  });
}

async function advanceToChoices(page: Page, maxTaps = 12): Promise<number> {
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

async function pickChoiceAndAdvance(page: Page, idx: number) {
  const ok = await clickChoiceByIndex(page, idx);
  if (!ok) throw new Error(`no choice/sticky-${idx} on stage`);
  await page.waitForTimeout(400);
  await advanceToChoices(page);
}

test.describe('P5 demo · Round 16 (verify Bug #25 + Bug #27)', () => {
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

  test('Bug #25 verify: panel + sticky coexist after [开始今日] click (no ▼ defer)', async ({
    page,
  }) => {
    // Per Bug #23: click [新游戏] goes directly to action_day
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);

    // Drive past intro 1/2/3 → Day 1 morning → click [开始今日]
    await advanceToChoices(page);
    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了 → day_1_morning_briefing

    // Day 1 sticky [开始今日] visible
    let labels = await listChoiceLabels(page);
    console.log('[r16-bug25] Day 1 morning sticky:', labels);
    expect(labels[0]).toContain('开始今日');

    // Click [开始今日] WITHOUT advanceToChoices to inspect immediate state
    await clickChoiceByIndex(page, 0);
    await page.waitForTimeout(500);

    // Bug #25 fix: after click, panel + 3 sticky choices (Event 1.2) should
    // appear together — NO ▼ defer phase. Old Bug #13 Option B would have
    // shown empty panel + ▼ first.
    const labelsImmediate = await listChoiceLabels(page);
    const panelImmediate = await readPanelText(page);
    console.log('[r16-bug25] labels immediate after [开始今日]:', labelsImmediate);
    console.log('[r16-bug25] panel head immediate:', panelImmediate.slice(0, 80));

    // Bug #25 expectation: 3 sticky choices visible IMMEDIATELY (no defer)
    expect(labelsImmediate.length).toBe(3);
    expect(labelsImmediate.some((l) => l.includes('Lisa 先'))).toBe(true);
    // Panel should also show narration text (event 1.1 + 1.2 content)
    expect(panelImmediate.length).toBeGreaterThan(20);

    expect(pageErrors.length).toBe(0);
    await page.screenshot({ path: 'qa/output/r16-01-event-1-2-panel-and-sticky.png' });
  });

  test('Bug #27 verify: AP system removed; flow advances without AP-related errors', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    // Drive Day 1 path (intro + events + after_work) — verify no AP-related
    // crashes since AP system is deleted. After_work should now only fire
    // via endDayEarly() trigger, no AP=0 listener.
    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了
    await pickChoiceAndAdvance(page, 0); // 开始今日 → 1.2
    await pickChoiceAndAdvance(page, 0); // 让Lisa先
    await pickChoiceAndAdvance(page, 0); // 还行你呢

    let labels = await listChoiceLabels(page);
    console.log('[r16-bug27] day_1_after_work labels:', labels);
    expect(labels.length).toBeGreaterThanOrEqual(3);
    // After_work choices should still be there per ink content (申报加班/按时下班/提前下班)
    const onTimeIdx = labels.findIndex((l) => l.includes('按时下班'));
    expect(onTimeIdx).toBeGreaterThanOrEqual(0);

    await pickChoiceAndAdvance(page, onTimeIdx);

    // Day 2 morning [开始今日] should appear without AP-related issues
    labels = await listChoiceLabels(page);
    console.log('[r16-bug27] Day 2 morning:', labels);
    expect(labels[0]).toContain('开始今日');

    // No AP errors in console
    expect(pageErrors.length).toBe(0);
  });

  test('Re-verify Bug #6 / #11 / #14 / #18-regression / #19 / #21 / #23 (no regressions)', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    // Bug #23: direct to action_day
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(500);
    await advanceToChoices(page);

    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0);
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

    // Bug #6: long sticky ellipsis still works
    const ev23 = await listChoiceLabels(page);
    expect(ev23.length).toBe(3);
    const longChoice = ev23.find((l) => l.includes('主动跟老周说'));
    expect(longChoice?.includes('…')).toBe(true);

    // Bug #18-regression: no stale Lisa "你喝什么" bubble
    const bubbleText = await page.evaluate(() => {
      // biome-ignore lint/suspicious/noExplicitAny: walk
      const app = window.__qa?.app as any;
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
    expect(bubbleText.some((t) => t.includes('你喝什么'))).toBe(false);

    expect(pageErrors.length).toBe(0);
  });
});
