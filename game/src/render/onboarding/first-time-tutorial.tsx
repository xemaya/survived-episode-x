// Q-K-2nd (Bug #23 second half + Bug #30): one-time onboarding modal.
//
// Mounts on first boot only — keyed off the `survived:tutorial_seen`
// localStorage flag. After the player dismisses the modal, the flag
// is written and the modal element is unmounted; subsequent boots
// skip it entirely.
//
// Content (per spec):
//   - 游戏概念 = 反向 KPI 中国职场生存模拟
//   - 三种 voice (视角 narration / 笑天 monologue / 选项 sticky)
//   - 不可能三角 (KPI / 钱 / 状态)
//   - 52 集 finite + 病倒 cap = 6
//
// Mount path: separate from ui-overlay (via own DOM root). main.ts
// calls `mountFirstTimeTutorial()` early in boot before any other
// scene mounts. Cheap to skip on subsequent boots — flag check is
// the only synchronous read.

import { render } from 'preact';
import { useState } from 'preact/hooks';

const FLAG_KEY = 'survived:tutorial_seen';

export function hasSeenTutorial(): boolean {
  try {
    return window.localStorage?.getItem(FLAG_KEY) === '1';
  } catch {
    return false;
  }
}

export function markTutorialSeen(): void {
  try {
    window.localStorage?.setItem(FLAG_KEY, '1');
  } catch (e) {
    console.warn('[tutorial] failed to write seen flag:', (e as Error).message);
  }
}

interface Props {
  onDismiss: () => void;
}

export function FirstTimeTutorial({ onDismiss }: Props): preact.JSX.Element | null {
  const [dismissed, setDismissed] = useState(false);

  if (dismissed) return null;

  const dismiss = (): void => {
    markTutorialSeen();
    setDismissed(true);
    onDismiss();
  };

  return (
    <div class="menu-root menu-root--tutorial">
      <h2 class="menu-title menu-title--small">活过第 X 集</h2>
      <p class="menu-subtitle">中国职场反向 KPI 生存模拟</p>

      <div class="recap-rows">
        <div class="recap-row">
          <span class="recap-label">目标</span>
          <span class="recap-value">活过 52 集</span>
        </div>
        <div class="recap-row">
          <span class="recap-label">不可能三角</span>
          <span class="recap-value">KPI · 钱 · 状态</span>
        </div>
        <div class="recap-row">
          <span class="recap-label">病倒上限</span>
          <span class="recap-value">6 次</span>
        </div>
        <div class="recap-row recap-row--separator">
          <span class="recap-label">三种声音</span>
          <span class="recap-value">视角 / 笑天 / 选项</span>
        </div>
      </div>

      <p class="menu-subtitle" style={{ maxWidth: '480px', textAlign: 'left' }}>
        屏幕底部对话框是叙事 (你的视角) + 笑天的内心独白 (italic); 桌面上的便签是你的选项 (3 选
        1)。右上角 3 条 bar 是你的 KPI / 钱 / 状态。月末考核 KPI
        不达标会被裁；累积超阈太多会被"晋升处刑"。
      </p>

      <div class="menu-buttons">
        <button type="button" class="menu-button menu-button--primary" onClick={dismiss}>
          开始上班
        </button>
      </div>
    </div>
  );
}

/** Mount the tutorial into a freshly-created DOM element overlaid on
 * top of #ui-overlay. Returns whether the tutorial was actually shown
 * (first boot) — caller decides what to do with the result (e.g. skip
 * autoplay until dismiss). On subsequent boots, returns false without
 * touching the DOM. */
export function mountFirstTimeTutorial(): boolean {
  if (hasSeenTutorial()) return false;

  const host = document.createElement('div');
  host.id = 'tutorial-overlay';
  Object.assign(host.style, {
    position: 'fixed',
    inset: '0',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    background: 'rgba(8, 10, 14, 0.92)',
    zIndex: '20', // above ui-overlay (z=10)
  });
  document.body.appendChild(host);

  const onDismiss = (): void => {
    host.remove();
  };

  render(<FirstTimeTutorial onDismiss={onDismiss} />, host);
  return true;
}
