import { flow } from '@/flow/dispatcher';
import type { SceneState } from '@/flow/scene-state';
import { render } from 'preact';
import { useEffect, useState } from 'preact/hooks';
import { MainMenu } from './menu/main-menu';
import { PauseMenu } from './menu/pause-menu';
import { assertOverlayAllowed } from './stage';

interface RouterProps {
  host: HTMLElement;
}

function OverlayRouter({ host }: RouterProps): preact.JSX.Element | null {
  const [state, setState] = useState<SceneState>(flow.state);
  useEffect(() => {
    const unsub = flow.subscribe((next) => {
      setState(next);
    });
    return unsub;
  }, []);

  // Toggle host visibility and pointer-events based on whether the current
  // state has overlay UI. Otherwise the empty Preact tree leaves the
  // host div sitting on top with its rgba backdrop dimming the canvas
  // and pointer-events:auto blocking clicks from reaching Pixi.
  useEffect(() => {
    const hasOverlay = state.kind === 'main_menu' || state.kind === 'pause';
    host.style.display = hasOverlay ? 'flex' : 'none';
    host.style.pointerEvents = hasOverlay ? 'auto' : 'none';
  }, [state.kind, host]);

  switch (state.kind) {
    case 'main_menu':
      assertOverlayAllowed(state);
      return <MainMenu />;
    case 'pause':
      assertOverlayAllowed(state);
      return <PauseMenu state={state} />;
    case 'action_day':
    case 'recap':
    case 'kpi_review':
    case 'gameover':
      // Diegetic-only states; no overlay in P3
      return null;
  }
}

export function mountOverlay(host: HTMLElement): void {
  // Initial display/pointer-events are set by OverlayRouter's useEffect
  // on first render (state-driven). Default CSS keeps the host hidden
  // until Preact mounts the first state.
  render(<OverlayRouter host={host} />, host);
}
