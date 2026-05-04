import { flow } from '@/flow/dispatcher';

export function MainMenu(): preact.JSX.Element {
  const startGame = (): void => {
    flow.request({ kind: 'action_day', day: 1, phase: 'morning' });
  };

  return (
    <div class="menu-root menu-root--main">
      <h1 class="menu-title">活过第 X 集</h1>
      <p class="menu-subtitle">一个反向 KPI 办公室生存模拟</p>
      <div class="menu-buttons">
        <button type="button" class="menu-button menu-button--primary" onClick={startGame}>
          开始
        </button>
        {/* 「继续」 (load save) and 「设置」 deferred to P4+ */}
      </div>
    </div>
  );
}
