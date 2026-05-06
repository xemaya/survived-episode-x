// Unit tests for prop tag parsing + registry CRUD. The Pixi sprite
// loading inside createPropEntity is verified manually via `pnpm dev`
// (Assets.load needs a real fetch).

import { describe, expect, it } from 'vitest';
import {
  type PropEntity,
  type PropScope,
  computeCropFrame,
} from '../../../src/render/diegetic/prop-entity';
import { PropRegistry, parsePropTagValue } from '../../../src/render/diegetic/prop-registry';

function fakeEntity(
  id: string,
  states: ReadonlyArray<string>,
  scope: PropScope = 'scene',
): PropEntity {
  let current = states[0] ?? '';
  let visible = scope === 'permanent';
  const calls: string[] = [];
  const entity: PropEntity & { _calls: string[] } = {
    id,
    scope,
    stateNames: [...states].sort(),
    get currentState() {
      return current;
    },
    get visible() {
      return visible;
    },
    async setState(s: string) {
      calls.push(s);
      visible = true;
      if (states.includes(s)) current = s;
    },
    hasState(s: string) {
      return states.includes(s);
    },
    setVisible(v: boolean) {
      visible = v;
    },
    destroy() {},
    _calls: calls,
  };
  return entity;
}

describe('parsePropTagValue', () => {
  it('returns null for empty value', () => {
    expect(parsePropTagValue('', ['mug'])).toBeNull();
    expect(parsePropTagValue('   ', ['mug'])).toBeNull();
  });

  it('returns null when no registered id is a prefix', () => {
    expect(parsePropTagValue('phone_face_up', ['mug'])).toBeNull();
  });

  it('returns null when value is exactly an id (no state suffix)', () => {
    expect(parsePropTagValue('mug', ['mug'])).toBeNull();
    // Trailing underscore with empty state is also rejected
    expect(parsePropTagValue('mug_', ['mug'])).toBeNull();
  });

  it('splits id_state for simple ids', () => {
    expect(parsePropTagValue('mug_full', ['mug'])).toEqual({ id: 'mug', state: 'full' });
    expect(parsePropTagValue('phone_face_up', ['phone'])).toEqual({
      id: 'phone',
      state: 'face_up',
    });
  });

  it('preserves multi-segment state suffixes', () => {
    expect(parsePropTagValue('phone_with_badge', ['phone'])).toEqual({
      id: 'phone',
      state: 'with_badge',
    });
  });

  it('prefers longest registered id when prefixes overlap', () => {
    const ids = ['sticky', 'sticky_huo_dao_zhouwu'];
    expect(parsePropTagValue('sticky_huo_dao_zhouwu_fresh', ids)).toEqual({
      id: 'sticky_huo_dao_zhouwu',
      state: 'fresh',
    });
    expect(parsePropTagValue('sticky_curled', ids)).toEqual({
      id: 'sticky',
      state: 'curled',
    });
  });

  it('handles ids with underscores when only the long id is registered', () => {
    expect(
      parsePropTagValue('sticky_huo_dao_zhouwu_curled_edge_1week', ['sticky_huo_dao_zhouwu']),
    ).toEqual({
      id: 'sticky_huo_dao_zhouwu',
      state: 'curled_edge_1week',
    });
  });
});

describe('PropRegistry', () => {
  it('registers, retrieves, and unregisters entities', () => {
    const r = new PropRegistry();
    const e = fakeEntity('mug', ['full', 'empty']);
    r.register(e);
    expect(r.has('mug')).toBe(true);
    expect(r.get('mug')).toBe(e);
    expect(r.ids()).toContain('mug');
    r.unregister('mug');
    expect(r.has('mug')).toBe(false);
  });

  it('setStateFromTag dispatches to the matching entity', async () => {
    const r = new PropRegistry();
    const fruit = fakeEntity('fruit_bowl', ['apple', 'strawberry', 'empty']);
    r.register(fruit);

    const ok = await r.setStateFromTag('fruit_bowl_strawberry');
    expect(ok).toBe(true);
    expect(fruit.currentState).toBe('strawberry');
  });

  it('returns false when tag value matches no registered id', async () => {
    const r = new PropRegistry();
    r.register(fakeEntity('mug', ['full']));
    const ok = await r.setStateFromTag('phone_face_up');
    expect(ok).toBe(false);
  });

  it('snapshot mirrors current state of all registered props', async () => {
    const r = new PropRegistry();
    r.register(fakeEntity('mug', ['full', 'empty']));
    r.register(fakeEntity('phone', ['face_down', 'face_up']));
    await r.setStateFromTag('phone_face_up');
    const snap = r.snapshot();
    expect(snap.mug).toBe('full');
    expect(snap.phone).toBe('face_up');
  });

  it('clear() drops all registrations', () => {
    const r = new PropRegistry();
    r.register(fakeEntity('mug', ['full']));
    r.register(fakeEntity('phone', ['face_down']));
    r.clear();
    expect(r.ids()).toEqual([]);
  });
});

