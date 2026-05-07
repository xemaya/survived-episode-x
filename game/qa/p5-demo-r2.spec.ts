// Round 2 driver — drives via REAL canvas pointer clicks (not __qa.ink bypass),
// so screenshots reflect what a player would actually see.
//
// Coverage delta over Round 1:
//   - Validates no "click → empty panel" race (the handoff §5 example bug)
//   - Validates markdown strip on actual rendered text
//   - Tries save/reload cycle to confirm Bug #5 (ink resets to intro)
//   - Picks alternate Day 1 paths to discover new bugs
//   - Verifies that no listener exists for # scene / # npc / # prop tags
//     (Bug #8 — should observe BG never changes from workstation_closeup)
//
// Run: `npx playwright test qa/p5-demo-r2.spec.ts`

import { type Page, expect, test } from '@playwright/test';

declare global {
  interface Window {
    __qa?: {
      ink: {
        isLoaded: boolean;
        sourcePath: string | null;
        getVar: (n: string) => unknown;
        listVars: () => string[];
      };
      flow: { state: { kind: string; [k: string]: unknown } };
      save: unknown;
      app: unknown;
    };
  }
}

const CANVAS_W = 640;
const CANVAS_H = 360;
const PANEL_H = 130;
const PANEL_Y = CANVAS_H - PANEL_H - 8; // 222

interface CanvasGeom {
  x: number;
  y: number;
  width: number;
  height: number;
  scaleX: number;
  scaleY: number;
}

async function getCanvasGeom(page: Page): Promise<CanvasGeom> {
  const handle = page.locator('canvas');
  const box = await handle.boundingBox();
  if (!box) throw new Error('canvas not found');
  return {
    x: box.x,
    y: box.y,
    width: box.width,
    height: box.height,
    scaleX: box.width / CANVAS_W,
    scaleY: box.height / CANVAS_H,
  };
}

/** Map a logical (640x360) coord → page coord. */
function toPage(g: CanvasGeom, lx: number, ly: number): { x: number; y: number } {
  return { x: g.x + lx * g.scaleX, y: g.y + ly * g.scaleY };
}

/** Click the single-choice button (when only 1 ink choice). */
async function clickSingleChoice(page: Page): Promise<void> {
  const g = await getCanvasGeom(page);
  const p = toPage(g, CANVAS_W / 2, PANEL_Y - 16); // 320, 206
  await page.mouse.click(p.x, p.y);
}

/** Click the i-th choice in a multi-choice stack. */
async function clickChoiceI(page: Page, i: number, total: number): Promise<void> {
  const g = await getCanvasGeom(page);
  const gap = 26;
  const totalH = total * gap;
  const startY = PANEL_Y - 14 - totalH + gap / 2;
  const ly = startY + i * gap;
  const p = toPage(g, CANVAS_W / 2, ly);
  await page.mouse.click(p.x, p.y);
}

async function flowKind(page: Page): Promise<string> {
  return page.evaluate(() => window.__qa?.flow.state.kind ?? '');
}

async function readVars(page: Page, names: string[]): Promise<Record<string, unknown>> {
  return page.evaluate((ns) => {
    const qa = window.__qa;
    if (!qa) throw new Error('window.__qa not present');
    const out: Record<string, unknown> = {};
    for (const n of ns) out[n] = qa.ink.getVar(n);
    return out;
  }, names);
}

/** Read concatenated text content of all PixiJS Text nodes inside the
 * ink-dialog container. Walks the stage tree via __qa.app. */
async function readDialogText(page: Page): Promise<string> {
  return page.evaluate(() => {
    // biome-ignore lint/suspicious/noExplicitAny: bridging into private PixiJS Application
    const app = window.__qa?.app as any;
    if (!app?.stage) return '<no stage>';
    const out: string[] = [];
    // biome-ignore lint/suspicious/noExplicitAny: Container API
    const walk = (node: any): void => {
      if (
        node.label === 'choice-0' ||
        (typeof node.label === 'string' && node.label.startsWith('choice-'))
      ) {
        return; // skip choice button labels
      }
      if (typeof node.text === 'string' && node.text.length > 0) out.push(node.text);
      const children = node.children ?? [];
      for (const c of children) walk(c);
    };
    // biome-ignore lint/suspicious/noExplicitAny: Container API
    const dialog = app.stage.children
      ?.find?.((c: any) => c.label === 'world')
      ?.children?.find?.(
        // biome-ignore lint/suspicious/noExplicitAny: Container API
        (c: any) => c.label === 'ink-dialog',
      );
    if (dialog) walk(dialog);
    return out.join(' | ');
  });
}

