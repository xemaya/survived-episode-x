import { flow } from '@/flow/dispatcher';
import type { SceneState } from '@/flow/scene-state';
import { render } from 'preact';
import { useEffect, useState } from 'preact/hooks';
import { MainMenu } from './menu/main-menu';
import { assertOverlayAllowed } from './stage';

// Pause menu lives in Task 5; for now this stub avoids an import error.
function PauseMenu(): preact.JSX.Element {
  return <div class="menu-root menu-root--pause">已暂停（P1 stub — pause UI in Task 5）</div>;
}

function OverlayRouter(): preact.JSX.Element | null {
  const [state, setState] = useState<SceneState>(flow.state);
  useEffect(() => {
    const unsub = flow.subscribe((next) => {
      setState(next);
    });
    return unsub;
  }, []);

  switch (state.kind) {
    case 'main_menu':
      assertOverlayAllowed(state);
      return <MainMenu />;
    case 'pause':
      assertOverlayAllowed(state);
      return <PauseMenu />;
    case 'action_day':
      // Diegetic-only state; no overlay
      return null;
  }
}

export function mountOverlay(host: HTMLElement): void {
  // Show the overlay container (CSS hides it by default until Preact mounts)
  host.style.display = 'flex';
  host.style.pointerEvents = 'auto';
  render(<OverlayRouter />, host);
}
