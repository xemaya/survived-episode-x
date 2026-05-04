import { flow } from '@/flow/dispatcher';
import type { SceneState } from '@/flow/scene-state';
import { save } from '@/save/system';
import { useEffect, useState } from 'preact/hooks';

export function MainMenu(): preact.JSX.Element {
  const [hasSave, setHasSave] = useState(false);
  useEffect(() => {
    void save.hasCurrentRun().then(setHasSave);
  }, []);

  const startGame = (): void => {
    // Task 4 will check if save exists and prompt "discard previous run?"
    // P4 Task 1 placeholder: always start fresh from action_day day=1.
    flow.request({ kind: 'action_day', day: 1, phase: 'morning' });
  };

  const continueGame = (): void => {
    // Save was already loaded on boot via main.ts; just transition to
    // the saved sceneState. main.ts has already done flow.request for
    // restored state, so by the time MainMenu shows, this button just
    // dismisses to the current state.
    void save.loadCurrentRun().then((s) => {
      // Same cast rationale as main.ts: schema includes future P4 states.
      if (s) flow.request(s.sceneState as SceneState);
    });
  };

  const viewArchive = (): void => flow.request({ kind: 'archive_list' });

  return (
    <div class="menu-root menu-root--main">
      <h1 class="menu-title">活过第 X 集</h1>
      <p class="menu-subtitle">一个反向 KPI 办公室生存模拟</p>
      <div class="menu-buttons">
        <button
          type="button"
          class={`menu-button ${hasSave ? '' : 'menu-button--primary'}`}
          onClick={startGame}
        >
          新游戏
        </button>
        <button
          type="button"
          class="menu-button menu-button--primary"
          onClick={continueGame}
          disabled={!hasSave}
          style={{ opacity: hasSave ? 1 : 0.4, cursor: hasSave ? 'pointer' : 'not-allowed' }}
        >
          继续
        </button>
        <button type="button" class="menu-button" onClick={viewArchive}>
          档案
        </button>
      </div>
    </div>
  );
}
