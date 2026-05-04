import type { Card } from '../card';

// 6 hand-coded placeholder defense cards for P2/P3. Card faces use real
// sprites from assets/sprites/cards/defense/. AP costs roughly follow
// GDD's 40/40/20 distribution (3×1 / 2×2 / 1×3 = 50/33/17, close enough
// for a 6-card placeholder hand). Total cost 10 AP > 8 budget so player
// must choose which cards to skip; multiple paths reach AP=0:
// e.g. 1+1+2+1+3 = 8, or 1+2+2+3 = 8, or 1+1+2+2 = 6 + early-leave.
//
// Full deck-level 40/40/20 lint will land when the full card library
// is authored (P4+) and the deck is large enough for distribution checks
// to be statistically meaningful.
export const DEFENSE_CARDS_P2: ReadonlyArray<Card> = [
  {
    id: 'card_pretend_busy',
    apCost: 1,
    isHero: false,
    faceUrl: 'sprites/cards/defense/look_busy.png',
    title: '装作很忙',
    effects: [{ kind: 'kpi_contribution', amount: 5 }],
  },
  {
    id: 'card_slack_off',
    apCost: 1,
    isHero: false,
    faceUrl: 'sprites/cards/defense/slack_off.png',
    title: '划水',
    effects: [{ kind: 'kpi_contribution', amount: 4 }],
  },
  {
    id: 'card_pretend_sleep',
    apCost: 1,
    isHero: false,
    faceUrl: 'sprites/cards/defense/pretend_sleep.png',
    title: '装睡',
    effects: [{ kind: 'kpi_contribution', amount: 6 }],
  },
  {
    id: 'card_dodge_meeting',
    apCost: 2,
    isHero: false,
    faceUrl: 'sprites/cards/defense/dodge_meeting.png',
    title: '躲开会议',
    effects: [{ kind: 'kpi_contribution', amount: 10 }],
  },
  {
    id: 'card_stall_meeting',
    apCost: 2,
    isHero: false,
    faceUrl: 'sprites/cards/defense/stall_meeting.png',
    title: '拖延会议',
    effects: [{ kind: 'kpi_contribution', amount: 11 }],
  },
  {
    id: 'card_call_in_sick',
    apCost: 3,
    isHero: true,
    faceUrl: 'sprites/cards/defense/call_in_sick.png',
    title: '请病假',
    effects: [{ kind: 'kpi_contribution', amount: 18 }],
  },
];
