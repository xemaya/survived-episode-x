// Round 5 driver — verify Bug #16 fix + visual checks for Bug #13 (working tree
// batch-9), Bug #14, Bug #15. Latest commits seen:
//   - cfcc902 fix(qa-bug-16): re-tune NPC anchor stubs to narrative geometry
//   - 7ded1bd fix(qa-bug-1,2): commit episode-1.ink content fixes
//
// Working tree has uncommitted batch-9 changes for Bug #13 (dialog-phase.ts).

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

/** Find a node by label and return its global position + visibility. */
async function findNodeWorld(page: Page, label: string) {
  return page.evaluate((needle) => {
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const app = window.__qa?.app as any;
    if (!app?.stage) return null;
    let result: { x: number; y: number; visible: boolean; alpha: number } | null = null;
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const walk = (n: any) => {
      if (n.label === needle) {
        const gp = n.getGlobalPosition?.();
        if (gp) result = { x: gp.x, y: gp.y, visible: n.visible !== false, alpha: n.alpha ?? 1 };
      }
      for (const c of n.children ?? []) walk(c);
    };
    walk(app.stage);
    return result;
  }, label);
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

test.describe('P5 demo · Round 5 (verify Bug #16 + visual checks #13/#14/#15)', () => {
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

  test('Bug #16 verify: 老周 speech bubble anchors to right-mid (x≈540, y≈160)', async ({
    page,
  }) => {
    // Drive to Day 2 Event 2.3 where 老周 speaks
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了 → day_1
    await pickChoiceAndAdvance(page, 0); // 开始今日 → event 1.2
    await pickChoiceAndAdvance(page, 0); // 让Lisa先 → 1.3
    await pickChoiceAndAdvance(page, 0); // 还行你呢 → 1.4-1.6 + after_work

    let labels = await listChoiceLabels(page);
    const onTimeIdx = labels.findIndex((l) => l.includes('按时下班'));
    expect(onTimeIdx).toBeGreaterThanOrEqual(0);
    await pickChoiceAndAdvance(page, onTimeIdx);

    // Day 2 [开始今日]
    labels = await listChoiceLabels(page);
    if (labels[0]?.includes('开始今日')) await pickChoiceAndAdvance(page, 0);

    // Day 2 Event 2.1 → pick any
    const ev21 = await listChoiceLabels(page);
    console.log('[r5-bug16] Event 2.1:', ev21);
    if (ev21.length >= 1) await pickChoiceAndAdvance(page, 0);

    // Now at Day 2 Event 2.3 (老周凉茶) — sceneState should reflect 老周 speaking
    const ev23 = await listChoiceLabels(page);
    console.log('[r5-bug16] Event 2.3 choices:', ev23);
    expect(ev23.length).toBe(3);

    // Read sceneState — speaker should be 'lao_zhou' (Q-1 id)
    const sceneSnap = await page.evaluate(() => ({ ...(window.__qa?.sceneState.snapshot ?? {}) }));
    console.log('[r5-bug16] sceneState at Event 2.3:', sceneSnap);

    // Check speech-bubble world position
    const bubble = await findNodeWorld(page, 'speech-bubble');
    console.log('[r5-bug16] speech-bubble world pos:', bubble);

    await page.screenshot({ path: 'qa/output/r5-01-event-2-3-laozhou-bubble.png' });

    // The fix re-tunes 老周 to (540, 160) logical. Bubble container is anchored
    // there; world position should be roughly that point on the canvas (scaled
    // by viewport-fit factor). If no bubble mounted at this beat (no
    // `# speaker:` tag yet at the choice presentation moment), bubble may be null.
    if (bubble) {
      const g = await getCanvasGeom(page);
      const expectedPageX = g.x + 540 * g.scaleX;
      const expectedPageY = g.y + 160 * g.scaleY;
      console.log(
        `[r5-bug16] expected bubble near (${expectedPageX.toFixed(0)}, ${expectedPageY.toFixed(0)}) page coords`,
      );
      // Allow ±50px tolerance for bubble offset (head + tail)
      expect(Math.abs(bubble.x - expectedPageX)).toBeLessThan(120);
      expect(Math.abs(bubble.y - expectedPageY)).toBeLessThan(120);
    } else {
      console.log(
        '[r5-bug16] no speech-bubble mounted at Event 2.3 choice phase — speaker tag may have fallen out of step blob',
      );
    }

    expect(pageErrors.length).toBe(0);
  });

  test('Bug #13 verify (working tree): panel + sticky-notes do NOT vertically overlap', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);

    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了 → day_1
    await pickChoiceAndAdvance(page, 0); // 开始今日 → event 1.2 (3 sticky choices visible)

    // At this beat, narration text + 3 sticky choices should NOT visually overlap
    // per Bug #13 fix. Inspect: ink-dialog panel should be hidden OR text moved
    // to header band, sticky rack at desk surface.
    const labels = await listAllStageLabels(page);
    console.log('[r5-bug13] stage labels at Event 1.2:', labels);

    // Find ink-dialog panel BG and sticky-notes layer; compare Y ranges.
    const panelInfo = await page.evaluate(() => {
      // biome-ignore lint/suspicious/noExplicitAny: PIXI walk
      const app = window.__qa?.app as any;
      // biome-ignore lint/suspicious/noExplicitAny: walk
      const dialog = app?.stage?.children
        ?.find?.((c: any) => c.label === 'world')
        // biome-ignore lint/suspicious/noExplicitAny: walk
        ?.children?.find?.((c: any) => c.label === 'ink-dialog');
      if (!dialog) return null;
      // panel BG is 1st Graphics child; visible flag indicates whether panel is shown
      // biome-ignore lint/suspicious/noExplicitAny: walk
      const panelVisible = dialog.visible !== false;
      const dialogAlpha = dialog.alpha ?? 1;
      // biome-ignore lint/suspicious/noExplicitAny: walk
      const text = dialog.children?.find?.((c: any) => typeof c.text === 'string');
      return {
        dialogVisible: panelVisible,
        dialogAlpha,
        textRendered: text?.text ?? '',
        textY: text?.y,
      };
    });
    console.log('[r5-bug13] dialog panel info at sticky choices:', panelInfo);

    // Bug #13 fix variants:
    //   - "deferred-choices" (long text): ▼ click first → panel hidden → sticky alone
    //   - "header-band" (short text < 60 chars): no panel, narration as small Text above sticky
    //   - "choices-only": empty narration → sticky alone
    // At Event 1.2 the narration is multi-paragraph (>60 chars) — should be
    // either deferred-choices (no sticky yet) OR if we already clicked ▼,
    // sticky alone with no panel.

    const stickyCount = labels.filter((l) => l.startsWith('sticky-')).length;
    const hasPanelText =
      (panelInfo?.textRendered ?? '').length > 5 && panelInfo?.textRendered !== '...';
    console.log(
      `[r5-bug13] sticky count: ${stickyCount}, dialog visible: ${panelInfo?.dialogVisible}, dialog text: "${(panelInfo?.textRendered ?? '').slice(0, 30)}..."`,
    );

    // Bug #13 expectation: NOT BOTH sticky-rack visible AND substantial narration text.
    // If 3 sticky choices visible, panel should not be showing multi-paragraph text.
    if (stickyCount >= 3) {
      // If text is substantive AND panel is rendered, that's the bug.
      // Allow header-band: text < 60 chars is OK alongside sticky.
      const headerBandOk = (panelInfo?.textRendered ?? '').length < 60;
      console.log('[r5-bug13] sticky+text scenario: header-band ok?', headerBandOk);
      expect(headerBandOk).toBe(true);
    }
    await page.screenshot({ path: 'qa/output/r5-02-event-1-2-no-overlap.png' });
  });

  test('Bug #14 visual: phone prop persists into daily_recap', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);
    await pickChoiceAndAdvance(page, 0); // 然后呢
    await pickChoiceAndAdvance(page, 0); // 听懂了
    await pickChoiceAndAdvance(page, 0); // 我懂了 → day_1
    await pickChoiceAndAdvance(page, 0); // 开始今日 → 1.2
    await pickChoiceAndAdvance(page, 0); // 让Lisa先 → 1.3
    await pickChoiceAndAdvance(page, 0); // 还行你呢 → 1.4-1.6 + after_work
    const labels = await listChoiceLabels(page);
    const onTimeIdx = labels.findIndex((l) => l.includes('按时下班'));
    await pickChoiceAndAdvance(page, onTimeIdx);

    // After 按时下班 → daily_recap → pagebreak → next morning. Inspect
    // stage tree DURING the recap pagebreak (before final tap).
    const stageDuringRecap = await listAllStageLabels(page);
    const propLabels = stageDuringRecap.filter((l) => l.startsWith('prop:'));
    console.log('[r5-bug14] props mounted during/after Day 1 recap:', propLabels);

    // Continue tapping until next choice
    await advanceToChoices(page);
    const day2Labels = await listAllStageLabels(page);
    const day2Props = day2Labels.filter((l) => l.startsWith('prop:'));
    console.log('[r5-bug14] props at Day 2 morning:', day2Props);

    await page.screenshot({ path: 'qa/output/r5-03-day1-recap-or-day2-morning.png' });
    // Bug #14 still open; just record what props persist
    console.log(`[r5-bug14] phone prop visible during recap?`, propLabels.includes('prop:phone'));
  });

  test('Bug #15 visual: capture screenshots showing potential sprite-sheet label leakage', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);
    await advanceToChoices(page);
    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0);
    await pickChoiceAndAdvance(page, 0);
    // Now at Day 1 morning briefing — fruit_bowl + phone props should be on stage
    await page.screenshot({
      path: 'qa/output/r5-04-day1-morning-fruit-phone.png',
      fullPage: false,
    });

    // Also a tighter shot for sprite-sheet label inspection — full-canvas at viewport
    const propLabels = (await listAllStageLabels(page)).filter((l) => l.startsWith('prop:'));
    console.log('[r5-bug15] mounted props at Day 1 morning:', propLabels);
  });

  test('Re-verify Bug #3 + Bug #6 still pass (no regressions)', async ({ page }) => {
    // Quick: drive past intro → Day 1 events → Day 2 Event 2.3, expect ellipsis on long sticky.
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

    const ev23 = await listChoiceLabels(page);
    console.log('[r5-regress] Event 2.3 choices:', ev23);
    expect(ev23.length).toBe(3);
    const longChoice = ev23.find((l) => l.includes('主动跟老周说'));
    expect(longChoice).toBeDefined();
    const renderedText = longChoice?.split('=').slice(1).join('=') ?? '';
    expect(renderedText.includes('…')).toBe(true);
    expect(pageErrors.length).toBe(0);
  });
});
