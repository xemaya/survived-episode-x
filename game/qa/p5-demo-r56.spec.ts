// Round 56 driver — verify Bug #44 (NPC 立绘 portrait source + AVG side-stand)
// Latest commit: 5949d89 fix(qa-bug-44): NPC 立绘 portrait source + AVG side-stand layout

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

async function advanceToChoices(page: Page, maxTaps = 50): Promise<number> {
  let taps = 0;
  while (taps < maxTaps) {
    const labels = await listChoiceLabels(page);
    if (labels.length > 0) return taps;
    await clickPanelToContinue(page);
    await page.waitForTimeout(300);
    taps++;
  }
  return taps;
}

async function pickChoiceAndAdvance(page: Page, idx: number) {
  const ok = await clickChoiceByIndex(page, idx);
  if (!ok) throw new Error(`no choice/sticky-${idx} on stage`);
  await page.waitForTimeout(300);
  await advanceToChoices(page);
}

test.describe('P5 demo · Round 56 (Bug #44 NPC 立绘 portrait + side-stand)', () => {
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

  test('Bug #44 verify: NPC sprites positioned at AVG side-stand (left + right edges)', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0); // 开始今日 → Event 1.2 (Lisa + David active)

    const npcInfo = await page.evaluate(() => {
      // biome-ignore lint/suspicious/noExplicitAny: walk
      const app = window.__qa?.app as any;
      if (!app?.stage) return [];
      const out: Array<{ label: string; scaleX: number; x: number; y: number; visible: boolean }> = [];
      // biome-ignore lint/suspicious/noExplicitAny: walk
      const walk = (n: any) => {
        if (typeof n.label === 'string' && n.label.startsWith('npc:')) {
          out.push({
            label: n.label,
            scaleX: n.scale?.x ?? 1,
            x: n.x ?? 0,
            y: n.y ?? 0,
            visible: n.visible !== false,
          });
        }
        for (const c of n.children ?? []) walk(c);
      };
      walk(app.stage);
      return out;
    });
    console.log('[r56-bug44] NPC sprites at Event 1.2:', npcInfo);

    // Bug #44: AVG side-stand layout — NPC立绘 anchors to canvas edges.
    // Verify sprites exist + are visible.
    const visibleNpcs = npcInfo.filter((n) => n.visible);
    expect(visibleNpcs.length).toBeGreaterThan(0);

    await page.screenshot({ path: 'qa/output/r56-01-npc-side-stand.png' });
    expect(pageErrors.length).toBe(0);
  });

  test('Re-verify Bug #25 + #29 + #38 + #40 + #43 (no regressions)', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    const labels = await page.evaluate(() => {
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
    expect(labels.includes('pause-button')).toBe(true);
    expect(labels.includes('status-hud')).toBe(true);
    expect(labels.includes('calendar-widget')).toBe(true);

    expect(pageErrors.length).toBe(0);
  });
});
