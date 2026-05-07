// QA driver for P5 demo (Round 1: boot → 新游戏 → intro → Day 1 → Day 7).
//
// Drives the live Vite dev server at localhost:1420. Uses the dev-only
// `window.__qa` hook (added in src/main.ts under import.meta.env.DEV) to
// inspect ink runtime state and dispatch choices without depending on
// canvas pixel coordinates. Screenshots each beat under qa/output/.
//
// Run from game/ with the dev server already up:
//   pnpm dev               # in another terminal
//   npx playwright test
//
// Findings flow into design/vertical-slice/p5-qa-bug-reports.md (filed
// by the QA session, not this driver).

import { type Page, expect, test } from '@playwright/test';

interface InkChoice {
  index: number;
  text: string;
}

interface QaSnapshot {
  flow: string;
  ink: {
    canContinue: boolean;
    currentText: string;
    choices: InkChoice[];
    vars: Record<string, unknown>;
  };
}

const TRACKED_VARS = [
  'kpi',
  'money',
  'state',
  'lisa_score',
  'david_score',
  'wang_score',
  'sick_count',
  'fruit_bowl',
];

declare global {
  interface Window {
    __qa?: {
      ink: {
        isLoaded: boolean;
        sourcePath: string | null;
        step: () => {
          text: string;
          tags: { raw: string; key: string; value: string }[];
          canContinue: boolean;
          choices: { index: number; text: string }[];
          ended: boolean;
        };
        selectChoice: (i: number) => unknown;
        getVar: (n: string) => unknown;
        listVars: () => string[];
      };
      flow: { state: { kind: string; [k: string]: unknown } };
      save: unknown;
      app: unknown;
    };
  }
}

async function waitForBoot(page: Page): Promise<void> {
  await page.waitForFunction(() => window.__qa?.ink?.isLoaded === true, undefined, {
    timeout: 10000,
  });
}

async function snapshot(page: Page): Promise<QaSnapshot> {
  return page.evaluate((vars) => {
    const qa = window.__qa;
    if (!qa) throw new Error('window.__qa not present');
    const flowKind = qa.flow.state.kind;
    const flowExtra: Record<string, unknown> = {};
    for (const k of Object.keys(qa.flow.state)) {
      if (k !== 'kind') flowExtra[k] = qa.flow.state[k];
    }
    const flowDesc = `${flowKind}${
      Object.keys(flowExtra).length ? `(${JSON.stringify(flowExtra)})` : ''
    }`;
    const varsOut: Record<string, unknown> = {};
    for (const v of vars) varsOut[v] = qa.ink.getVar(v);
    return {
      flow: flowDesc,
      ink: {
        canContinue: false,
        currentText: '',
        choices: [],
        vars: varsOut,
      },
    } as QaSnapshot;
  }, TRACKED_VARS);
}

/** Step ink and return resulting text + choices (for assertion). */
async function inkStep(page: Page): Promise<{
  text: string;
  choices: InkChoice[];
  canContinue: boolean;
  ended: boolean;
  tagsRaw: string[];
}> {
  return page.evaluate(() => {
    const qa = window.__qa;
    if (!qa) throw new Error('window.__qa not present');
    const r = qa.ink.step();
    return {
      text: r.text,
      choices: r.choices,
      canContinue: r.canContinue,
      ended: r.ended,
      tagsRaw: r.tags.map((t) => t.raw),
    };
  });
}

