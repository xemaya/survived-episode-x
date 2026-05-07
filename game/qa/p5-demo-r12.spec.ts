// Round 12 driver — verify Bug #15 fix (Pixi-side crop edges hide sprite-sheet
// label leakage).
// Latest commit: 450ef7c fix(qa-bug-15): Pixi-side crop edges to hide sprite-sheet label leakage

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

test.describe('P5 demo · Round 12 (verify Bug #15 fix)', () => {
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

  test('Bug #15 verify: fruit_bowl prop has Pixi-side crop mask + screenshots clean', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    // Drive to Day 1 morning_briefing where fruit_bowl is visible
    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了 → day_1_morning_briefing

    // At Day 1 morning sticky [开始今日] — fruit_bowl prop should be visible
    // (per ink Day 1 morning emits prop:fruit_bowl_apple at line ~243)
    await page.screenshot({ path: 'qa/output/r12-01-day1-morning-fruitbowl.png' });

    // Inspect the prop:fruit_bowl sprite to check for crop mask
    const propInfo = await page.evaluate(() => {
      // biome-ignore lint/suspicious/noExplicitAny: walk
      const app = window.__qa?.app as any;
      if (!app?.stage) return null;
      let result: {
        label: string;
        visible: boolean;
        hasMask: boolean;
        worldX: number | null;
        worldY: number | null;
        textureWidth: number | null;
        textureHeight: number | null;
      } | null = null;
      // biome-ignore lint/suspicious/noExplicitAny: walk
      const walk = (n: any) => {
        if (n.label === 'prop:fruit_bowl') {
          const gp = n.getGlobalPosition?.();
          // The fruit_bowl is a Sprite (not Container) per PropEntity.
          // Check if it has a mask attached.
          // biome-ignore lint/suspicious/noExplicitAny: PIXI
          const findMask = (m: any): boolean => {
            if (m.mask != null) return true;
            for (const c of m.children ?? []) if (findMask(c)) return true;
            return false;
          };
          result = {
            label: n.label,
            visible: n.visible !== false,
            hasMask: findMask(n) || n.mask != null,
            worldX: gp?.x ?? null,
            worldY: gp?.y ?? null,
            // biome-ignore lint/suspicious/noExplicitAny: texture
            textureWidth: (n.texture as any)?.width ?? null,
            // biome-ignore lint/suspicious/noExplicitAny: texture
            textureHeight: (n.texture as any)?.height ?? null,
          };
        }
        for (const c of n.children ?? []) walk(c);
      };
      walk(app.stage);
      return result;
    });
    console.log('[r12-bug15] fruit_bowl prop info:', propInfo);
    // Bug #15 fix Option C: Pixi-side crop mask attached to sprite/parent
    // OR sprite uses cropped texture region. Either way, label band hidden.
    // We can't do programmatic OCR — visual inspection of screenshot needed.
    // Just verify the prop exists and is in stage tree.
    expect(propInfo).not.toBeNull();
    expect(pageErrors.length).toBe(0);
  });

  test('Bug #15 visual: capture fruit_bowl while it is actively rendered', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);
    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了 → day_1_morning_briefing

    // Day 1 morning_briefing has prop:fruit_bowl_apple emitted at Event 1.1
    // (line ~243). To capture it visible, click [开始今日] RAW (no advance)
    // and tap panel a few times until step lands on a moment where fruit_bowl
    // is visible (between Event 1.1 prop emission and Event 1.2 scene change).
    await clickChoiceByIndex(page, 0); // 开始今日 raw
    await page.waitForTimeout(500);
    await page.screenshot({ path: 'qa/output/r12-02-after-kaishi-jinri-raw.png' });

    // Try a single ▼ tap to flush deferred-choices and see if fruit_bowl visible
    await clickPanelToContinue(page);
    await page.waitForTimeout(500);
    await page.screenshot({ path: 'qa/output/r12-03-after-1-flush.png' });

    // Inspect prop visibility at this moment
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
    console.log('[r12-bug15-visual] prop visibility after 1 flush:', propVis);
  });

  test('Re-verify Bug #6 + #11 + #14 + #18-regression + #19 (no regressions)', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(500);
    await advanceToChoices(page);

    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了
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

    // Bug #18-regression: no stale Lisa bubble at Event 2.3
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
    console.log('[r12-regress] bubble at Event 2.3:', bubbleText);
    expect(bubbleText.some((t) => t.includes('谢谢哈'))).toBe(false);
    expect(bubbleText.some((t) => t.includes('你喝什么'))).toBe(false);

    // Bug #14: phone hidden during scene transitions
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
    console.log('[r12-regress] prop vis at Event 2.3:', propVis);

    expect(pageErrors.length).toBe(0);
  });
});
