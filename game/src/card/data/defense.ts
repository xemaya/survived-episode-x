import type { Card } from '../card';

// 4 hand-coded placeholder defense cards for P2. Card faces use real
// sprites from assets/sprites/cards/defense/ (provided by parallel
// art-gen session). AP costs distributed 2/1/1 across {1,2,3} for the
// hand of 4 — full deck-level 40/40/20 distribution will land when the
// full card library is authored (P3+).
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
    id: 'card_dodge_meeting',
    apCost: 2,
    isHero: false,
    faceUrl: 'sprites/cards/defense/dodge_meeting.png',
    title: '躲开会议',
    effects: [{ kind: 'kpi_contribution', amount: 10 }],
  },
  {
    id: 'card_call_in_sick',
    apCost: 3,
    isHero: false,
    faceUrl: 'sprites/cards/defense/call_in_sick.png',
    title: '请病假',
    effects: [{ kind: 'kpi_contribution', amount: 18 }],
  },
  {
    id: 'card_slack_off',
    apCost: 1,
    isHero: false,
    faceUrl: 'sprites/cards/defense/slack_off.png',
    title: '划水',
    effects: [{ kind: 'kpi_contribution', amount: 4 }],
  },
];