describe('PropEntity scope + hideScopedTo (Bug #14 fix)', () => {
  it('scene-scoped fakes start invisible; permanent fakes start visible', () => {
    const sceneProp = fakeEntity('phone', ['face_down'], 'scene');
    const permProp = fakeEntity('mug', ['full'], 'permanent');
    expect(sceneProp.visible).toBe(false);
    expect(permProp.visible).toBe(true);
  });

  it('setState wakes the prop (visible=true) even if state matches current', async () => {
    const phone = fakeEntity('phone', ['face_down', 'face_up'], 'scene');
    expect(phone.visible).toBe(false);
    await phone.setState('face_down'); // same as initial
    expect(phone.visible).toBe(true);
  });

  it('hideScopedTo("scene") hides only scene-scoped entities, permanent unaffected', async () => {
    const r = new PropRegistry();
    const phone = fakeEntity('phone', ['face_down'], 'scene');
    const fruit = fakeEntity('fruit_bowl', ['apple'], 'scene');
    const mug = fakeEntity('mug', ['full'], 'permanent');
    r.register(phone);
    r.register(fruit);
    r.register(mug);
    // Wake the scene props first.
    await r.setStateFromTag('phone_face_down');
    await r.setStateFromTag('fruit_bowl_apple');
    expect(phone.visible).toBe(true);
    expect(fruit.visible).toBe(true);

    const hiddenCount = r.hideScopedTo('scene');
    expect(hiddenCount).toBe(2);
    expect(phone.visible).toBe(false);
    expect(fruit.visible).toBe(false);
    expect(mug.visible).toBe(true); // permanent — unaffected
  });

  it('post-hide setStateFromTag re-shows scene-scoped entities', async () => {
    const r = new PropRegistry();
    const phone = fakeEntity('phone', ['face_down', 'face_up'], 'scene');
    r.register(phone);
    await r.setStateFromTag('phone_face_down');
    expect(phone.visible).toBe(true);

    r.hideScopedTo('scene');
    expect(phone.visible).toBe(false);

    // Next prop tag — even with the SAME state — wakes it.
    await r.setStateFromTag('phone_face_down');
    expect(phone.visible).toBe(true);
  });

  it('hideScopedTo on empty registry is a no-op (returns 0)', () => {
    const r = new PropRegistry();
    expect(r.hideScopedTo('scene')).toBe(0);
  });

  it('hideScopedTo("permanent") hides permanent props (escape hatch — unusual but works)', () => {
    const r = new PropRegistry();
    const mug = fakeEntity('mug', ['full'], 'permanent');
    r.register(mug);
    expect(mug.visible).toBe(true);
    expect(r.hideScopedTo('permanent')).toBe(1);
    expect(mug.visible).toBe(false);
  });
});

describe('computeCropFrame (Bug #15 fix — pure crop math)', () => {
  it('returns null when edges are undefined', () => {
    expect(computeCropFrame(341, 844, undefined)).toBeNull();
  });

  it('returns null when all edges are zero', () => {
    expect(computeCropFrame(341, 844, { top: 0, right: 0, bottom: 0, left: 0 })).toBeNull();
  });

  it('returns null when an empty object is passed', () => {
    expect(computeCropFrame(341, 844, {})).toBeNull();
  });

  it('crops top + bottom (the fruit_bowl reproducer)', () => {
    expect(computeCropFrame(341, 844, { top: 80, bottom: 80 })).toEqual({
      x: 0,
      y: 80,
      width: 341,
      height: 844 - 80 - 80,
    });
  });

  it('crops all four sides asymmetrically', () => {
    expect(computeCropFrame(200, 200, { top: 10, right: 20, bottom: 30, left: 40 })).toEqual({
      x: 40,
      y: 10,
      width: 200 - 40 - 20,
      height: 200 - 10 - 30,
    });
  });

  it('clamps inner dimensions to 1px minimum on degenerate edges', () => {
    const f = computeCropFrame(100, 100, { top: 200, bottom: 200 });
    expect(f).not.toBeNull();
    expect(f?.height).toBe(1);
  });

  it('handles partial-edge specs (only some sides defined)', () => {
    expect(computeCropFrame(100, 100, { right: 20 })).toEqual({
      x: 0,
      y: 0,
      width: 80,
      height: 100,
    });
    expect(computeCropFrame(100, 100, { left: 30 })).toEqual({
      x: 30,
      y: 0,
      width: 70,
      height: 100,
    });
  });
});