async function inkSelect(
  page: Page,
  idx: number,
): Promise<{
  text: string;
  choices: InkChoice[];
  ended: boolean;
  tagsRaw: string[];
}> {
  return page.evaluate((i) => {
    const qa = window.__qa;
    if (!qa) throw new Error('window.__qa not present');
    const r = qa.ink.selectChoice(i) as {
      text: string;
      tags: { raw: string }[];
      choices: InkChoice[];
      ended: boolean;
    };
    return {
      text: r.text,
      choices: r.choices,
      ended: r.ended,
      tagsRaw: r.tags.map((t) => t.raw),
    };
  }, idx);
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

async function flowKind(page: Page): Promise<string> {
  return page.evaluate(() => window.__qa?.flow.state.kind ?? '');
}

async function logBeat(page: Page, label: string): Promise<void> {
  const snap = await snapshot(page);
  // eslint-disable-next-line no-console
  console.log(`[QA] ${label} ↳ flow=${snap.flow} vars=${JSON.stringify(snap.ink.vars)}`);
}

test.describe('P5 demo · Round 1 (boot → Day 7)', () => {
  test.beforeEach(async ({ page }) => {
    page.on('pageerror', (err) => console.error('[page error]', err.message));
    page.on('console', (msg) => {
      if (msg.type() === 'error' || msg.type() === 'warning') {
        console.log(`[console.${msg.type()}]`, msg.text());
      }
    });
    // Clear any prior save so we get the deterministic intro flow.
    await page.addInitScript(() => {
      try {
        localStorage.clear();
      } catch {
        // ignore
      }
    });
    await page.goto('/');
    await waitForBoot(page);
  });

  test('full episode-1 path through Day 7', async ({ page }) => {
    // ── Boot — should be at main_menu ────────────────────────────────────
    await logBeat(page, 'boot');
    expect(await flowKind(page)).toBe('main_menu');
    await page.screenshot({ path: 'qa/output/01-boot-main-menu.png' });

    // The ink runtime is pre-loaded with episode-1 + diverted to 'intro'.
    // Verify that.
    const inkPath = await page.evaluate(() => window.__qa?.ink.sourcePath);
    expect(inkPath).toContain('episode-1');

    // ── Click 新游戏 (Preact button in DOM overlay) ──────────────────────
    await page.getByRole('button', { name: '新游戏' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'morning_briefing');
    await logBeat(page, 'after [新游戏]');
    await page.screenshot({ path: 'qa/output/02-morning-briefing.png' });

    // ── Click 开始今日 — enters action_day, ink dialog mounts ───────────
    await page.getByRole('button', { name: '开始今日' }).click();
    await page.waitForFunction(() => window.__qa?.flow.state.kind === 'action_day');
    await logBeat(page, 'after [开始今日]');
    // Give the workstation scene + ink-dialog a tick to mount + step.
    await page.waitForTimeout(500);
    await page.screenshot({ path: 'qa/output/03-action-day-intro-1.png' });

    // ── Intro screen 1 — verify text + single choice [然后呢] ───────────
    // ink-dialog has already step()'d. Reading current state requires a fresh
    // step() — but step() drains content. Instead we drive via selectChoice
    // matching whatever the dialog already painted. We trust the dialog
    // rendered screen 1 and we now click its choice.

    // Sanity: ink should currently have exactly 1 choice = "然后呢"
    const introScreen1Choices = await page.evaluate(
      () =>
        // biome-ignore lint/suspicious/noExplicitAny: bridging into private inkjs Story
        (window.__qa?.ink as any)?.story?.currentChoices?.map?.((c: { text: string }) => c.text) ??
        [],
    );
    console.log('[QA] intro screen 1 choices (via story):', introScreen1Choices);

    const r1 = await inkSelect(page, 0);
    console.log(
      '[QA] after 然后呢 → text head:',
      r1.text.slice(0, 60),
      '... choices:',
      r1.choices.map((c) => c.text),
    );
    expect(r1.choices.map((c) => c.text)).toEqual(['听懂了']);
    expect(r1.text).toContain('8 个时间槽');
    expect(r1.text).toContain('不可能三角');
    await page.screenshot({ path: 'qa/output/04-action-day-intro-2.png' });

    // Screen 2 → Screen 3 (听懂了 → endgame)
    const r2 = await inkSelect(page, 0);
    console.log(
      '[QA] after 听懂了 → text head:',
      r2.text.slice(0, 60),
      '... choices:',
      r2.choices.map((c) => c.text),
    );
    expect(r2.choices.map((c) => c.text)).toEqual(['我懂了, 开始第 1 天']);
    expect(r2.text).toContain('52 周');
    expect(r2.text).toContain('我妈不知道');
    await page.screenshot({ path: 'qa/output/05-action-day-intro-3.png' });

    // Screen 3 → episode_1 → day_1_morning_briefing + auto-fall-through to
    // event 1.1 (Vivian, no-choice) + event 1.2 (caishuijian, 3 choices).
    const r3 = await inkSelect(page, 0);
    console.log(
      '[QA] after 我懂了 → text head:',
      r3.text.slice(0, 80),
      '... choices:',
      r3.choices.map((c) => c.text),
    );
    expect(r3.text).toContain('闹钟响了 3 次');
    expect(r3.text).toContain('陈笑天');
    expect(r3.text).toContain('9:14');
    // The tags should include scene + time + prop hints
    expect(r3.tagsRaw.some((t) => t.startsWith('scene:'))).toBe(true);
    // Single choice = [开始今日]
    expect(r3.choices.map((c) => c.text)).toEqual(['开始今日']);
    await page.screenshot({ path: 'qa/output/06-day1-morning-briefing.png' });

    // ── Day 1 event 1.1 Vivian (no choices) → fall-through to event 1.2 ──
    const r4 = await inkSelect(page, 0);
    console.log(
      '[QA] after 开始今日 → text head:',
      r4.text.slice(0, 80),
      '... choices:',
      r4.choices.map((c) => c.text),
    );
    // Event 1.1 (Vivian) + Event 1.2 (caishuijian) get concatenated since
    // step() drains until next choice. Verify both contents present.
    expect(r4.text).toContain('Vivian'); // Event 1.1
    expect(r4.text).toContain('苹果'); // Event 1.1 fruit_bowl
    expect(r4.text).toContain('茶水间'); // Event 1.2
    expect(r4.text).toContain('Lisa'); // Event 1.2

    // Event 1.2 has 3 choices: 让 Lisa 先 / 你先 / 不说话，先接你的
    expect(r4.choices.length).toBe(3);
    expect(r4.choices[0]?.text).toContain('Lisa 先');
    await page.screenshot({ path: 'qa/output/07-day1-event-1-vivian-and-2-lisa.png' });

    // Verify event 1.1 side effects fired (money +1, state +2, fruit_bowl=apple)
    const afterE1 = await readVars(page, ['money', 'state', 'fruit_bowl']);
    console.log('[QA] after event 1.1 vars:', afterE1);
    expect(afterE1.money).toBe(5501);
    expect(afterE1.state).toBe(82);
    expect(afterE1.fruit_bowl).toBe('apple');

    // ── Day 1 event 1.2 (let Lisa go first → +1 lisa_score) ─────────────
    const r5 = await inkSelect(page, 0); // 让 Lisa 先
    const afterE2 = await readVars(page, ['lisa_score']);
    console.log(
      '[QA] after 让Lisa先 → lisa_score:',
      afterE2.lisa_score,
      'next text:',
      r5.text.slice(0, 80),
    );
    expect(afterE2.lisa_score).toBe(1);
    // Should have transitioned to event 1.3 (David elevator) — 3 choices
    expect(r5.text).toContain('电梯');
    expect(r5.choices.length).toBe(3);
    await page.screenshot({ path: 'qa/output/08-day1-event-3-david.png' });

    // ── Continue Day 1 events (1.3 David → 1.4 Wang → 1.5 LaoZhou → 1.6 Lisa) ──
    const r6 = await inkSelect(page, 0); // 还行，你呢 (David)
    console.log(
      '[QA] after david choice → text head:',
      r6.text.slice(0, 100),
      'choices:',
      r6.choices.map((c) => c.text),
    );
    // After David, events 1.4 (Wang), 1.5 (LaoZhou no-choice), 1.6 (Lisa no-choice)
    // all flow into day_1_after_work which has 3 choices.
    expect(r6.choices.length).toBeGreaterThan(0);
    await page.screenshot({ path: 'qa/output/09-day1-after-david.png' });

    // ── Day 1 after_work: pick 提前下班 to test that path exists ─────────
    const afterWorkChoices = r6.choices.map((c) => c.text);
    console.log('[QA] day_1 after_work choices:', afterWorkChoices);
    // Verify all 3 are present (申报加班 / 按时下班 / 提前下班)
    expect(afterWorkChoices.some((t) => t.includes('申报加班'))).toBe(true);
    expect(afterWorkChoices.some((t) => t.includes('按时下班'))).toBe(true);
    expect(afterWorkChoices.some((t) => t.includes('提前下班'))).toBe(true);

    // pick 按时下班 (middle path)
    const onTimeIdx = afterWorkChoices.findIndex((t) => t.includes('按时下班'));
    const r7 = await inkSelect(page, onTimeIdx);
    console.log(
      '[QA] after day_1 按时下班 → text head:',
      r7.text.slice(0, 100),
      'choices:',
      r7.choices.map((c) => c.text),
    );
    await page.screenshot({ path: 'qa/output/10-day1-end-recap.png' });

    // ── Day 2 onward: just keep advancing until story ends ──────────────
    const beats: { day: number; choicesSeen: string[][] } = { day: 2, choicesSeen: [] };
    let safety = 80;
    while (safety-- > 0) {
      const cur = await page.evaluate(() => {
        // biome-ignore lint/suspicious/noExplicitAny: bridging into private inkjs Story
        const story = (window.__qa?.ink as any)?.story;
        if (!story) return null;
        return {
          choices: (story.currentChoices ?? []).map((c: { text: string }) => c.text),
          canContinue: story.canContinue,
        };
      });
      if (!cur) break;
      // If story continues without choices, drive a step to resolve
      if (cur.canContinue && cur.choices.length === 0) {
        await inkStep(page);
        continue;
      }
      // No choices and not continuing = ended
      if (!cur.canContinue && cur.choices.length === 0) {
        console.log('[QA] story ended at iteration', 80 - safety);
        break;
      }
      // Has choices — pick first; record
      beats.choicesSeen.push(cur.choices);
      const r = await inkSelect(page, 0);
      const dayMatch = /day_(\d+)/.exec(JSON.stringify(r.tagsRaw));
      if (dayMatch?.[1]) {
        const d = Number(dayMatch[1]);
        if (d > beats.day) {
          beats.day = d;
          await page.screenshot({ path: `qa/output/auto-day-${d}.png` });
        }
      }
    }
    console.log('[QA] beats summary:', {
      day: beats.day,
      totalChoiceBeats: beats.choicesSeen.length,
    });
    console.log('[QA] all choice texts seen across run:');
    for (let i = 0; i < beats.choicesSeen.length; i++) {
      console.log(`  beat ${i}: ${JSON.stringify(beats.choicesSeen[i])}`);
    }

    // Final state vars
    const finalVars = await readVars(page, TRACKED_VARS);
    console.log('[QA] final vars:', finalVars);

    await page.screenshot({ path: 'qa/output/99-final.png' });
  });
});
