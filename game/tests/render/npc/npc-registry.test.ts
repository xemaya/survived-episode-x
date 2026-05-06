import { describe, expect, it } from 'vitest';
import { NPC_ALIASES, NPC_TABLE, parseNpcId } from '../../../src/render/npc/npc-registry';

describe('parseNpcId — extract NPC id from `# npc:` tag value', () => {
  it('parses bare id "lisa" → "lisa"', () => {
    expect(parseNpcId('lisa')).toBe('lisa');
  });

  it('parses "lisa_holding_milk_tea_cup" → "lisa"', () => {
    expect(parseNpcId('lisa_holding_milk_tea_cup')).toBe('lisa');
  });

  it('parses "lao_zhou_drinking_tea" → "lao_zhou"', () => {
    expect(parseNpcId('lao_zhou_drinking_tea')).toBe('lao_zhou');
  });

  it('parses "wang_director" with longest-prefix match', () => {
    expect(parseNpcId('wang_director')).toBe('wang_director');
  });

  it('parses "wang_director_walks_in" with state suffix', () => {
    expect(parseNpcId('wang_director_walks_in')).toBe('wang_director');
  });

  it('normalizes alias "food_court_auntie" → "cafeteria_auntie"', () => {
    expect(parseNpcId('food_court_auntie')).toBe('cafeteria_auntie');
  });

  it('normalizes alias "food_court_auntie_serving_lunch" → "cafeteria_auntie"', () => {
    expect(parseNpcId('food_court_auntie_serving_lunch')).toBe('cafeteria_auntie');
  });

  it('normalizes alias "lao_li" → "li_ayi"', () => {
    expect(parseNpcId('lao_li')).toBe('li_ayi');
  });

  it('normalizes alias "lao_li_mopping_background" → "li_ayi"', () => {
    expect(parseNpcId('lao_li_mopping_background')).toBe('li_ayi');
  });

  it('parses "it_xiaoma_back_at_machine" with full underscore id', () => {
    expect(parseNpcId('it_xiaoma_back_at_machine')).toBe('it_xiaoma');
  });

  it('parses "li_ayi_pushing_mop_cart" without falling into "li" prefix', () => {
    expect(parseNpcId('li_ayi_pushing_mop_cart')).toBe('li_ayi');
  });

  it('returns null for unknown ids', () => {
    expect(parseNpcId('mystery_man')).toBeNull();
  });

  it('returns null for empty string', () => {
    expect(parseNpcId('')).toBeNull();
  });

  it('returns null for whitespace', () => {
    expect(parseNpcId('   ')).toBeNull();
  });

  it('handles uppercase by normalizing', () => {
    expect(parseNpcId('Lisa_typing')).toBe('lisa');
  });
});

describe('NPC_TABLE / NPC_ALIASES schema', () => {
  it('all aliases map to a real NPC_TABLE entry', () => {
    for (const target of Object.values(NPC_ALIASES)) {
      expect(target in NPC_TABLE).toBe(true);
    }
  });

  it('all NPC_TABLE entries have a sprite URL pointing at sprites/npc/', () => {
    for (const config of Object.values(NPC_TABLE)) {
      expect(config.spriteUrl.startsWith('sprites/npc/')).toBe(true);
    }
  });

  it('all NPC_TABLE positions are within the 640x360 canvas', () => {
    for (const config of Object.values(NPC_TABLE)) {
      expect(config.x).toBeGreaterThanOrEqual(0);
      expect(config.x).toBeLessThanOrEqual(640);
      expect(config.y).toBeGreaterThanOrEqual(0);
      expect(config.y).toBeLessThanOrEqual(360);
    }
  });

  it('covers all 11 named NPCs (5 deep + 5 bit + S2 slots) per series-structure', () => {
    const expected = [
      'lisa',
      'david',
      'vivian',
      'wang_director',
      'lao_zhou',
      'zoe',
      'li_ayi',
      'mama',
      'lin_jie',
      'it_xiaoma',
      'cafeteria_auntie',
    ];
    for (const id of expected) {
      expect(id in NPC_TABLE).toBe(true);
    }
  });
});
