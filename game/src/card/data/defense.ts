import type { Card } from '../card';

// 2026-05-04 design pivot: 6 placeholder cards removed.
//
// The original hand was a stub to prove the AP/KPI loop could turn cards
// into numbers. It worked, and that's the entire problem — the game became
// "abstract reverse-KPI sim with fake card content," and reading the
// hand-coded titles ("装作很忙", "划水", etc.) misled both author and any
// future reader into thinking these are the *designed* cards.
//
// Real cards will be authored alongside the events that surface them
// (per design/vertical-slice/month-1.md). Until those land, the action_day
// hand is intentionally empty: the workstation shows a placeholder hint
// ("（事件触发中… 按「下班」继续）") and the day-cycle still works via
// 「下班」 button.
//
// Card schema (../card.ts) and 7-step play sequence (../play.ts) are kept
// — they are the interaction primitives that future event choices will
// also flow through.
export const DEFENSE_CARDS_P2: ReadonlyArray<Card> = [];
