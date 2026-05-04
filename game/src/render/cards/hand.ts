import { type Card, evaluateCardState } from '@/card/card';
import { DEFENSE_CARDS_P2 } from '@/card/data/defense';
import { playCard, playedThisDay } from '@/card/play';
import { ap } from '@/economy/ap';
import { type Application, Assets, Container, Graphics, Sprite, Text } from 'pixi.js';

// Card visual constants. All hand-tuned for the 640×360 logical canvas.
const CARD_W = 80;
const CARD_H = 110;
const CARD_GAP = 8;
const CARD_Y = 360 - CARD_H / 2 - 12; // 12px from canvas bottom
const CARD_BG_IDLE = 0x1a1d22;
const CARD_BG_DISABLED = 0x101113;
const CARD_BG_PLAYED = 0x080a0c;
const CARD_BORDER_IDLE = 0xc8a85a;
const CARD_BORDER_DISABLED = 0x3a3d42;
const CARD_BORDER_HOVER = 0xe0b050;

interface CardView {
  card: Card;
  container: Container;
  bg: Graphics;
  face: Sprite;
  apLabel: Text;
  titleLabel: Text;
}

export interface HandHandles {
  container: Container;
  destroy: () => void;
  redraw: () => void;
}

export async function mountCardHand(parent: Container, _app: Application): Promise<HandHandles> {
  const container = new Container();
  container.label = 'card-hand';
  parent.addChild(container);

  const totalWidth = DEFENSE_CARDS_P2.length * CARD_W + (DEFENSE_CARDS_P2.length - 1) * CARD_GAP;
  const startX = (640 - totalWidth) / 2 + CARD_W / 2;

  const views: CardView[] = [];

  for (const [i, card] of DEFENSE_CARDS_P2.entries()) {
    const view = await createCardView(card);
    view.container.x = startX + i * (CARD_W + CARD_GAP);
    view.container.y = CARD_Y;
    container.addChild(view.container);
    views.push(view);
  }

  const redraw = () => {
    for (const view of views) {
      const state = evaluateCardState(view.card, ap.current, playedThisDay.has(view.card.id));
      paintCardForState(view, state);
    }
  };

  // Subscribe to AP changes so disabled state updates as player spends.
  // KPI changes don't affect card state but UI may want to re-render
  // anyway; redraw is cheap.
  const unsubAp = ap.onChanged(() => redraw());

  redraw();

  const destroy = () => {
    unsubAp();
    container.destroy({ children: true });
  };

  return { container, destroy, redraw };
}

async function createCardView(card: Card): Promise<CardView> {
  const c = new Container();
  c.label = `card-${card.id}`;
  c.eventMode = 'static';
  c.cursor = 'pointer';

  const bg = new Graphics();
  c.addChild(bg);

  const tex = await Assets.load(card.faceUrl);
  tex.source.scaleMode = 'linear';
  const face = new Sprite(tex);
  face.anchor.set(0.5);
  face.x = 0;
  face.y = -10;
  // Source is 1024×1024; fit into ~CARD_W-12 inside the card.
  const targetW = CARD_W - 12;
  face.scale.set(targetW / tex.width);
  c.addChild(face);

  const apLabel = new Text({
    text: String(card.apCost),
    style: {
      fontFamily: 'PingFang SC, -apple-system, sans-serif',
      fontSize: 16,
      fill: 0xc8a85a,
      fontWeight: '700',
    },
  });
  apLabel.anchor.set(0.5);
  apLabel.x = -CARD_W / 2 + 12;
  apLabel.y = -CARD_H / 2 + 12;
  c.addChild(apLabel);

  const titleLabel = new Text({
    text: card.title,
    style: {
      fontFamily: 'PingFang SC, -apple-system, sans-serif',
      fontSize: 11,
      fill: 0xe8e0cc,
      align: 'center',
    },
  });
  titleLabel.anchor.set(0.5);
  titleLabel.x = 0;
  titleLabel.y = CARD_H / 2 - 14;
  c.addChild(titleLabel);

  // Hover feedback
  c.on('pointerover', () => {
    if (c.eventMode === 'static') paintHover(bg, true);
  });
  c.on('pointerout', () => {
    paintHover(bg, false);
  });
  // Click → play card. Wrapped in try so disabled-card clicks throw cleanly.
  c.on('pointertap', () => {
    try {
      playCard(card);
    } catch (err) {
      console.warn('[card] play rejected:', (err as Error).message);
    }
  });

  return { card, container: c, bg, face, apLabel, titleLabel };
}

function paintCardForState(view: CardView, state: ReturnType<typeof evaluateCardState>): void {
  const { container, bg, face } = view;
  const interactive = state === 'IDLE';
  container.eventMode = interactive ? 'static' : 'none';
  container.cursor = interactive ? 'pointer' : 'default';
  face.alpha = state === 'DISABLED' || state === 'PLAYED' ? 0.35 : 1;
  bg.clear();
  const fill =
    state === 'PLAYED' ? CARD_BG_PLAYED : state === 'DISABLED' ? CARD_BG_DISABLED : CARD_BG_IDLE;
  const border = state === 'IDLE' ? CARD_BORDER_IDLE : CARD_BORDER_DISABLED;
  bg.rect(-CARD_W / 2, -CARD_H / 2, CARD_W, CARD_H);
  bg.fill(fill);
  bg.stroke({ color: border, width: 2 });
}

function paintHover(bg: Graphics, hovering: boolean): void {
  // Hover-only border accent; only draws on top of an existing IDLE bg.
  // We don't redraw the bg here because state-driven paintCardForState
  // already wrote it; we just append a thin border highlight.
  bg.stroke({ color: hovering ? CARD_BORDER_HOVER : CARD_BORDER_IDLE, width: 2 });
}