async function readChoiceLabels(page: Page): Promise<string[]> {
  return page.evaluate(() => {
    // biome-ignore lint/suspicious/noExplicitAny: bridging into private PixiJS
    const app = window.__qa?.app as any;
    if (!app?.stage) return [];
    const out: string[] = [];
    // biome-ignore lint/suspicious/noExplicitAny: Container API
    const dialog = app.stage.children
      ?.find?.((c: any) => c.label === 'world')
      ?.children?.find?.(
        // biome-ignore lint/suspicious/noExplicitAny: Container API
        (c: any) => c.label === 'ink-dialog',
      );
    if (!dialog) return out;
    // biome-ignore lint/suspicious/noExplicitAny: Container API
    const choicesLayer = dialog.children?.find?.((c: any) => c.label === 'choices');
    if (!choicesLayer) return out;
    for (const btn of choicesLayer.children ?? []) {
      // each btn has a Text child
      // biome-ignore lint/suspicious/noExplicitAny: Container API
      const lbl = btn.children?.find?.((c: any) => typeof c.text === 'string');
      if (lbl) out.push(lbl.text);
    }
    return out;
  });
}

test.describe('P5 demo · Round 2 (real canvas clicks)', () => {
  let consoleErrors: string[] = [];
  let pageErrors: string[] = [];

  test.beforeEach(async ({ page }) => {
    consoleErrors = [];
    pageErrors = [];
    page.on('pageerror', (err) => {
      pageErrors.push(err.message);
      console.error('[page error]', err.message);
    });
    page.on('console', (msg) => {
      if (msg.type() === 'error') {
        consoleErrors.push(msg.text());
        console.log('[console.error]', msg.text());
      }
    });
    await page.addInitScript(() => {
      try {
        localStorage.clear();
      } catch {
        // ignore
      }
    });
    await page.goto('/');
    await page.waitForFunction(() => window.__qa?.ink?.isLoaded === true, undefined, {
      timeout: 10000,
    });
  });

  test('intro screen 1 → click [然后呢] → screen 2 renders (no empty-panel race)', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    // Give workstation scene + ink-dialog mount time
    await page.waitForTimeout(800);
    await page.screenshot({ path: 'qa/output/r2-01-intro-screen-1.png', fullPage: false });

    const t1 = await readDialogText(page);
    const c1 = await readChoiceLabels(page);
    console.log('[r2] intro 1 panel text head:', t1.slice(0, 80), '... choices:', c1);
    expect(c1).toEqual(['然后呢']);
    expect(t1).toContain('陈笑天');
    expect(t1).toContain('32 岁');
    // Verify markdown strip — `**陈笑天**` source should not appear with literal **
    expect(t1).not.toContain('**');
    expect(t1).not.toMatch(/_[^\s]/); // _italic_ stripped

    await clickSingleChoice(page);
    await page.waitForTimeout(300);
    await page.screenshot({ path: 'qa/output/r2-02-intro-screen-2.png' });
    const t2 = await readDialogText(page);
    const c2 = await readChoiceLabels(page);
    console.log('[r2] intro 2 panel text head:', t2.slice(0, 80), '... choices:', c2);
    // Bug from handoff §5 example: panel empty after click. Must not be empty.
    expect(t2.length).toBeGreaterThan(20);
    expect(c2).toEqual(['听懂了']);
    expect(t2).toContain('8 个时间槽');
    expect(t2).toContain('不可能三角');

    await clickSingleChoice(page);
    await page.waitForTimeout(300);
    await page.screenshot({ path: 'qa/output/r2-03-intro-screen-3.png' });
    const t3 = await readDialogText(page);
    const c3 = await readChoiceLabels(page);
    console.log('[r2] intro 3 panel text head:', t3.slice(0, 80), '... choices:', c3);
    expect(t3).toContain('52 周');
    expect(t3).toContain('我妈不知道');
    expect(c3).toEqual(['我懂了, 开始第 1 天']);

    await clickSingleChoice(page);
    await page.waitForTimeout(500);
    await page.screenshot({ path: 'qa/output/r2-04-day1-morning.png' });
    const t4 = await readDialogText(page);
    const c4 = await readChoiceLabels(page);
    console.log('[r2] day1 morning panel text head:', t4.slice(0, 100), '... choices:', c4);
    expect(t4).toContain('闹钟响了 3 次');
    expect(t4).toContain('陈笑天');
    expect(t4).toContain('9:14');
    expect(c4).toEqual(['开始今日']);

    expect(consoleErrors.filter((e) => !e.includes('autosave')).length).toBe(0);
    expect(pageErrors.length).toBe(0);
  });

  test('Day 1 alt path: pick [你先] (Lisa milk tea) — verify lisa_score=0 not -2', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);

    // intro 1 → 2 → 3 → day_1_morning_briefing → event 1.1 + 1.2
    await clickSingleChoice(page); // 然后呢
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // 听懂了
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // 我懂了
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // 开始今日 (event 1.1 vivian → event 1.2 caishuijian)
    await page.waitForTimeout(500);

    const choices = await readChoiceLabels(page);
    console.log('[r2] event 1.2 choices:', choices);
    expect(choices.length).toBe(3);
    expect(choices[1]).toContain('你先');

    // Pick [你先] (idx 1)
    await clickChoiceI(page, 1, 3);
    await page.waitForTimeout(500);
    await page.screenshot({ path: 'qa/output/r2-05-event-1-2-pick-你先.png' });

    const vars = await readVars(page, ['lisa_score']);
    console.log('[r2] after [你先] → lisa_score:', vars.lisa_score);
    // [你先] gives lisa_score + 0 (per ink line 312)
    expect(vars.lisa_score).toBe(0);

    expect(pageErrors.length).toBe(0);
  });

  test('Day 1 alt path: pick [不说话，先接你的] — verify lisa_score = -2', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);

    await clickSingleChoice(page); // 然后呢
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // 听懂了
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // 我懂了
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // 开始今日
    await page.waitForTimeout(500);

    const choices = await readChoiceLabels(page);
    expect(choices[2]).toContain('不说话');

    await clickChoiceI(page, 2, 3);
    await page.waitForTimeout(500);
    await page.screenshot({ path: 'qa/output/r2-06-event-1-2-pick-bushuoauhua.png' });

    const vars = await readVars(page, ['lisa_score']);
    console.log('[r2] after [不说话] → lisa_score:', vars.lisa_score);
    expect(vars.lisa_score).toBe(-2);
  });

  test('Bug #5 verify: [继续] after refresh diverts ink back to intro', async ({ page }) => {
    // Step 1: start a new game and progress past intro into Day 1 events
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(500);
    await clickSingleChoice(page); // 然后呢
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // 听懂了
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // 我懂了 → into day_1_morning
    await page.waitForTimeout(500);
    // We're now at day_1_morning_briefing with [开始今日] choice — past the intro

    // Trigger a save (autosave runs after each FSM transition?) — read save state
    const haveSaveBefore = await page.evaluate(() => {
      try {
        return localStorage.length > 0;
      } catch {
        return false;
      }
    });
    console.log('[r2] localStorage non-empty after intro:', haveSaveBefore);

    // Step 2: hard reload
    await page.reload();
    await page.waitForFunction(() => window.__qa?.ink?.isLoaded === true, undefined, {
      timeout: 10000,
    });
    await page.waitForTimeout(500);

    // Step 3: should be at main_menu with [继续] enabled
    const flow1 = await flowKind(page);
    console.log('[r2] after reload flow.kind:', flow1);

    const continueBtn = page.getByRole('button', { name: '继续' });
    const continueDisabled = await continueBtn.isDisabled();
    console.log('[r2] [继续] disabled?', continueDisabled);

    if (!continueDisabled) {
      await continueBtn.click();
      await page.waitForTimeout(800);
      const flow2 = await flowKind(page);
      console.log('[r2] after [继续] click → flow.kind:', flow2);
      const t = await readDialogText(page);
      console.log('[r2] dialog text head after [继续]:', t.slice(0, 100));
      // Bug #5 prediction: dialog text should be intro screen 1 (你好。我陈笑天) not Day 1 content
      // Save the screenshot for evidence either way
      await page.screenshot({ path: 'qa/output/r2-07-after-continue.png' });
      const t_low = t.toLowerCase();
      const looksLikeIntro = t.includes('你好') || t.includes('数咖啡杯');
      const looksLikeDay1 = t.includes('闹钟响') || t.includes('打卡机');
      console.log('[r2] looksLikeIntro:', looksLikeIntro, 'looksLikeDay1:', looksLikeDay1);
      // If looksLikeIntro → Bug #5 confirmed
    } else {
      console.log('[r2] [继续] is disabled even after intro — interesting, save not triggered?');
    }
  });

  test('No NPC立绘 / scene swap visible (Bug #8 verification)', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);

    // Drive into event 1.1 (Vivian) — should fire `# npc: vivian_smiling` tag
    await clickSingleChoice(page); // 然后呢
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // 听懂了
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // 我懂了
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // 开始今日 → vivian
    await page.waitForTimeout(500);

    // Snapshot the stage tree — check for any NPC sprite labels
    const npcSprites = await page.evaluate(() => {
      // biome-ignore lint/suspicious/noExplicitAny: bridging into private PixiJS
      const app = window.__qa?.app as any;
      const labels: string[] = [];
      // biome-ignore lint/suspicious/noExplicitAny: PIXI Container
      const walk = (node: any): void => {
        if (typeof node.label === 'string') labels.push(node.label);
        for (const c of node.children ?? []) walk(c);
      };
      walk(app.stage);
      return labels;
    });
    console.log('[r2] all stage labels at event 1.1:', npcSprites);
    // Verify no NPC sprite was mounted by tags
    expect(npcSprites.some((l) => l.includes('vivian'))).toBe(false);
    expect(npcSprites.some((l) => l.includes('npc'))).toBe(false);
    // Confirm Bug #8: tags fire but no listeners
  });
});
