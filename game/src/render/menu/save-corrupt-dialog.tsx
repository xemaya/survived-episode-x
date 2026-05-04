import { flow } from '@/flow/dispatcher';
import { save } from '@/save/system';

interface Props {
  errorMessage: string;
}

export function SaveCorruptDialog({ errorMessage }: Props): preact.JSX.Element {
  const startFresh = async (): Promise<void> => {
    // Discard the corrupt save — load went null, no in-memory state to clear
    await save.clearCurrentRun();
    flow.request({ kind: 'main_menu' });
  };

  return (
    <div class="menu-root menu-root--corrupt">
      <h2 class="menu-title menu-title--small">存档损坏</h2>
      <p class="menu-subtitle">无法读取上次进度</p>
      <div class="briefing-status">
        <p class="corrupt-error-detail">{errorMessage}</p>
      </div>
      <div class="menu-buttons">
        <button
          type="button"
          class="menu-button menu-button--primary"
          onClick={() => void startFresh()}
        >
          放弃存档，开始新游戏
        </button>
      </div>
    </div>
  );
}
