import { describe, expect, it } from 'vitest';
import { SCENE_BG_TABLE } from '../../../src/render/scene/scene-registry';

describe('SCENE_BG_TABLE (T-1)', () => {
  it('covers all spec scene ids (workstation + tea_room + meeting_room + endgame)', () => {
    const required = [
      'workstation',
      'break_room',
      'tea_room',
      'cafeteria',
      'meeting_room',
      'hallway',
      'reception',
      'boss_office',
      'monitor_modal',
      'endgame',
      'home_phone',
    ];
    for (const id of required) {
      expect(id in SCENE_BG_TABLE).toBe(true);
    }
  });

  it('every entry has a sprites/backgrounds/ URL (asset-path invariant)', () => {
    for (const spec of Object.values(SCENE_BG_TABLE)) {
      expect(spec.url.startsWith('sprites/backgrounds/')).toBe(true);
    }
  });

  it('break_room and tea_room share the same BG (alias)', () => {
    expect(SCENE_BG_TABLE.break_room?.url).toBe(SCENE_BG_TABLE.tea_room?.url);
  });

  it('home_phone and endgame share the same BG (kitchen/home pairing)', () => {
    expect(SCENE_BG_TABLE.home_phone?.url).toBe(SCENE_BG_TABLE.endgame?.url);
  });

  it('hallway and reception share the same BG (entry pairing)', () => {
    expect(SCENE_BG_TABLE.hallway?.url).toBe(SCENE_BG_TABLE.reception?.url);
  });
});
