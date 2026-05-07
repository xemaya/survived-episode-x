// Round 15 driver — verify Bug #23 fix (delete morning_briefing card; new game
// → action_day directly).
// Latest commit: 89c8a29 fix(qa-bug-23)

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

test.describe('P5 demo · Round 15 (verify Bug #23 fix — morning_briefing card deleted)', () => {
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

  test('Bug #23 verify: [新游戏] click goes directly to action_day, no morning_briefing card', async ({
    page,
  }) => {
    // Click 新游戏 — should transition straight to action_day, NOT show
    // morning_briefing Preact overlay
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day', undefined, {
      timeout: 5000,
    });
    const flowKind = await page.evaluate(() => window.__qa?.flow.state.kind);
    console.log('[r15-bug23] flow.kind after [新游戏]:', flowKind);
    expect(flowKind).toBe('action_day');

    // Verify morning_briefing button [开始今日] does NOT exist (card deleted)
    const startTodayCount = await page.getByRole('button', { name: '开始今日' }).count();
    console.log('[r15-bug23] [开始今日] Preact button count:', startTodayCount);
    expect(startTodayCount).toBe(0);

    // Workstation scene + ink dialog should mount immediately
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    // First choice should be intro [然后呢]
    const introChoices = await listChoiceLabels(page);
    console.log('[r15-bug23] intro screen 1 sticky:', introChoices);
    expect(introChoices[0]).toContain('然后呢');

    expect(pageErrors.length).toBe(0);
    await page.screenshot({ path: 'qa/output/r15-01-direct-action-day.png' });
  });

  test('Re-verify Day 1-2 flow still works (no morning_briefing intermediate)', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    // Intro
    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了

    // Day 1 — first choice rack appears (no longer needs [开始今日] from card)
    let labels = await listChoiceLabels(page);
    console.log('[r15-day1-first-choice]:', labels);
    // Day 1 morning_briefing → Event 1.1 → 1.2's [开始今日] sticky inside ink narrative
    // OR may be Event 1.2's 3 choices directly
    expect(labels.length).toBeGreaterThanOrEqual(1);

    // If [开始今日] is the in-ink sticky, click it
    if (labels[0]?.includes('开始今日')) {
      await pickChoiceAndAdvance(page, 0);
      labels = await listChoiceLabels(page);
    }

    // Now should be at Event 1.2 (3 choices)
    console.log('[r15] Event 1.2:', labels);
    expect(labels.length).toBe(3);
    expect(labels.some((l) => l.includes('Lisa 先'))).toBe(true);

    // Pick 让Lisa先 → Event 1.3 → ... → after_work
    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0); // 还行你呢
    labels = await listChoiceLabels(page);
    const onTimeIdx = labels.findIndex((l) => l.includes('按时下班'));
    expect(onTimeIdx).toBeGreaterThanOrEqual(0);
    await pickChoiceAndAdvance(page, onTimeIdx);

    // After Day 1 recap pagebreak + Day 2 morning, should land at Day 2 [开始今日]
    // (in-ink sticky, NOT Preact card per Bug #23 fix)
    labels = await listChoiceLabels(page);
    console.log('[r15] after Day 1 wrap:', labels);
    expect(labels[0]).toContain('开始今日');
    // No Preact morning_briefing card should appear
    const startTodayPreact = await page.getByRole('button', { name: '开始今日' }).count();
    expect(startTodayPreact).toBe(0); // [开始今日] is sticky, not Preact button

    expect(pageErrors.length).toBe(0);
  });

  test('Re-verify Bug #11 + #14 + #18-regression + #19 + #21 still pass (no regressions)', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
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

    // Bug #6 ellipsis
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
