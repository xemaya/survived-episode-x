import { flow } from '@/flow/dispatcher';
import type { SceneState } from '@/flow/scene-state';
import { render } from 'preact';
import { useEffect, useState } from 'preact/hooks';
import { AfterWork } from './menu/after-work';
import { ArchiveList } from './menu/archive-list';
import { DailyRecap } from './menu/daily-recap';
import { GameOver } from './menu/gameover';
import { KpiReview } from './menu/kpi-review';
import { MainMenu } from './menu/main-menu';
import { MorningBriefing } from './menu/morning-briefing';
import { PauseMenu } from './menu/pause-menu';
import { SaveCorruptDialog } from './menu/save-corrupt-dialog';
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
      state.kind === 'morning_briefing' ||
      state.kind === 'after_work' ||
      state.kind === 'recap' ||
      state.kind === 'kpi_review' ||
      state.kind === 'gameover' ||
      state.kind === 'archive_list' ||
      state.kind === 'save_corrupt';
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
    case 'morning_briefing':
      assertOverlayAllowed(state);
      return <MorningBriefing day={state.day} />;
    case 'after_work':
      assertOverlayAllowed(state);
      return <AfterWork day={state.day} />;
    case 'action_overtime':
      // Diegetic — workstation scene remains visible; no overlay.
      return null;
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
      return <GameOver reason={state.reason} monthIndex={state.monthIndex} />;
    case 'archive_list':
      assertOverlayAllowed(state);
      return <ArchiveList />;
    case 'save_corrupt':
      assertOverlayAllowed(state);
      return <SaveCorruptDialog errorMessage={state.errorMessage} />;
  }
}

export function mountOverlay(host: HTMLElement): void {
  render(<OverlayRouter host={host} />, host);
}
