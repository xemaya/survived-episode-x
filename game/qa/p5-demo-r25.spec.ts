// Round 25 driver — verify Bug #37 (strip "Lisa：" prefix when header shows it)
// + Bug #38 (pause hamburger button + 回主菜单).
// Latest commits:
//   - 7d3f29c fix(qa-bug-37): strip "Lisa：" prefix from NPC body when header shows it
//   - ed16579 fix(qa-bug-38): pause hamburger button + 回主菜单 hard-restart

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

async function advanceToChoices(page: Page, maxTaps = 50): Promise<number> {
  let taps = 0;
  while (taps < maxTaps) {
    const labels = await listChoiceLabels(page);
    if (labels.length > 0) return taps;
    await clickPanelToContinue(page);
    await page.waitForTimeout(400);
    taps++;
  }
  // Diagnostic: dump stage state if we hit max taps
  const finalLabels = await listAllStageLabels(page);
  console.log(`[advanceToChoices] hit max taps (${maxTaps}), stage labels:`, finalLabels);
  const panel = await readPanelText(page);
  console.log(`[advanceToChoices] panel text: ${panel.slice(0, 100)}`);
  return taps;
}

async function pickChoiceAndAdvance(page: Page, idx: number) {
  const ok = await clickChoiceByIndex(page, idx);
  if (!ok) throw new Error(`no choice/sticky-${idx} on stage`);
  await page.waitForTimeout(400);
  await advanceToChoices(page);
}

test.describe('P5 demo · Round 25 (verify Bug #37 + Bug #38)', () => {
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

  test('Bug #38 verify: pause hamburger button mounted at top-right (614, 8)', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);

    const labels = await listAllStageLabels(page);
    console.log('[r25-bug38] all stage labels:', labels);
    // Hamburger button should have a label like 'pause-hamburger' or similar
    const hamburgerLabels = labels.filter((l) =>
      l.toLowerCase().includes('hamburger') || l.toLowerCase().includes('pause-button') || l === 'pause',
    );
    console.log('[r25-bug38] hamburger-related labels:', hamburgerLabels);
    expect(hamburgerLabels.length).toBeGreaterThan(0);

    await page.screenshot({ path: 'qa/output/r25-01-pause-hamburger.png' });

    // Find pause-button's actual world position and click it
    const buttonPos = await page.evaluate(() => {
      // biome-ignore lint/suspicious/noExplicitAny: walk
      const app = window.__qa?.app as any;
      if (!app?.stage) return null;
      let result: { x: number; y: number } | null = null;
      // biome-ignore lint/suspicious/noExplicitAny: walk
      const walk = (n: any) => {
        if (n.label === 'pause-button') {
          const gp = n.getGlobalPosition?.();
          if (gp) result = { x: gp.x, y: gp.y };
        }
        for (const c of n.children ?? []) walk(c);
      };
      walk(app.stage);
      return result;
    });
    console.log('[r25-bug38] pause-button world pos:', buttonPos);
    expect(buttonPos).not.toBeNull();
    if (buttonPos) {
      // World pos is logical 640×360 frame; convert to page coords
      const g = await getCanvasGeom(page);
      // Click center of the 16×16 button (worldPos is top-left)
      await page.mouse.click(
        g.x + (buttonPos.x + 8) * g.scaleX,
        g.y + (buttonPos.y + 8) * g.scaleY,
      );
      await page.waitForTimeout(500);
    }

    const flowAfter = await page.evaluate(() => window.__qa?.flow.state.kind);
    console.log('[r25-bug38] flow after hamburger click:', flowAfter);
    expect(flowAfter).toBe('pause');

    // Pause menu should have 回主菜单 button
    const backToMenuCount = await page.getByRole('button', { name: /主菜单|回主/ }).count();
    console.log('[r25-bug38] [回主菜单] button count:', backToMenuCount);
    expect(backToMenuCount).toBeGreaterThanOrEqual(1);

    expect(pageErrors.length).toBe(0);
  });

  test('Bug #37 verify: NPC body has no "Lisa：" prefix when header shows speaker', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    // Drive to Day 1 Event 1.2 (caishuijian) — first place Lisa speaks: "诶, 你先用吧。"
    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了
    await pickChoiceAndAdvance(page, 0); // 开始今日 → Event 1.2

    // Pick [让 Lisa 先] — Lisa says "谢谢哈."
    await pickChoiceAndAdvance(page, 0);

    // After click, ink advances. Read panel for Lisa's line.
    // Bug #37 fix: panel body should be just "谢谢哈." (or "谢谢哈"), NOT
    // "Lisa：谢谢哈." (which would be the legacy un-stripped form).
    const panelAfterLisa = await readPanelText(page);
    console.log('[r25-bug37] panel after [让 Lisa 先]:', panelAfterLisa.slice(0, 100));

    // Header may show "[ Lisa ]" — that's per Q-R design. But body should NOT
    // duplicate "Lisa："
    // Strip the header bracketed name first to inspect body
    const bodyOnly = panelAfterLisa.replace(/\[\s*[^\]]+\s*\]/g, '').trim();
    console.log('[r25-bug37] body only (after stripping header):', bodyOnly.slice(0, 80));
    // Body should NOT contain "Lisa：" prefix
    expect(bodyOnly.includes('Lisa：')).toBe(false);

    expect(pageErrors.length).toBe(0);
    await page.screenshot({ path: 'qa/output/r25-02-event-1-3-no-prefix.png' });
  });

  test('Re-verify Q-R + Bug #25 + #26 + #33 (no regressions)', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    const allLabels = await listAllStageLabels(page);
    // Q-R 3-layer: no internal-monologue / header-band / speech-bubble containers
    expect(allLabels.includes('internal-monologue')).toBe(false);
    expect(allLabels.includes('header-band')).toBe(false);
    expect(allLabels.includes('speech-bubble')).toBe(false);
    // Bug #26 calendar still mounted
    expect(allLabels.some((l) => l.includes('calendar-widget'))).toBe(true);

    // Bug #25: panel + sticky coexist
    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0); // 开始今日

    const labels = await listChoiceLabels(page);
    const panel = await readPanelText(page);
    expect(labels.length).toBe(3);
    expect(panel.length).toBeGreaterThan(20);

    // Bug #33: no "[视角]" header
    expect(panel.includes('[视角]')).toBe(false);
    expect(panel.includes('视角')).toBe(false);

    expect(pageErrors.length).toBe(0);
  });
});
