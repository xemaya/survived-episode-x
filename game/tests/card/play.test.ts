import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import type { Card, CardId } from '../../src/card/card';
import { type PlayCardContext, playCard } from '../../src/card/play';
import { ApSystem } from '../../src/economy/ap';
import { KpiSystem } from '../../src/economy/kpi';

const lookBusy: Card = {
  id: 'card_look_busy',
  apCost: 1,
  isHero: false,
  faceUrl: 'x.png',
  title: '装作很忙',
  effects: [{ kind: 'kpi_contribution', amount: 5 }],
};

const heroCard: Card = {
  id: 'card_hero',
  apCost: 2,
  isHero: true,
  faceUrl: 'x.png',
  title: '英雄主义',
  effects: [{ kind: 'kpi_contribution', amount: 10 }],
};

describe('playCard (P2: implements steps 1-3 of 7-step sequence)', () => {
  let ctx: PlayCardContext;
  let cardPlayed: ReturnType<typeof vi.fn>;
  let played: Set<CardId>;

  beforeEach(() => {
    cardPlayed = vi.fn();
    played = new Set();
    ctx = {
      ap: new ApSystem(),
      kpi: new KpiSystem(),
      onCardPlayed: cardPlayed,
      playedThisDay: played,
    };
  });

  afterEach(() => {
    cardPlayed.mockReset();
  });

  it('Step 1: emits onCardPlayed with the card id', () => {
    playCard(lookBusy, ctx);
    expect(cardPlayed).toHaveBeenCalledWith('card_look_busy');
  });

  it('Step 3: applies kpi_contribution from each effect', () => {
    playCard(lookBusy, ctx);
    expect(ctx.kpi.actualKpi).toBe(5);
  });

  it('AP is spent (Rule 6 pre-check baked into play)', () => {
    playCard(lookBusy, ctx);
    expect(ctx.ap.current).toBe(7); // 8 - 1
  });

  it('records the card in playedThisDay', () => {
    playCard(lookBusy, ctx);
    expect(played.has('card_look_busy')).toBe(true);
  });

  it('throws and does NOT mutate state if AP is insufficient', () => {
    ctx.ap.spend(8); // drain
    expect(() => playCard(lookBusy, ctx)).toThrow(/AP underflow|cannot afford/i);
    expect(ctx.kpi.actualKpi).toBe(0);
    expect(played.has('card_look_busy')).toBe(false);
  });

  it('throws if the card was already played today', () => {
    playCard(lookBusy, ctx);
    expect(() => playCard(lookBusy, ctx)).toThrow(/already played/i);
  });

  it('hero cards: emits onCardPlayed flag (Step 2 stub via emit; full hero accounting is P3+)', () => {
    playCard(heroCard, ctx);
    // P2 just records the play. P3 wires hero count into effort_norm.
    expect(cardPlayed).toHaveBeenCalledWith('card_hero');
    expect(ctx.kpi.actualKpi).toBe(10);
    expect(ctx.ap.current).toBe(6);
  });

  it('event ordering: onCardPlayed fires BEFORE kpi changes (per GDD step order)', () => {
    const order: string[] = [];
    ctx.onCardPlayed = () => order.push('emit');
    ctx.kpi.onChanged(() => order.push('kpi'));
    playCard(lookBusy, ctx);
    expect(order).toEqual(['emit', 'kpi']);
  });
});
