import { flow } from '@/flow/dispatcher';

// Single global keyboard handler. P1 only handles Esc; P2+ extends with
// the 12 act_* mappings (input/dual_focus, etc., per spec §3 input system).

export function installKeyboardHandler(): () => void {
  const onKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Escape') {
      e.preventDefault();
      togglePause();
    }
  };
  window.addEventListener('keydown', onKeyDown);
  return () => window.removeEventListener('keydown', onKeyDown);
}

function togglePause(): void {
  const state = flow.state;
  if (state.kind === 'action_day') {
    flow.request({ kind: 'pause', resumeTo: state });
  } else if (state.kind === 'pause') {
    flow.request(state.resumeTo);
  }
  // Esc in main_menu does nothing (no place to go back to)
}
