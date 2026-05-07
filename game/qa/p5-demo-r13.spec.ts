// Round 13 driver — Bug #20 doc-close (no engine change). Use this round to
// extend coverage past Day 3 first event into Day 3 after_work + Day 4 events.
// Latest commit: 5de6eb9 fix(qa-bug-20): close by Bug #19 fix dependency

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
  await page.mouse.click(g.x + (CANVAS_W / 2) * g.scaleX, g.y + 274 * g.scaleY);
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

test.describe('P5 demo · Round 13 (extend Day 3-4 coverage)', () => {
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

  test('Drive Day 1 → Day 2 → Day 3 events 3.2 → 3.4 → day_3_after_work → Day 4 morning', async ({
    page,
  }) => {
    const beats: { day: number; choices: string[] }[] = [];

    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    // Intro
    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0);
    // Day 1
    await pickChoiceAndAdvance(page, 0); // 开始今日
    await pickChoiceAndAdvance(page, 0); // 让Lisa先
    await pickChoiceAndAdvance(page, 0); // 还行你呢
    let labels = await listChoiceLabels(page);
    const day1OnTime = labels.findIndex((l) => l.includes('按时下班'));
    await pickChoiceAndAdvance(page, day1OnTime);
    // Day 2
    labels = await listChoiceLabels(page);
    if (labels[0]?.includes('开始今日')) await pickChoiceAndAdvance(page, 0);
    const ev21 = await listChoiceLabels(page);
    beats.push({ day: 2, choices: ev21 });
    if (ev21.length) await pickChoiceAndAdvance(page, 0);
    const ev23 = await listChoiceLabels(page);
    beats.push({ day: 2, choices: ev23 });
    if (ev23.length) await pickChoiceAndAdvance(page, 0); // Day 2 stub after_work + recap → Day 3

    // Day 3 morning [开始今日]
    labels = await listChoiceLabels(page);
    console.log('[r13] Day 3 morning_briefing:', labels);
    expect(labels[0]).toContain('开始今日');
    await pickChoiceAndAdvance(page, 0);

    // Day 3 first event with choices = Event 3.2 (Lisa after meeting): 看大家吧 / 我不去 / 我也不知道
    const day3E2 = await listChoiceLabels(page);
    console.log('[r13] Day 3 Event 3.2:', day3E2);
    beats.push({ day: 3, choices: day3E2 });
    expect(day3E2.length).toBe(3);
    expect(day3E2.some((l) => l.includes('看大家吧'))).toBe(true);
    await pickChoiceAndAdvance(page, 0); // 看大家吧

    // Day 3 has 3.3 (老周吃面, no choices) + 3.4 (coffee_machine_callback, no choices) +
    // day_3_after_work (3 choices)
    const day3AW = await listChoiceLabels(page);
    console.log('[r13] Day 3 after_work:', day3AW);
    beats.push({ day: 3, choices: day3AW });
    expect(day3AW.length).toBeGreaterThanOrEqual(3);
    expect(day3AW.some((l) => l.includes('按时下班'))).toBe(true);

    const day3OnTime = day3AW.findIndex((l) => l.includes('按时下班'));
    await pickChoiceAndAdvance(page, day3OnTime);

    // Day 4 morning_briefing [开始今日]
    const day4Open = await listChoiceLabels(page);
    console.log('[r13] Day 4 morning_briefing:', day4Open);
    beats.push({ day: 4, choices: day4Open });
    expect(day4Open[0]).toContain('开始今日');
    await pickChoiceAndAdvance(page, 0);

    // Day 4 first event with choices — Event 4.2 (weekly_report) per ink:1106-1116
    const day4E1 = await listChoiceLabels(page);
    console.log('[r13] Day 4 first choice event:', day4E1);
    beats.push({ day: 4, choices: day4E1 });
    expect(day4E1.length).toBe(3);
    expect(day4E1.some((l) => l.includes('提交') || l.includes('改'))).toBe(true);

    console.log(
      '[r13] beats reached:',
      beats.map((b) => `Day ${b.day}: [${b.choices.join('|')}]`),
    );
    expect(pageErrors.length).toBe(0);
    await page.screenshot({ path: 'qa/output/r13-01-day4-first-event.png' });
  });
});
