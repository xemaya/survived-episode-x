// Round 3 driver — verify dev fixes that landed in commits:
//   - dedb258 fix(qa-bug-4,5,9)+feat(p5-T16) — panel mask + ink save schema + autosave-per-choice
//   - 6fb3445 feat(p5-T05-mini+T03-prop) — prop registry + tag interceptor
//   - 7f62762 feat(p5-T03-scene-mirror+speaker-tag) — scene state mirror
//
// Re-verifies which round-1/2 bugs are now resolved, and re-checks bugs that
// the dev didn't touch (#1 ink runtime crash, #2 **David** malformed choice,
// #3 daily_recap blob).

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
      sceneState: { snapshot: Record<string, string | null> };
      propRegistry: { getMountedIds?: () => string[] };
    };
  }
}

const CANVAS_W = 640;
const CANVAS_H = 360;
const PANEL_H = 156; // updated by Bug #4 fix
const PANEL_Y = CANVAS_H - PANEL_H - 8; // 196

interface CanvasGeom {
  x: number;
  y: number;
  scaleX: number;
  scaleY: number;
}

async function getCanvasGeom(page: Page): Promise<CanvasGeom> {
  const box = await page.locator('canvas').boundingBox();
  if (!box) throw new Error('canvas not found');
  return {
    x: box.x,
    y: box.y,
    scaleX: box.width / CANVAS_W,
    scaleY: box.height / CANVAS_H,
  };
}

function toPage(g: CanvasGeom, lx: number, ly: number): { x: number; y: number } {
  return { x: g.x + lx * g.scaleX, y: g.y + ly * g.scaleY };
}

async function clickSingleChoice(page: Page): Promise<void> {
  // Always go via clickChoiceByIndex — works whether the renderer is
  // ink-dialog `choice-0` (legacy) or T11 `sticky-0` (current).
  const ok = await clickChoiceByIndex(page, 0);
  if (!ok) throw new Error('clickSingleChoice: no choice-0/sticky-0 button on stage');
}

/** Find a choice button (sticky-N or choice-N) by its choice index in stage,
 *  read its world coords, and click. Returns true if found+clicked. */
