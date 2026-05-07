// Round 11 driver — verify Bug #19 (monologue top-region) + Bug #18-regression
// (bubble dominance) fix.
// Latest commit: fafa078 fix(qa-bug-19,18-regression): monologue top-region
// retune + bubble dominance heuristic

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

/** Find a node by label — return its world position + bounds. */
async function findNode(
  page: Page,
  label: string,
): Promise<{ x: number; y: number; visible: boolean } | null> {
  return page.evaluate((needle) => {
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const app = window.__qa?.app as any;
    if (!app?.stage) return null;
    let result: { x: number; y: number; visible: boolean } | null = null;
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const walk = (n: any) => {
      if (n.label === needle) {
        const gp = n.getGlobalPosition?.();
        if (gp) result = { x: gp.x, y: gp.y, visible: n.visible !== false };
      }
      for (const c of n.children ?? []) walk(c);
    };
    walk(app.stage);
    return result;
  }, label);
}

/** Find ALL Text node values inside speech-bubble containers. */
async function readSpeechBubbleText(page: Page): Promise<string[]> {
  return page.evaluate(() => {
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const app = window.__qa?.app as any;
    if (!app?.stage) return [];
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
}

/** Find internal-monologue text + position. */
async function readMonologue(page: Page): Promise<{
  text: string;
  worldY: number | null;
  visible: boolean;
}> {
  return page.evaluate(() => {
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const app = window.__qa?.app as any;
    if (!app?.stage) return { text: '', worldY: null, visible: false };
    const result: { text: string; worldY: number | null; visible: boolean } = {
      text: '',
      worldY: null,
      visible: false,
    };
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const walk = (n: any) => {
      if (n.label === 'internal-monologue') {
        const gp = n.getGlobalPosition?.();
        result.worldY = gp?.y ?? null;
        result.visible = n.visible !== false;
        // collect text from descendants
        // biome-ignore lint/suspicious/noExplicitAny: walk
        const collect = (m: any) => {
          if (typeof m.text === 'string' && m.text.length > 0) result.text += `${m.text} `;
          for (const c of m.children ?? []) collect(c);
        };
        collect(n);
      }
      for (const c of n.children ?? []) walk(c);
    };
    walk(app.stage);
    return result;
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

test.describe('P5 demo · Round 11 (verify Bug #19 + Bug #18-regression)', () => {
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

  test('Bug #19 verify: monologue mounts at TOP region (y < 100), not overlapping bottom panel', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    // Drive into Day 1 morning_briefing → Event 1.1 (Vivian) → Event 1.2 — these
    // all have monologue paragraphs (`_..._`). The monologue should now mount
    // at top (y<100 in canvas logical = ~y<200 page coords for 1280×720 view).
    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了 → day_1_morning_briefing

    // At Day 1 morning_briefing's [开始今日] choice point — narration above panel,
    // possibly internal monologue from "_笑天下众生 / 反 David / 她也在装_" etc.
    const monologueAtDay1Morning = await readMonologue(page);
    console.log('[r11-bug19] monologue at Day 1 morning:', monologueAtDay1Morning);

    // Get canvas geometry to translate logical to page coords
    const g = await getCanvasGeom(page);
    if (monologueAtDay1Morning.visible && monologueAtDay1Morning.worldY != null) {
      // Logical y < 100 = page y < g.y + 100*g.scaleY
      const pageThreshold = g.y + 100 * g.scaleY;
      console.log(
        `[r11-bug19] monologue worldY=${monologueAtDay1Morning.worldY}, threshold=${pageThreshold}`,
      );
      expect(monologueAtDay1Morning.worldY).toBeLessThan(pageThreshold);
    } else {
      console.log('[r11-bug19] no monologue at Day 1 morning — checking next event');
    }
    await page.screenshot({ path: 'qa/output/r11-01-day1-morning-monologue.png' });

    // Continue into Event 1.2 sticky phase
    await pickChoiceAndAdvance(page, 0); // 开始今日
    const monologueAtE12 = await readMonologue(page);
    console.log('[r11-bug19] monologue at Event 1.2:', monologueAtE12);
    if (monologueAtE12.visible && monologueAtE12.worldY != null) {
      const pageThreshold = g.y + 100 * g.scaleY;
      expect(monologueAtE12.worldY).toBeLessThan(pageThreshold);
    }
    await page.screenshot({ path: 'qa/output/r11-02-event-1-2-monologue.png' });

    expect(pageErrors.length).toBe(0);
  });

  test('Bug #18-regression verify: bubble teardown across non-flush event boundaries', async ({
    page,
  }) => {
    // Day 4 has the reproducer — but driver hasn't been validated to Day 4 yet.
    // The Bug #18 fix surface (bubble dominance heuristic) should kick in at
    // ANY event boundary where new ink content arrives without a speaker tag,
    // regardless of which paint phase fires.
    //
    // Easier reproducer: Day 1 Event 1.2 mounts Lisa bubble ("挺烫的。") if
    // player picks [你先]. Then Event 1.3 starts (David elevator). Bubble
    // should tear down at the event boundary.

    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了
    await pickChoiceAndAdvance(page, 0); // 开始今日 → Event 1.2

    // Pick [让 Lisa 先] (idx 0) — emits Lisa "谢谢哈." bubble
    await pickChoiceAndAdvance(page, 0);
    // Now we're in Event 1.3 (David elevator). Lisa's bubble should be gone.
    const bubbleTextAtE13 = await readSpeechBubbleText(page);
    console.log('[r11-bug18-r] bubble text at Event 1.3:', bubbleTextAtE13);
    expect(bubbleTextAtE13.some((t) => t.includes('谢谢哈'))).toBe(false);

    // Event 1.3 has David lines ("我啊，周六加了一天班..."). After picking [还行你呢]
    // → Event 1.4 (王总监 cue). David bubble should be gone by then.
    await pickChoiceAndAdvance(page, 0); // 还行你呢

    // Now in 1.4 + 1.5 + 1.6 + after_work. After_work has 3 choices.
    const bubbleTextAtAfterWork = await readSpeechBubbleText(page);
    console.log('[r11-bug18-r] bubble text at after_work:', bubbleTextAtAfterWork);
    // No David line should persist
    expect(bubbleTextAtAfterWork.some((t) => t.includes('我啊，周六加了一天班'))).toBe(false);

    await page.screenshot({ path: 'qa/output/r11-03-after-work-no-stale-bubble.png' });

    expect(pageErrors.length).toBe(0);
  });

  test('Bug #19 deferred-choices phase: capture pre-flush state to confirm monologue at top', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);

    // From INITIAL state (intro screen 1, before first ▼ tap), the deferred-
    // choices phase has narration in panel + monologue MAY be visible at top.
    // Don't call advanceToChoices yet — capture this frame.
    await page.screenshot({ path: 'qa/output/r11-04-initial-intro-deferred.png' });

    const monologueInitial = await readMonologue(page);
    console.log('[r11-bug19-pre-flush] monologue at initial intro:', monologueInitial);
    const g = await getCanvasGeom(page);
    if (monologueInitial.visible && monologueInitial.worldY != null) {
      const pageThreshold = g.y + 100 * g.scaleY; // top 100 logical px
      console.log(
        `[r11-bug19-pre-flush] worldY=${monologueInitial.worldY}, threshold=${pageThreshold}`,
      );
      // Bug #19 Option A: monologue at PROTAGONIST_HEAD_ANCHOR (320, 26).
      // World y for (logical 26) = g.y + 26*g.scaleY ≈ g.y + 52 (for 720 viewport)
      expect(monologueInitial.worldY).toBeLessThan(pageThreshold);
      console.log('[r11-bug19-pre-flush] ✓ monologue at top region');
    } else {
      console.log(
        '[r11-bug19-pre-flush] no monologue at intro screen 1 (no _..._ in this paragraph)',
      );
    }
    expect(pageErrors.length).toBe(0);
  });

  test('Re-verify Bug #11 + #14 + #6 (no regressions)', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
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

    // Bug #6: long sticky ellipsis still works
    const ev23 = await listChoiceLabels(page);
    expect(ev23.length).toBe(3);
    const longChoice = ev23.find((l) => l.includes('主动跟老周说'));
    expect(longChoice?.includes('…')).toBe(true);
    expect(pageErrors.length).toBe(0);
  });
});
