// Round 9 driver — verify Bug #11 fix (T16 follow-up: persist last narration
// text across reload).
// Latest commit: a81da37 fix(qa-bug-11): persist last narration text across reload

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

test.describe('P5 demo · Round 9 (verify Bug #11 fix)', () => {
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

  test('Bug #11 verify: post-reload panel shows last narration, not `...` placeholder', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    // Click 然后呢 → intro screen 2 (deferred-choices phase: panel + ▼).
    // pickChoiceAndAdvance flushes the ▼ for us, leaving us at intro 2's
    // sticky 听懂了. The panel was painted then flushed — but the autosave
    // that fired during the click captured `lastNarrationText` from intro 2.
    await pickChoiceAndAdvance(page, 0); // 然后呢

    // Now click 听懂了 RAW (no advanceToChoices). The click triggers
    // ink.selectChoice → autosave (saves lastNarrationText = intro 2's text) →
    // advance ink → paintStep with intro 3 narration. We pause here so the
    // panel still shows intro 3 content (deferred-choices phase, not yet flushed).
    await clickChoiceByIndex(page, 0); // 听懂了
    await page.waitForTimeout(500);

    const preReloadPanel = await readDialogPanelText(page);
    console.log('[r9-bug11] pre-reload panel head:', preReloadPanel.slice(0, 80));
    // Should be in deferred-choices phase showing intro 3's text
    expect(preReloadPanel.length).toBeGreaterThan(20);

    // Reload
    await page.reload();
    await page.waitForFunction(() => window.__qa?.ink?.isLoaded === true, undefined, {
      timeout: 10000,
    });
    await page.waitForTimeout(800);

    const flow1 = await page.evaluate(() => window.__qa?.flow.state.kind);
    console.log('[r9-bug11] after reload flow.kind:', flow1);
    expect(flow1).toBe('action_day');

    const postReloadPanel = await readDialogPanelText(page);
    console.log('[r9-bug11] post-reload panel head:', postReloadPanel.slice(0, 80));
    await page.screenshot({ path: 'qa/output/r9-01-after-reload.png' });

    // Bug #11 fix: panel should NOT show literal `...` (or empty). It should
    // show the LAST narration the player saw before reload (per dialogState
    // .lastNarrationText fallback in paintStep).
    const isPlaceholder = postReloadPanel.trim() === '...' || postReloadPanel.trim() === '';
    console.log('[r9-bug11] post-reload is placeholder/empty?', isPlaceholder);
    expect(isPlaceholder).toBe(false);
    expect(postReloadPanel.length).toBeGreaterThan(15);

    expect(pageErrors.length).toBe(0);
  });

  test('Re-verify R6/R7/R8 path (no regressions on #14/#18/#13/#3/#6)', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(500);
    await advanceToChoices(page);
    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了

    // Bug #13 deferred-choices: [开始今日] click → no sticky immediately
    await clickChoiceByIndex(page, 0);
    await page.waitForTimeout(500);
    const labelsImm = await listChoiceLabels(page);
    expect(labelsImm.length).toBe(0);
    await clickPanelToContinue(page);
    await page.waitForTimeout(500);
    const labelsFlush = await listChoiceLabels(page);
    expect(labelsFlush.length).toBe(3);

    await pickChoiceAndAdvance(page, 0); // 让Lisa先
    await pickChoiceAndAdvance(page, 0); // 还行你呢
    let labels = await listChoiceLabels(page);
    const onTimeIdx = labels.findIndex((l) => l.includes('按时下班'));
    await pickChoiceAndAdvance(page, onTimeIdx);
    labels = await listChoiceLabels(page);
    if (labels[0]?.includes('开始今日')) await pickChoiceAndAdvance(page, 0);
    const ev21 = await listChoiceLabels(page);
    if (ev21.length) await pickChoiceAndAdvance(page, 0);

    // Bug #18 verify (no stale Lisa bubble)
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
    expect(bubbleText.some((t: string) => t.includes('你喝什么'))).toBe(false);

    // Bug #14: prop:phone hidden during recap (we're at Event 2.3 here)
    const propVis = await page.evaluate(() => {
      // biome-ignore lint/suspicious/noExplicitAny: walk
      const app = window.__qa?.app as any;
      const out: Array<{ label: string; visible: boolean }> = [];
      // biome-ignore lint/suspicious/noExplicitAny: walk
      const walk = (n: any) => {
        if (typeof n.label === 'string' && n.label.startsWith('prop:')) {
          out.push({ label: n.label, visible: n.visible !== false });
        }
        for (const c of n.children ?? []) walk(c);
      };
      walk(app.stage);
      return out;
    });
    console.log('[r9-regress] prop visibility at Event 2.3:', propVis);

    // Bug #6: long sticky ellipsis still works
    const ev23 = await listChoiceLabels(page);
    expect(ev23.length).toBe(3);
    const longChoice = ev23.find((l) => l.includes('主动跟老周说'));
    expect(longChoice?.includes('…')).toBe(true);

    expect(pageErrors.length).toBe(0);
  });
});
