import { snapshotCurrentRunState } from './snapshot';
import { save } from './system';

// Fire-and-forget autosave. Called after every card play + day/month
// transition. The pending guard prevents overlapping async writes —
// the second caller silently skips rather than racing the first.
//
// NOT called on the gameover path: commitGameOverArchive already
// clears current_run, so writing it again would re-create a stale file.
let pending = false;

export async function autosave(): Promise<void> {
  if (pending) return;
  pending = true;
  try {
    await save.writeCurrentRun(snapshotCurrentRunState());
  } catch (e) {
    console.warn('[autosave] failed:', (e as Error).message);
  } finally {
    pending = false;
  }
}
