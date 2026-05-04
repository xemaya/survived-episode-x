import { flow } from '@/flow/dispatcher';
import type { SceneState } from '@/flow/scene-state';

interface Props {
  state: SceneState & { kind: 'pause' };
}

export function PauseMenu({ state }: Props): preact.JSX.Element {
  const resume = (): void => {
    flow.request(state.resumeTo);
  };
  const quitToMenu = (): void => {
    flow.request({ kind: 'main_menu' });
  };

  return (
    <div class="menu-root menu-root--pause">
      <h2 class="menu-title menu-title--small">已暂停</h2>
      <p class="menu-subtitle">按 Esc 或点 「继续」 回去</p>
      <div class="menu-buttons">
        <button type="button" class="menu-button menu-button--primary" onClick={resume}>
          继续
        </button>
        <button type="button" class="menu-button" onClick={quitToMenu}>
          回主菜单
        </button>
      </div>
    </div>
  );
}
