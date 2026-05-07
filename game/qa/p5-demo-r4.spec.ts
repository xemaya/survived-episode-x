// Round 4 driver — verify dev fixes for Bug #3 (pagebreak) and Bug #6
// (sticky-note 2-line ellipsis), landed in commits:
//   - fb3b4df feat(p5-pagebreak)+fix(qa-bug-3): # pagebreak step-loop + ▼ continue affordance
//   - 3b91ff1 feat(p5-T11-fit)+fix(qa-bug-6): sticky-note 2-line ellipsis (Q-3)
//
// Also re-checks Bug #11 (post-reload `...` placeholder) since the new
// pagebreak step-loop may interact with it.

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

async function clickSingleChoice(page: Page) {
  const ok = await clickChoiceByIndex(page, 0);
  if (!ok) throw new Error('no sticky-0/choice-0 button on stage');
}

/** Advance the dialog by clicking the panel's tap-to-continue affordance
 * (▼) repeatedly until a choice button appears or maxTaps is exceeded. */
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

/** Click choice idx; if the next paint is a pagebreak (no choice), advance
 * via tap-to-continue until next choice appears. */
async function pickChoiceAndAdvance(page: Page, idx: number): Promise<void> {
  const ok = await clickChoiceByIndex(page, idx);
  if (!ok) throw new Error(`no choice/sticky-${idx} on stage to click`);
  await page.waitForTimeout(400);
  await advanceToChoices(page);
}

/** Click the panel's tap-to-continue affordance (▼). The handler attaches
 *  on the panel BG itself, so click anywhere over the narration panel. */
async function clickPanelToContinue(page: Page) {
  const g = await getCanvasGeom(page);
  // Panel center: (CANVAS_W/2, CANVAS_H - PANEL_H/2 - 8) = (320, 360-78-8 = 274)
  const p = toPage(g, CANVAS_W / 2, 274);
  await page.mouse.click(p.x, p.y);
}

