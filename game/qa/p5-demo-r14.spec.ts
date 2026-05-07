// Round 14 driver — verify Bug #21 + #22 fix (episode-end render + new-game
// exit). Latest commit: 70310ea fix(qa-bug-21,22)
//
// Approach: divertTo a near-end stitch via __qa.ink (read directly), drive the
// few remaining clicks to reach END, then check:
//   - panel shows recap text (not in monologue overlay)
//   - [新游戏] sticky-0 mounted at desk surface (not "（剧本结束）" mid-canvas)
//   - clicking [新游戏] reloads the page

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

async function advanceToChoices(page: Page, maxTaps = 15): Promise<number> {
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

test.describe('P5 demo · Round 14 (verify Bug #21 + #22 fix at episode end)', () => {
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

  test('Bug #21 + #22 verify: divert to Day 7 cliffhanger, drive to END, check [新游戏] sticky', async ({
    page,
  }) => {
    // Start a new game so save exists + UI is wired up correctly
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    // Skip ahead via ink.divertTo to the Day 7 cliffhanger stitch
    await page.evaluate(() => {
      // biome-ignore lint/suspicious/noExplicitAny: bridging
      const ink = window.__qa?.ink as any;
      if (ink?.divertTo) {
        ink.divertTo('episode_1.day_7_e1_finale_cliffhanger');
      }
    });
    await page.waitForTimeout(800);

    // Force a refresh of dialog by tapping panel
    await advanceToChoices(page);

    // Should now be at Day 7 cliffhanger 3 choices: 应该会, 他每周三都问 / 不一定 / 不知道
    const cliffChoices = await listChoiceLabels(page);
    console.log('[r14] cliffhanger choices:', cliffChoices);
    expect(cliffChoices.length).toBeGreaterThanOrEqual(1);

    // Pick choice 0
    await pickChoiceAndAdvance(page, 0);

    // Now at day_7_daily_recap → END. Episode-end state should show:
    //   - panel with recap text (today KPI / 钱 / 状态 / 关键时刻)
    //   - [新游戏] sticky button
    const endLabels = await listChoiceLabels(page);
    console.log('[r14] end labels:', endLabels);
    await page.screenshot({ path: 'qa/output/r14-01-episode-end.png' });

    // Bug #21 fix: should have [新游戏] sticky, NOT "（剧本结束）"
    expect(endLabels.some((l) => l.includes('新游戏'))).toBe(true);
    expect(endLabels.some((l) => l.includes('剧本结束'))).toBe(false);

    // Bug #22 fix: panel renders something (recap if available, else engine
    // fallback "剧本结束。"). Either is valid post-fix state — old bug was
    // "（剧本结束）" pseudo-button at canvas center with no panel BG.
    const panelAtEnd = await readPanelText(page);
    console.log('[r14] panel text at episode end:', panelAtEnd.slice(0, 120));
    expect(panelAtEnd.trim().length).toBeGreaterThan(0);
    expect(panelAtEnd.trim()).not.toBe('...');
    // Old bug had "（剧本结束）" with brackets as a fake choice button. New
    // state has "剧本结束。" (period, no brackets) inside the panel.
    expect(panelAtEnd.includes('（剧本结束）')).toBe(false);

    expect(pageErrors.length).toBe(0);
  });

  test('Bug #21 [新游戏] click triggers reload + clears save', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);
    // Make some progress so a save exists
    await pickChoiceAndAdvance(page, 0); // 然后呢

    // Verify save exists
    const saveBefore = await page.evaluate(() => {
      try {
        return localStorage.length;
      } catch {
        return 0;
      }
    });
    console.log('[r14-newgame] save count before:', saveBefore);
    expect(saveBefore).toBeGreaterThan(0);

    // Divert to end
    await page.evaluate(() => {
      // biome-ignore lint/suspicious/noExplicitAny: bridging
      const ink = window.__qa?.ink as any;
      if (ink?.divertTo) ink.divertTo('episode_1.day_7_e1_finale_cliffhanger');
    });
    await page.waitForTimeout(800);
    await advanceToChoices(page);
    await pickChoiceAndAdvance(page, 0);
    await page.waitForTimeout(800);

    const endLabels = await listChoiceLabels(page);
    console.log('[r14-newgame] end labels:', endLabels);
    const newGameIdx = endLabels.findIndex((l) => l.includes('新游戏'));
    expect(newGameIdx).toBeGreaterThanOrEqual(0);

    // Clicking [新游戏] should triggerNewGame: clearSave + reset + reload
    await clickChoiceByIndex(page, newGameIdx);
    await page.waitForTimeout(2000);

    // After reload, page should be at fresh boot (main_menu)
    const flowAfter = await page.evaluate(() => window.__qa?.flow.state.kind);
    console.log('[r14-newgame] flow after [新游戏]:', flowAfter);
    expect(flowAfter).toBe('main_menu');

    // Save cleared
    const saveAfter = await page.evaluate(() => {
      try {
        return localStorage.length;
      } catch {
        return 0;
      }
    });
    console.log('[r14-newgame] save count after [新游戏]:', saveAfter);
    expect(saveAfter).toBe(0);
  });
});
