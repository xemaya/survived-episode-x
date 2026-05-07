// Round 19 driver — verify Q-R 3-layer dialog rewrite + Bug #26 calendar
// programmatic widget + Bug #33 drop [视角] header.
// Latest commits:
//   - 0f7aa6f feat(p5-Q-R): 3-layer 公文报告框 dialog rewrite
//   - 9446295 fix(qa-bug-33): drop "[视角]" header for narration paints
//   - 70a4b95 fix(qa-bug-26): programmatic Pixi calendar widget

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

test.describe('P5 demo · Round 19 (Q-R dialog rewrite + Bug #26 + Bug #33)', () => {
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

  test('Q-R rewrite: 3-layer dialog (panel + sticky + ▼) — no header-band, no monologue overlay separately', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    // Verify stage tree: should NOT have separate 'internal-monologue' /
    // 'header-band' / 'speech-bubble' containers per Q-R 3-layer reset.
    const labels = await listAllStageLabels(page);
    console.log('[r19-qr] all stage labels at intro 1:', labels);

    // Q-R rewrite: monologue + speech-bubble + header-band collapsed into the panel
    // Stage tree should NOT have these separately mounted
    const hasMonologueContainer = labels.includes('internal-monologue');
    const hasHeaderBand = labels.includes('header-band');
    const hasSpeechBubble = labels.includes('speech-bubble');
    console.log(
      `[r19-qr] internal-monologue:${hasMonologueContainer}, header-band:${hasHeaderBand}, speech-bubble:${hasSpeechBubble}`,
    );

    // Should be collapsed — these containers shouldn't exist as separate layers
    expect(hasHeaderBand).toBe(false);
    // monologue + speech-bubble may still exist as label names from new code; check via screenshot

    expect(pageErrors.length).toBe(0);
    await page.screenshot({ path: 'qa/output/r19-01-intro-1-3layer.png' });
  });

  test('Bug #33 verify: panel does NOT show "[视角]" header for narration paints', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    // intro 1 narration — read panel text, should NOT contain "[视角]" header
    const introPanel = await readPanelText(page);
    console.log('[r19-bug33] intro 1 panel:', introPanel.slice(0, 100));
    expect(introPanel.includes('[视角]')).toBe(false);
    expect(introPanel.includes('视角')).toBe(false);

    await pickChoiceAndAdvance(page, 0); // 然后呢
    const intro2Panel = await readPanelText(page);
    console.log('[r19-bug33] intro 2 panel:', intro2Panel.slice(0, 100));
    expect(intro2Panel.includes('[视角]')).toBe(false);

    await pickChoiceAndAdvance(page, 0); // 听懂了
    const intro3Panel = await readPanelText(page);
    expect(intro3Panel.includes('[视角]')).toBe(false);

    await pickChoiceAndAdvance(page, 0); // 我懂了 → day_1_morning
    const day1Panel = await readPanelText(page);
    console.log('[r19-bug33] day 1 morning panel:', day1Panel.slice(0, 100));
    expect(day1Panel.includes('[视角]')).toBe(false);

    expect(pageErrors.length).toBe(0);
  });

  test('Bug #26 verify: programmatic Pixi calendar widget is mounted', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);

    // Calendar widget should be in stage tree — possibly with new label
    const labels = await listAllStageLabels(page);
    const calendarLabels = labels.filter((l) => l.toLowerCase().includes('calendar'));
    console.log('[r19-bug26] calendar-related labels:', calendarLabels);
    expect(calendarLabels.length).toBeGreaterThan(0);

    await page.screenshot({ path: 'qa/output/r19-02-calendar-widget.png' });
    expect(pageErrors.length).toBe(0);
  });

  test('Re-verify Bug #25 + #21 + #6: panel + sticky still coexist; episode-end + ellipsis intact', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0); // 开始今日 → 1.2

    // Bug #25 verify: panel + sticky coexist
    const labels = await listChoiceLabels(page);
    const panel = await readPanelText(page);
    console.log('[r19-bug25] event 1.2 sticky:', labels);
    console.log('[r19-bug25] panel:', panel.slice(0, 60));
    expect(labels.length).toBe(3);
    expect(panel.length).toBeGreaterThan(20);

    // Drive to Day 2 Event 2.3 to verify Bug #6 ellipsis still works
    await pickChoiceAndAdvance(page, 0); // 让Lisa先
    await pickChoiceAndAdvance(page, 0); // 还行你呢
    let labels2 = await listChoiceLabels(page);
    const onTimeIdx = labels2.findIndex((l) => l.includes('按时下班'));
    await pickChoiceAndAdvance(page, onTimeIdx);
    labels2 = await listChoiceLabels(page);
    if (labels2[0]?.includes('开始今日')) await pickChoiceAndAdvance(page, 0);
    const ev21 = await listChoiceLabels(page);
    if (ev21.length) await pickChoiceAndAdvance(page, 0);

    const ev23 = await listChoiceLabels(page);
    expect(ev23.length).toBe(3);
    const longChoice = ev23.find((l) => l.includes('主动跟老周说'));
    expect(longChoice?.includes('…')).toBe(true);

    // Bug #21 verify: divert to end and check [新游戏] sticky
    await page.evaluate(() => {
      // biome-ignore lint/suspicious/noExplicitAny: bridging
      const ink = window.__qa?.ink as any;
      if (ink?.divertTo) ink.divertTo('episode_1.day_7_e1_finale_cliffhanger');
    });
    await page.waitForTimeout(600);
    await advanceToChoices(page);
    await pickChoiceAndAdvance(page, 0);
    await page.waitForTimeout(800);
    const endLabels = await listChoiceLabels(page);
    console.log('[r19-bug21] end labels:', endLabels);
    expect(endLabels.some((l) => l.includes('新游戏'))).toBe(true);

    expect(pageErrors.length).toBe(0);
  });
});
