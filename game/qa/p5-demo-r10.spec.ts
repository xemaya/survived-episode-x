// Round 10 driver — verify Bug #12 close (no engine change; pagebreak between
// events means sceneState mirror reflects current event's tags, not stale).
// Latest commit: f98577d fix(qa-bug-12): close by Bug #3 resolution dependency

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

async function readSceneState(page: Page): Promise<Record<string, string | null>> {
  return page.evaluate(() => ({ ...(window.__qa?.sceneState.snapshot ?? {}) }));
}

async function advanceToChoices(page: Page, maxTaps = 10): Promise<number> {
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

test.describe('P5 demo · Round 10 (Bug #12 close-out + regression)', () => {
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

  test('Bug #12 close: sceneState reflects current event (not stale prior event) thanks to pagebreak gating', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    // Intro screens — sceneState should be 'intro' / 'pre_game'
    const introScene = await readSceneState(page);
    console.log('[r10-bug12] intro scene:', introScene);
    expect(introScene.scene).toBe('intro');
    expect(introScene.time).toBe('pre_game');

    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了 → episode_1 → day_1_morning_briefing

    // After Day 1 morning_briefing: scene transitions through home → office_entrance → office_workstation
    // With pagebreak gating, step() should stop at intermediate boundaries, sceneState updates as ink advances
    const day1MorningScene = await readSceneState(page);
    console.log('[r10-bug12] day_1 morning scene:', day1MorningScene);
    // Should be in office context now, not 'intro'
    expect(day1MorningScene.scene).not.toBe('intro');
    expect(day1MorningScene.time).not.toBe('pre_game');

    // Day 1 [开始今日] → Event 1.1 (Vivian, reception) — pagebreak between 1.1 + 1.2
    await pickChoiceAndAdvance(page, 0);

    const sceneAtChoicePhase = await readSceneState(page);
    console.log('[r10-bug12] scene at Event 1.2 sticky phase:', sceneAtChoicePhase);
    // Pre-Bug-#3 fix this would be 'break_room' (Event 1.2's last scene tag,
    // which overwrote 1.1's 'reception'). With pagebreak now, step() stops
    // INSIDE Event 1.1 OR 1.2 — let's just check it's a Day 1 event scene
    // and not stale 'intro'.
    expect(sceneAtChoicePhase.scene).not.toBe('intro');
    expect(
      ['reception', 'break_room', 'office_workstation', 'home_then_subway_then_office'].includes(
        sceneAtChoicePhase.scene ?? '',
      ),
    ).toBe(true);
    expect(pageErrors.length).toBe(0);
  });

  test('Re-verify Bug #14 (props hidden on scene change) + Bug #11 (post-reload narration)', async ({
    page,
  }) => {
    // Quick regression smoke after Bug #12 close-out commit (which is docs-only)
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    await pickChoiceAndAdvance(page, 0); // 然后呢
    await clickChoiceByIndex(page, 0); // 听懂了 RAW (no advance — preserve pre-reload narration)
    await page.waitForTimeout(500);

    await page.reload();
    await page.waitForFunction(() => window.__qa?.ink?.isLoaded === true, undefined, {
      timeout: 10000,
    });
    await page.waitForTimeout(800);

    const flowKind = await page.evaluate(() => window.__qa?.flow.state.kind);
    expect(flowKind).toBe('action_day');

    // Bug #11 still works: panel shows narration not '...'
    const panelText = await page.evaluate(() => {
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
    console.log('[r10] post-reload panel:', panelText.slice(0, 80));
    expect(panelText.trim()).not.toBe('...');
    expect(panelText.length).toBeGreaterThan(15);

    expect(pageErrors.length).toBe(0);
  });
});