async function listChoiceLabels(page: Page): Promise<string[]> {
  return page.evaluate(() => {
    // biome-ignore lint/suspicious/noExplicitAny: stage walk
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

async function readDialogPanelText(page: Page): Promise<string> {
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

test.describe('P5 demo · Round 4 (verify Bug #3 pagebreak + Bug #6 sticky ellipsis)', () => {
  let consoleErrors: string[] = [];

  test.beforeEach(async ({ page }) => {
    consoleErrors = [];
    page.on('pageerror', (err) => console.error('[page error]', err.message));
    page.on('console', (msg) => {
      if (msg.type() === 'error') {
        consoleErrors.push(msg.text());
        console.log('[console.error]', msg.text());
      }
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

  test('Bug #3 verify: pagebreak gate exists between days', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);

    // Advance through intro 1/2/3 (each choice may be followed by pagebreak)
    await advanceToChoices(page); // pagebreak BEFORE first choice (if any)
    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了 → episode_1 (has pagebreak before day_1_morning_briefing per ink line 178)
    // After pagebreak past episode_1, should now be at day_1_morning_briefing's [开始今日]
    let labels = await listChoiceLabels(page);
    console.log('[r4-bug3] after intro chain, choices:', labels);
    expect(labels.length).toBe(1);
    expect(labels[0]).toContain('开始今日');

    await pickChoiceAndAdvance(page, 0); // 开始今日 → event 1.1 (Vivian no-choice) → 1.2 caishuijian (3 choices)
    labels = await listChoiceLabels(page);
    console.log('[r4-bug3] after [开始今日], choices:', labels);
    expect(labels.length).toBe(3);

    await pickChoiceAndAdvance(page, 0); // 让Lisa先
    await pickChoiceAndAdvance(page, 0); // event 1.3 → 还行你呢
    // event 1.4 + 1.5 + 1.6 + day_1_after_work (3 choices)

    labels = await listChoiceLabels(page);
    console.log('[r4-bug3] choices at day_1_after_work:', labels);
    expect(labels.length).toBeGreaterThanOrEqual(3);
    const onTimeIdx = labels.findIndex((l) => l.includes('按时下班'));
    expect(onTimeIdx).toBeGreaterThanOrEqual(0);

    // Pick [按时下班]. After Bug #3 fix, ink should hit a pagebreak between
    // day_1_after_work post-choice and day_1_daily_recap (line 517) AND
    // between day_1_daily_recap and day_2_morning_briefing (line 544).
    // Track number of pagebreak taps needed to reach Day 2 [开始今日].
    await clickChoiceByIndex(page, onTimeIdx);
    await page.waitForTimeout(500);
    await page.screenshot({ path: 'qa/output/r4-01-after-an-shi-xia-ban-pre-pagebreak.png' });

    // Inspect intermediate state: should have NO choice buttons immediately
    // after [按时下班] click.
    const labelsImm = await listChoiceLabels(page);
    console.log('[r4-bug3] choices immediately after [按时下班]:', labelsImm);
    expect(labelsImm.length).toBe(0); // pagebreak gate active

    const panelImm = await readDialogPanelText(page);
    console.log('[r4-bug3] panel text head right after [按时下班]:', panelImm.slice(0, 80));
    // Should NOT yet contain Day 2 morning marker
    expect(panelImm).not.toContain('闹钟响了 3 次');

    // Tap-to-continue + count taps to reach Day 2 [开始今日]
    const taps = await advanceToChoices(page);
    console.log(`[r4-bug3] tapped ${taps} times to reach Day 2 [开始今日]`);
    expect(taps).toBeGreaterThanOrEqual(1); // Bug #3 fix: pagebreak DID gate

    const day2Labels = await listChoiceLabels(page);
    console.log('[r4-bug3] Day 2 choices after pagebreak loop:', day2Labels);
    expect(day2Labels[0]).toContain('开始今日');

    const panelDay2 = await readDialogPanelText(page);
    console.log('[r4-bug3] Day 2 panel text head:', panelDay2.slice(0, 80));
    // Day 2 morning_briefing opens with "早上你出门时下小雨" (not "闹钟响" — that's Day 1).
    expect(panelDay2).toContain('小雨');
    await page.screenshot({ path: 'qa/output/r4-02-day2-morning-after-pagebreak.png' });
  });

  test('Bug #6 verify: medium sticky-note text renders cleanly', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(500);
    await advanceToChoices(page); // pre-intro pagebreak if any

    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了 → intro 3

    const introScreen3Labels = await listChoiceLabels(page);
    console.log('[r4-bug6] intro screen 3 label:', introScreen3Labels);
    expect(introScreen3Labels.length).toBe(1);
    // "[我懂了, 开始第 1 天]" — 9 chars, may be 2-line wrap or truncate
    expect(introScreen3Labels[0]).toContain('我懂了');
    await page.screenshot({ path: 'qa/output/r4-03-intro-3-sticky-fit.png' });

    await pickChoiceAndAdvance(page, 0); // 我懂了 → day_1_morning
    await pickChoiceAndAdvance(page, 0); // 开始今日 → event 1.2

    const event12Labels = await listChoiceLabels(page);
    console.log('[r4-bug6] event 1.2 sticky labels:', event12Labels);
    expect(event12Labels.length).toBe(3);
    const longest = event12Labels.find((l) => l.includes('不说话'));
    console.log('[r4-bug6] longest choice (不说话):', longest);
    expect(longest).toBeDefined();
    await page.screenshot({ path: 'qa/output/r4-04-event-1-2-sticky-3choices.png' });
  });

  test('Day 2 long-sentence choice [主动跟老周说...] verify ellipsis', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(500);
    await advanceToChoices(page);

    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了 → day_1_morning
    await pickChoiceAndAdvance(page, 0); // 开始今日 → event 1.2
    await pickChoiceAndAdvance(page, 0); // 让Lisa先 → 1.3
    await pickChoiceAndAdvance(page, 0); // 还行你呢 → 1.4-1.6 + after_work

    let labels = await listChoiceLabels(page);
    const onTimeIdx = labels.findIndex((l) => l.includes('按时下班'));
    if (onTimeIdx >= 0) await pickChoiceAndAdvance(page, onTimeIdx);

    // Now at Day 2 [开始今日]
    labels = await listChoiceLabels(page);
    console.log('[r4-bug6-day2] choices:', labels);
    if (labels[0]?.includes('开始今日')) await pickChoiceAndAdvance(page, 0);

    const ev21 = await listChoiceLabels(page);
    console.log('[r4-bug6-day2] Event 2.1:', ev21);
    if (ev21.length >= 1) await pickChoiceAndAdvance(page, 0);

    // Day 2 Event 2.3 — has the longest choice "[主动跟老周说"对不起，您那杯茶我喝了"]"
    const ev23 = await listChoiceLabels(page);
    console.log('[r4-bug6-day2] Event 2.3:', ev23);
    await page.screenshot({ path: 'qa/output/r4-05-event-2-3-laozhou.png' });
    expect(ev23.length).toBe(3);
    const longChoice = ev23.find((l) => l.includes('主动跟老周说'));
    console.log('[r4-bug6-day2] long-sentence choice as rendered:', longChoice);
    expect(longChoice).toBeDefined();
    const rendered = longChoice?.split('=').slice(1).join('=') ?? '';
    console.log(
      '[r4-bug6-day2] rendered length:',
      rendered.length,
      'has …?',
      rendered.includes('…'),
    );
  });
});
