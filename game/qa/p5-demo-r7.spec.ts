// Round 7 driver — verify Bug #14 fix (PropEntity scope + scene-aware hide/show).
// Latest commit: bcd2fb0 fix(qa-bug-14): PropEntity scope + scene-aware hide/show
//
// Fix approach: "hide-not-destroy". Props mount invisible; setState makes them
// visible; '# scene:' change bulk-hides all scene-scoped props. Next prop tag
// re-shows them.

import { type Page, expect, test } from '@playwright/test';

declare global {
  interface Window {
    __qa?: {
      ink: { isLoaded: boolean };
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

/** Find props by label prefix and return their visibility info. */
async function listPropVisibility(
  page: Page,
): Promise<Array<{ label: string; visible: boolean; alpha: number; renderable: boolean }>> {
  return page.evaluate(() => {
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const app = window.__qa?.app as any;
    if (!app?.stage) return [];
    const out: Array<{ label: string; visible: boolean; alpha: number; renderable: boolean }> = [];
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const walk = (n: any) => {
      if (typeof n.label === 'string' && n.label.startsWith('prop:')) {
        out.push({
          label: n.label,
          visible: n.visible !== false,
          alpha: n.alpha ?? 1,
          renderable: n.renderable !== false,
        });
      }
      for (const c of n.children ?? []) walk(c);
    };
    walk(app.stage);
    return out;
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

test.describe('P5 demo · Round 7 (verify Bug #14 fix)', () => {
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

  test('Bug #14 verify: phone prop hides during scene transitions', async ({ page }) => {
    // Drive to Day 1 daily_recap (where Bug #14 was visible — phone covering recap text)
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);
    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了 → day_1

    // After 我懂了, sceneState scene transitions to 'home' then through morning beats.
    // Inspect props before [开始今日]
    const propsAtMorning = await listPropVisibility(page);
    console.log('[r7-bug14] props at Day 1 [开始今日] choice phase:', propsAtMorning);

    await pickChoiceAndAdvance(page, 0); // 开始今日 → events 1.1+1.2 (3 sticky)
    const propsAtE12 = await listPropVisibility(page);
    console.log('[r7-bug14] props at Event 1.2 sticky phase:', propsAtE12);
    // Note: fix is "hide-not-destroy + scene-bulk-hide on scene change". Event 1.2
    // emits `# scene: break_room` which bulk-hides 1.1's fruit_bowl. So both
    // props may be hidden here — that's intended, not a bug.

    await pickChoiceAndAdvance(page, 0); // 让Lisa先 → 1.3
    await pickChoiceAndAdvance(page, 0); // 还行你呢 → 1.4-1.6 + after_work
    const labels = await listChoiceLabels(page);
    const onTimeIdx = labels.findIndex((l) => l.includes('按时下班'));
    expect(onTimeIdx).toBeGreaterThanOrEqual(0);

    // Pick [按时下班] → enters daily_recap pagebreak (was: phone covers text)
    await clickChoiceByIndex(page, onTimeIdx);
    await page.waitForTimeout(800);

    // Inspect prop visibility DURING daily_recap pagebreak (no choices yet, panel showing recap stats)
    const propsAtRecap = await listPropVisibility(page);
    console.log('[r7-bug14] props at Day 1 daily_recap pagebreak:', propsAtRecap);
    await page.screenshot({ path: 'qa/output/r7-01-day1-recap-prop-state.png' });

    // Bug #14 fix: hide-not-destroy. After scene change to home_phone_screen
    // (daily_recap), prop:phone (which lives in workstation scene) should be
    // visible=false (or alpha=0). Same for fruit_bowl which is workstation-scoped.
    const phone = propsAtRecap.find((p) => p.label === 'prop:phone');
    console.log(
      '[r7-bug14] phone at recap → visible:',
      phone?.visible,
      'alpha:',
      phone?.alpha,
      'renderable:',
      phone?.renderable,
    );
    if (phone) {
      // Must be hidden via visible=false OR alpha=0 OR renderable=false
      const isHidden = !phone.visible || phone.alpha === 0 || !phone.renderable;
      expect(isHidden).toBe(true);
    }

    // Continue past pagebreaks until next choice
    await advanceToChoices(page);
    const day2Choices = await listChoiceLabels(page);
    console.log('[r7-bug14] Day 2 choices:', day2Choices);
    expect(day2Choices[0]).toContain('开始今日');

    // After advancing to Day 2 morning, props from Day 2 morning_briefing tags
    // should fire — fruit_bowl_apple_again (line 564), so fruit_bowl should be
    // visible again.
    const propsAtDay2Morning = await listPropVisibility(page);
    console.log('[r7-bug14] props at Day 2 [开始今日]:', propsAtDay2Morning);
    expect(pageErrors.length).toBe(0);
  });

  test('Re-verify Bug #18 + #13 + #6 (no regressions)', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(500);
    await advanceToChoices(page);
    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了

    // Bug #13: deferred-choices flow
    await clickChoiceByIndex(page, 0); // 开始今日 — should NOT show sticky immediately
    await page.waitForTimeout(500);
    const labelsImm = await listChoiceLabels(page);
    expect(labelsImm.length).toBe(0); // deferred-choices phase
    await clickPanelToContinue(page); // ▼ flush
    await page.waitForTimeout(500);
    const labelsAfterFlush = await listChoiceLabels(page);
    expect(labelsAfterFlush.length).toBe(3);

    await pickChoiceAndAdvance(page, 0); // 让Lisa先
    await pickChoiceAndAdvance(page, 0); // 还行你呢
    let labels = await listChoiceLabels(page);
    const onTimeIdx = labels.findIndex((l) => l.includes('按时下班'));
    await pickChoiceAndAdvance(page, onTimeIdx);
    labels = await listChoiceLabels(page);
    if (labels[0]?.includes('开始今日')) await pickChoiceAndAdvance(page, 0);
    const ev21 = await listChoiceLabels(page);
    if (ev21.length) await pickChoiceAndAdvance(page, 0);

    // Bug #18: no stale Lisa bubble at Event 2.3
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

    // Bug #6: long sticky ellipsis
    const ev23 = await listChoiceLabels(page);
    expect(ev23.length).toBe(3);
    const longChoice = ev23.find((l) => l.includes('主动跟老周说'));
    expect(longChoice?.includes('…')).toBe(true);

    expect(pageErrors.length).toBe(0);
  });
});