async function clickChoiceByIndex(page: Page, idx: number): Promise<boolean> {
  const g = await getCanvasGeom(page);
  const logical = await page.evaluate((i) => {
    // biome-ignore lint/suspicious/noExplicitAny: stage tree walk
    const app = window.__qa?.app as any;
    if (!app?.stage) return null;
    let found: { x: number; y: number } | null = null;
    // biome-ignore lint/suspicious/noExplicitAny: Container API
    const walk = (node: any) => {
      if (
        typeof node.label === 'string' &&
        (node.label === `choice-${i}` ||
          node.label === `sticky-${i}` ||
          node.label === `sticky-fallback-${i}`)
      ) {
        // getGlobalPosition gives world space (logical 640x360 frame).
        const gp = node.getGlobalPosition?.();
        if (gp) found = { x: gp.x, y: gp.y };
      }
      for (const c of node.children ?? []) walk(c);
    };
    walk(app.stage);
    return found;
  }, idx);
  if (!logical) return false;
  const p = toPage(g, logical.x, logical.y);
  await page.mouse.click(p.x, p.y);
  return true;
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

async function readSceneState(page: Page): Promise<Record<string, string | null>> {
  return page.evaluate(() => ({ ...(window.__qa?.sceneState.snapshot ?? {}) }));
}

async function listAllStageLabels(page: Page): Promise<string[]> {
  return page.evaluate(() => {
    // biome-ignore lint/suspicious/noExplicitAny: stage walk
    const app = window.__qa?.app as any;
    if (!app?.stage) return [];
    const out: string[] = [];
    // biome-ignore lint/suspicious/noExplicitAny: PIXI container
    const walk = (n: any) => {
      if (typeof n.label === 'string' && n.label.length > 0) out.push(n.label);
      for (const c of n.children ?? []) walk(c);
    };
    walk(app.stage);
    return out;
  });
}

async function listChoiceLabels(page: Page): Promise<string[]> {
  return page.evaluate(() => {
    // biome-ignore lint/suspicious/noExplicitAny: stage walk
    const app = window.__qa?.app as any;
    if (!app?.stage) return [];
    const out: string[] = [];
    // biome-ignore lint/suspicious/noExplicitAny: PIXI
    const walk = (n: any) => {
      // sticky-N or choice-N
      if (
        typeof n.label === 'string' &&
        (n.label.startsWith('sticky-') || n.label.startsWith('choice-'))
      ) {
        // find inner Text
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
    // biome-ignore lint/suspicious/noExplicitAny: PIXI
    const app = window.__qa?.app as any;
    if (!app?.stage) return '';
    // biome-ignore lint/suspicious/noExplicitAny: walk
    const walk = (n: any): string => {
      // skip choice buttons
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
    const dialog = app.stage.children
      ?.find?.((c: any) => c.label === 'world')
      // biome-ignore lint/suspicious/noExplicitAny: walk
      ?.children?.find?.((c: any) => c.label === 'ink-dialog');
    return dialog ? walk(dialog) : '';
  });
}

test.describe('P5 demo · Round 3 (verify dev fixes for #4/#5/#8/#9)', () => {
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
    // Clear localStorage on FIRST navigation only (don't use addInitScript —
    // that runs on every reload + breaks the Bug #5 verify test). Instead
    // navigate to about:blank, evaluate, then go to the app.
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

  test('Bug #4 verify: panel grew to 156 + clip mask attached to text node', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);

    // Inspect ink-dialog tree for mask presence
    const dialogShape = await page.evaluate(() => {
      // biome-ignore lint/suspicious/noExplicitAny: stage walk
      const app = window.__qa?.app as any;
      // biome-ignore lint/suspicious/noExplicitAny: walk
      const dialog = app?.stage?.children
        ?.find?.((c: any) => c.label === 'world')
        // biome-ignore lint/suspicious/noExplicitAny: walk
        ?.children?.find?.((c: any) => c.label === 'ink-dialog');
      if (!dialog) return null;
      // biome-ignore lint/suspicious/noExplicitAny: walk
      const text = dialog.children?.find?.((c: any) => typeof c.text === 'string');
      // Pixi Graphics has a `geometry` field; minified class name is unreliable.
      // biome-ignore lint/suspicious/noExplicitAny: walk
      const graphicsCount =
        dialog.children?.filter?.(
          // biome-ignore lint/suspicious/noExplicitAny: PIXI
          (c: any) =>
            c.geometry != null || typeof c.rect === 'function' || typeof c.fill === 'function',
        ).length ?? 0;
      return {
        hasText: !!text,
        textHasMask: text?.mask != null,
        graphicsCount,
        // hint: panel BG + text mask = 2 Graphics in the dialog container
      };
    });
    console.log('[r3] ink-dialog shape:', dialogShape);
    expect(dialogShape?.hasText).toBe(true);
    expect(dialogShape?.textHasMask).toBe(true); // Bug #4 fix: mask attached
    expect(dialogShape?.graphicsCount).toBeGreaterThanOrEqual(2);

    // Click through intro 1/2/3 → Day 1 morning_briefing (which is the
    // "long text" case from Bug #4)
    await clickSingleChoice(page); // 然后呢
    await page.waitForTimeout(300);
    await clickSingleChoice(page); // 听懂了
    await page.waitForTimeout(300);
    await clickSingleChoice(page); // 我懂了
    await page.waitForTimeout(500);

    await page.screenshot({ path: 'qa/output/r3-01-day1-morning-after-fix.png' });
    // Visual: text should be clipped at panel boundary, not bleeding onto BG
  });

  test('Bug #9 verify: autosave fires after every ink choice', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(500);

    const lsBefore = await page.evaluate(() => {
      try {
        return Object.keys(localStorage).length;
      } catch {
        return 0;
      }
    });
    console.log('[r3] localStorage keys before any choice:', lsBefore);

    await clickSingleChoice(page); // 然后呢
    // Allow autosave's microtask + IO to land
    await page.waitForTimeout(800);

    const lsAfter = await page.evaluate(() => {
      try {
        const keys = Object.keys(localStorage);
        const sample: Record<string, string | null> = {};
        for (const k of keys.slice(0, 5)) {
          const v = localStorage.getItem(k) ?? '';
          sample[k] = v.length > 200 ? `${v.slice(0, 200)}...(${v.length}b)` : v;
        }
        return { count: keys.length, sample };
      } catch {
        return { count: 0, sample: {} };
      }
    });
    console.log('[r3] localStorage after 1 choice:', lsAfter);
    expect(lsAfter.count).toBeGreaterThan(0);

    // Verify the saved blob includes ink state json
    const hasInkBlob = await page.evaluate(() => {
      try {
        for (const k of Object.keys(localStorage)) {
          const v = localStorage.getItem(k) ?? '';
          if (v.includes('inkStateJson') || v.includes('flags') || v.includes('callstack'))
            return true;
        }
        return false;
      } catch {
        return false;
      }
    });
    console.log('[r3] save contains ink state blob:', hasInkBlob);
    expect(hasInkBlob).toBe(true);
  });

  test('Bug #5 verify: refresh restores ink state at last position (skips main_menu)', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(500);
    await clickSingleChoice(page); // 然后呢 → intro screen 2
    await page.waitForTimeout(500);
    await clickSingleChoice(page); // 听懂了 → intro screen 3
    await page.waitForTimeout(500);

    const preReloadText = await readDialogPanelText(page);
    console.log('[r3] pre-reload panel head:', preReloadText.slice(0, 80));
    expect(preReloadText).toContain('52 周');

    await page.reload();
    await page.waitForFunction(() => window.__qa?.ink?.isLoaded === true);
    await page.waitForTimeout(800);

    // Existing save restoration behavior (since P4): boot path skips main_menu
    // entirely when a save exists, jumping straight to the saved sceneState.
    // FSM should be at action_day after reload.
    const flow1 = await page.evaluate(() => window.__qa?.flow.state.kind);
    console.log('[r3] after reload flow.kind:', flow1);
    expect(flow1).toBe('action_day');

    // The Bug #5 specific check: ink dialog should show the last position
    // (intro screen 3), NOT intro screen 1 (which is what would render if
    // ink.divertTo('intro') had run unconditionally).
    const postReloadText = await readDialogPanelText(page);
    console.log('[r3] post-reload panel head:', postReloadText.slice(0, 80));
    expect(postReloadText).not.toContain('数咖啡杯'); // intro screen 1 marker
    expect(postReloadText).toContain('52 周'); // intro screen 3 marker

    await page.screenshot({ path: 'qa/output/r3-02-after-reload.png' });
  });

  test('Bug #8 verify: sceneState mirror updates from # tag stream', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(800);

    // Click through intro 1/2/3 → Day 1 morning briefing
    await clickSingleChoice(page);
    await page.waitForTimeout(200);
    await clickSingleChoice(page);
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // 我懂了 → episode_1 → day_1_morning_briefing
    await page.waitForTimeout(500);

    // Day 1 morning_briefing emits scene + time tags. Verify mirror updated.
    const sceneAfterIntro = await readSceneState(page);
    console.log('[r3] sceneState after Day 1 morning:', sceneAfterIntro);
    expect(sceneAfterIntro.scene).not.toBeNull();
    expect(sceneAfterIntro.scene).not.toBe('intro');
    expect(sceneAfterIntro.time).not.toBeNull();
    expect(sceneAfterIntro.time).not.toBe('pre_game');

    // Click [开始今日] → enters Event 1.1 (Vivian) → step() drains through
    // Event 1.2 (caishuijian) too because 1.1 has no choices. Tags from BOTH
    // events fire; mirror retains LATEST value per key — so by the time
    // step() returns we'll see 1.2's tags (`scene: break_room`,
    // `npc: it_xiaoma_back_at_machine`). This single-slot behaviour is
    // intrinsic to Bug #3 (event blob) — the mirror is correct given what
    // it received.
    await clickSingleChoice(page);
    await page.waitForTimeout(500);
    const sceneAtBlob = await readSceneState(page);
    console.log('[r3] sceneState after [开始今日] (blob 1.1+1.2):', sceneAtBlob);
    // Verify: SOME npc value populated; SOME scene change happened.
    expect(sceneAtBlob.npc).not.toBeNull();
    expect(sceneAtBlob.scene).not.toBe(sceneAfterIntro.scene);

    // Verify a prop sprite for fruit_bowl was mounted to the stage
    // (fruit_bowl_apple fires in Event 1.1 — even if 1.2 overwrites scene/
    // npc, prop sprites should accumulate per propRegistry semantics).
    const labels = await listAllStageLabels(page);
    console.log('[r3] all stage labels after blob:', labels);
    const propLabels = labels.filter((l) => l.startsWith('prop:'));
    console.log('[r3] prop:* sprites mounted:', propLabels);
    expect(propLabels.length).toBeGreaterThan(0);

    await page.screenshot({ path: 'qa/output/r3-03-event-1-1-vivian-with-tags.png' });
  });

  test('Choice-rendering: T11 sticky-notes are mounted (or fallback)', async ({ page }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(500);
    await clickSingleChoice(page);
    await page.waitForTimeout(200);
    await clickSingleChoice(page);
    await page.waitForTimeout(200);
    await clickSingleChoice(page);
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // event 1.1 + 1.2 (3 choices)
    await page.waitForTimeout(500);

    const choiceLabels = await listChoiceLabels(page);
    console.log('[r3] choice labels at Event 1.2:', choiceLabels);
    expect(choiceLabels.length).toBe(3);
    await page.screenshot({ path: 'qa/output/r3-04-event-1-2-sticky-or-fallback.png' });
  });

  test('Bug #1 + #2 verify (silent ink content sweep): Day 2 Event 2.2 has no malformed choice + Event 2.3 [偷喝那杯，再走] does not crash', async ({
    page,
  }) => {
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await page.waitForTimeout(500);

    // Drive: intro 1/2/3 → 开始今日 → 让Lisa先 → 还行你呢 → after_work 按时下班
    // → Day 2 morning → Day 2 Event 2.1 → Day 2 Event 2.2 (David)
    await clickSingleChoice(page); // 然后呢
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // 听懂了
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // 我懂了
    await page.waitForTimeout(200);
    await clickSingleChoice(page); // 开始今日 (event 1.1 + 1.2)
    await page.waitForTimeout(500);
    await clickChoiceByIndex(page, 0); // 让Lisa先
    await page.waitForTimeout(500);
    await clickChoiceByIndex(page, 0); // event 1.3 还行你呢
    await page.waitForTimeout(500);
    // event 1.4-1.6 + day_1 after_work
    await clickChoiceByIndex(page, 1); // 按时下班 (idx 1 of 3)
    await page.waitForTimeout(500);
    await clickSingleChoice(page); // 开始今日 (Day 2 morning_briefing)
    await page.waitForTimeout(500);

    // Day 2 Event 2.1 — Lisa milk tea (3 choices)
    const labelsAtDay2_E1 = await listChoiceLabels(page);
    console.log('[r3] labels at Day 2 Event 2.1:', labelsAtDay2_E1);
    if (labelsAtDay2_E1.length >= 3) {
      await clickChoiceByIndex(page, 0); // 一起 (or whatever 0 is)
      await page.waitForTimeout(500);
    }

    // After Day 2 Event 2.1 → step blob runs through 2.2 (David, no choice)
    // → 2.3 (老周凉茶) and presents 2.3's 3 choices. Verify we land on 2.3
    // choices (not the malformed David choice from old Bug #2).
    const labelsAt23 = await listChoiceLabels(page);
    console.log('[r3] labels after Day 2 Event 2.1 → step blob:', labelsAt23);
    await page.screenshot({ path: 'qa/output/r3-05-day2-event-23-after-blob.png' });

    // Bug #2 fixed: no choice should contain 'David'
    const hasMalformed = labelsAt23.some((l) => l.includes('David'));
    expect(hasMalformed).toBe(false);

    // Bug #2 fixed: choices should be Event 2.3's
    expect(labelsAt23.some((l) => l.includes('偷喝那杯'))).toBe(true);
    expect(labelsAt23.some((l) => l.includes('拿走杯子'))).toBe(true);
    expect(labelsAt23.length).toBe(3);

    // Bug #1 verify: pick [偷喝那杯，再走] (sticky-0). Old bug crashed with
    // "ran out of content" because the choice had no -> divert. The fix
    // added a `-` gather joining all 3 paths to `~ check_state_after_choice
    // -> day_2_after_work`. Now picking it should advance, not crash.
    const errorsBefore = consoleErrors.length;
    await clickChoiceByIndex(page, 0);
    await page.waitForTimeout(800);

    // Verify no "ran out of content" runtime error fired
    const newErrors = consoleErrors.slice(errorsBefore);
    const ranOutOfContent = newErrors.some((e) => e.includes('ran out of content'));
    console.log('[r3] new console errors after [偷喝那杯]:', newErrors);
    console.log('[r3] Bug #1 still crashes?', ranOutOfContent);
    expect(ranOutOfContent).toBe(false);

    // Verify ink advanced past Event 2.3 (state should have changed somewhere)
    const vars = await readVars(page, ['lao_zhou_score', 'state']);
    console.log('[r3] vars after [偷喝那杯]:', vars);
    // [偷喝那杯，再走] gives state +2, lao_zhou_score +0 (per ink line ~698)
    // We can't assert exact state because earlier choices also affected it.
    // Just verify no crash + ink continues.
    const stateAfter = await page.evaluate(() => window.__qa?.flow.state.kind);
    console.log('[r3] FSM state after Bug #1 verify:', stateAfter);

    await page.screenshot({ path: 'qa/output/r3-06-day2-after-laozhou-pick.png' });
  });
});
