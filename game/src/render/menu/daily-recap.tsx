import { ap } from '@/economy/ap';
import { dayCycle } from '@/flow/day-cycle';
import { useEffect, useState } from 'preact/hooks';

interface Props {
  day: number;
}

// design/gdd/daily-weekly-recap-ui.md: skippable, auto-progress at 90s.
// Content: today's AP used + event count (P3: events not implemented,
// shown as 0) + skip hint. HR-tone copy throughout.

const AUTO_PROGRESS_MS = 90_000;

export function DailyRecap({ day }: Props): preact.JSX.Element {
  const [secondsLeft, setSecondsLeft] = useState(Math.floor(AUTO_PROGRESS_MS / 1000));

  useEffect(() => {
    const tickId = window.setInterval(() => {
      setSecondsLeft((s) => Math.max(0, s - 1));
    }, 1000);
    const progressId = window.setTimeout(() => dayCycle.confirmRecap(), AUTO_PROGRESS_MS);
    return () => {
      window.clearInterval(tickId);
      window.clearTimeout(progressId);
    };
  }, []);

  const apUsed = ap.max - ap.current;

  return (
    <div class="menu-root menu-root--recap">
      <h2 class="menu-title menu-title--small">Day {day} — 日报</h2>
      <p class="menu-subtitle">已登记今日工作量</p>
      <div class="recap-rows">
        <div class="recap-row">
          <span class="recap-label">AP 消耗</span>
          <span class="recap-value">
            {apUsed} / {ap.max}
          </span>
        </div>
        <div class="recap-row">
          <span class="recap-label">事件登记</span>
          <span class="recap-value">0 项</span>
        </div>
      </div>
      <div class="menu-buttons">
        <button
          type="button"
          class="menu-button menu-button--primary"
          onClick={() => dayCycle.confirmRecap()}
        >
          下一天
        </button>
      </div>
      <p class="recap-hint">{secondsLeft} 秒后自动进入下一天</p>
    </div>
  );
}
