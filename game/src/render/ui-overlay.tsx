import { flow } from '@/flow/dispatcher';
import type { SceneState } from '@/flow/scene-state';
import { render } from 'preact';
import { useEffect, useState } from 'preact/hooks';
import { MainMenu } from './menu/main-menu';
import { PauseMenu } from './menu/pause-menu';
import { assertOverlayAllowed } from './stage';

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
      return <PauseMenu state={state} />;
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
