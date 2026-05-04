import { flow } from '@/flow/dispatcher';
import type { SceneState } from '@/flow/scene-state';
import { render } from 'preact';
import { useEffect, useState } from 'preact/hooks';
import { DailyRecap } from './menu/daily-recap';
import { KpiReview } from './menu/kpi-review';
import { MainMenu } from './menu/main-menu';
import { PauseMenu } from './menu/pause-menu';
import { WeeklyRecap } from './menu/weekly-recap';
import { assertOverlayAllowed } from './stage';

interface RouterProps {
  host: HTMLElement;
}

function OverlayRouter({ host }: RouterProps): preact.JSX.Element | null {
  const [state, setState] = useState<SceneState>(flow.state);
  useEffect(() => {
    const unsub = flow.subscribe((next) => setState(next));
    return unsub;
  }, []);

  useEffect(() => {
    const hasOverlay =
      state.kind === 'main_menu' ||
      state.kind === 'pause' ||
      state.kind === 'recap' ||
      state.kind === 'kpi_review' ||
      state.kind === 'gameover';
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
    case 'recap':
      assertOverlayAllowed(state);
      return state.recapKind === 'weekly' ? (
        <WeeklyRecap day={state.day} />
      ) : (
        <DailyRecap day={state.day} />
      );
    case 'action_day':
      return null;
    case 'kpi_review':
      assertOverlayAllowed(state);
      return <KpiReview monthIndex={state.monthIndex} />;
    case 'gameover':
      assertOverlayAllowed(state);
      return <div class="menu-root">Game Over (Task 5 wires this)</div>;
  }
}

export function mountOverlay(host: HTMLElement): void {
  render(<OverlayRouter host={host} />, host);
}
