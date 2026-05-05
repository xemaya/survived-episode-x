// Bridges `tagDispatcher` to `propRegistry`. Call once at scene mount
// so subsequent `# prop:` / `# diegetic_prop:` tags from ink trigger
// sprite swaps via the prop entity registry.
//
// Returns a teardown that unregisters the listeners — call from the
// scene's teardowns array so a scene swap doesn't leave dangling
// handlers pointing to a destroyed prop registry.

import { tagDispatcher } from '@/ink/tag-interceptors';
import { propRegistry } from './prop-registry';

export function installPropTagHandler(): () => void {
  const onProp = tagDispatcher.on('prop', (tag) => {
    void propRegistry.setStateFromTag(tag.value);
  });
  // `# diegetic_prop:` carries the same `<id>_<state>` payload; the
  // distinction (extra visual emphasis on the prop) is a render-side
  // hook for the future. For now, route to the same handler.
  const onDiegetic = tagDispatcher.on('diegetic_prop', (tag) => {
    void propRegistry.setStateFromTag(tag.value);
  });
  return () => {
    onProp();
    onDiegetic();
  };
}
