import { flow } from '@/flow/dispatcher';
import type { SceneState } from '@/flow/scene-state';
import { dialogState } from '@/render/dialog/dialog-state';
import { save } from '@/save/system';

interface Props {
  state: SceneState & { kind: 'pause' };
}

export function PauseMenu({ state }: Props): preact.JSX.Element {
  const resume = (): void => {
    flow.request(state.resumeTo);
  };
  // Q-Y (Bug #38): "回主菜单" is a hard-restart per spec — clear the
  // saved run, reset the dialog cache, reload the page. Same pattern as
  // ink-dialog.ts's triggerNewGame() (gameover [新游戏] handler). Brutal
  // but guarantees a clean boot across all singletons; cheaper than
  // wiring per-singleton resets for a P5 demo.
  const quitToMenu = (): void => {
    void (async () => {
      try {
        await save.clearCurrentRun();
      } catch (e) {
        console.warn('[pause-menu] clearCurrentRun failed:', (e as Error).message);
      }
      dialogState.reset();
      window.location.reload();
    })();
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
          回主菜单（清存档）
        </button>
      </div>
    </div>
  );
}
