// Unit tests for the scene-state mirror — single-pass cache that
// records the latest # scene / # npc / # time / # weather tag value
// and dispatches to subscribers. Tag-handler installation is verified
// by hand-driving the global tagDispatcher.

import { afterEach, describe, expect, it, vi } from 'vitest';
import { parseTag } from '../../src/ink/runtime';
import { tagDispatcher } from '../../src/ink/tag-interceptors';
import { installSceneStateTagHandler, sceneState } from '../../src/scene/scene-state-mirror';

afterEach(() => {
  sceneState.reset();
  tagDispatcher.reset();
});

describe('SceneStateMirror', () => {
  it('starts with all keys null', () => {
    const s = sceneState.snapshot;
    expect(s.scene).toBeNull();
    expect(s.npc).toBeNull();
    expect(s.time).toBeNull();
    expect(s.weather).toBeNull();
  });

  it('set() updates the cache and notifies subscribers', () => {
    const fn = vi.fn();
    sceneState.on('scene', fn);
    sceneState.set('scene', 'workstation');
    expect(sceneState.get('scene')).toBe('workstation');
    expect(fn).toHaveBeenCalledWith('workstation');
  });

  it('set() with the same value does NOT notify (debounce identical)', () => {
    const fn = vi.fn();
    sceneState.set('time', '9:14');
    sceneState.on('time', fn);
    sceneState.set('time', '9:14');
    expect(fn).not.toHaveBeenCalled();
  });

  it('per-key listeners are isolated', () => {
    const sceneFn = vi.fn();
    const npcFn = vi.fn();
    sceneState.on('scene', sceneFn);
    sceneState.on('npc', npcFn);
    sceneState.set('npc', 'lisa_at_desk_typing');
    expect(npcFn).toHaveBeenCalledTimes(1);
    expect(sceneFn).not.toHaveBeenCalled();
  });

  it('warns once when an unknown scene id arrives but still stores it', () => {
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    sceneState.set('scene', 'nonexistent_scene_xyz');
    expect(sceneState.get('scene')).toBe('nonexistent_scene_xyz');
    expect(warn).toHaveBeenCalled();
    warn.mockRestore();
  });

  it('does NOT warn for known scene ids (workstation/phone/monitor_modal/endgame)', () => {
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    sceneState.set('scene', 'workstation');
    sceneState.set('scene', 'phone');
    sceneState.set('scene', 'monitor_modal');
    sceneState.set('scene', 'endgame');
    expect(warn).not.toHaveBeenCalled();
    warn.mockRestore();
  });

  it('reset() drops cache and listeners', () => {
    sceneState.set('scene', 'workstation');
    expect(sceneState.get('scene')).toBe('workstation');
    const fn = vi.fn();
    sceneState.on('scene', fn);
    sceneState.reset();
    sceneState.set('scene', 'phone');
    expect(fn).not.toHaveBeenCalled(); // listener was dropped by reset
    expect(sceneState.get('scene')).toBe('phone');
  });
});

describe('installSceneStateTagHandler', () => {
  it('routes # scene / # npc / # time / # weather / # speaker tags to the mirror', () => {
    const teardown = installSceneStateTagHandler();

    tagDispatcher.dispatch(parseTag('scene: workstation'));
    tagDispatcher.dispatch(parseTag('npc: lisa_at_desk_typing'));
    tagDispatcher.dispatch(parseTag('time: 9:14'));
    tagDispatcher.dispatch(parseTag('weather: rainy'));
    tagDispatcher.dispatch(parseTag('speaker: lisa'));

    expect(sceneState.get('scene')).toBe('workstation');
    expect(sceneState.get('npc')).toBe('lisa_at_desk_typing');
    expect(sceneState.get('time')).toBe('9:14');
    expect(sceneState.get('weather')).toBe('rainy');
    expect(sceneState.get('speaker')).toBe('lisa');

    teardown();
  });

  it('teardown stops further updates', () => {
    const teardown = installSceneStateTagHandler();
    tagDispatcher.dispatch(parseTag('scene: workstation'));
    teardown();
    tagDispatcher.dispatch(parseTag('scene: phone'));
    expect(sceneState.get('scene')).toBe('workstation'); // didn't update
  });

  it('does NOT route unrelated keys (e.g. # prop)', () => {
    const teardown = installSceneStateTagHandler();
    tagDispatcher.dispatch(parseTag('prop: fruit_bowl_apple'));
    expect(sceneState.get('scene')).toBeNull();
    expect(sceneState.get('npc')).toBeNull();
    teardown();
  });
});
