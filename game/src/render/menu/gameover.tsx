import { flow } from '@/flow/dispatcher';
import type { GameOverReason } from '@/flow/scene-state';

interface Props {
  reason: GameOverReason;
  monthIndex: number;
}

// design/gdd/kpi-review-game-over-ui.md: ironic dismissal certificate.
// "恭喜晋升" stamp on every variant (anti-励志 lint whitelist). Body
// copy varies by reason. Click anywhere → main_menu (P3 skips Archive
// flow — P4 adds it alongside save persistence).

const REASON_BODY: Record<GameOverReason, string> = {
  kpi_exceeds_capacity: '本月 KPI 阈值已超出承担能力上限。\n经评议，您的产出潜力已饱和。',
  dismissal_severe: '本月绩效大幅低于预期阈值。\n经评议，您的岗位适配度已不达标。',
};

export function GameOver({ reason, monthIndex }: Props): preact.JSX.Element {
  const goToMainMenu = (): void => {
    flow.request({ kind: 'main_menu' });
  };

  return (
    <button
      class="menu-root menu-root--gameover"
      onClick={goToMainMenu}
      style={{ cursor: 'pointer' }}
      type="button"
    >
      <h2 class="menu-title menu-title--small">解除劳动合同通知</h2>
      <div class="gameover-body">
        <p class="gameover-month">第 {monthIndex} 个工作月</p>
        <p class="gameover-reason">{REASON_BODY[reason]}</p>
        <p class="gameover-stamp">恭喜晋升</p>
      </div>
      <p class="recap-hint">点击任意位置回到主菜单</p>
    </button>
  );
}
