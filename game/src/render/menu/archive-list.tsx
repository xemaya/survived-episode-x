import { flow } from '@/flow/dispatcher';
import { removeFromArchive } from '@/run-meta/archive';
import { HR_EVALUATION_LIBRARY } from '@/run-meta/hr-evaluation';
import type { MetaState, RunSummary } from '@/save/schema';
import { save } from '@/save/system';
import { useEffect, useState } from 'preact/hooks';

const REASON_LABEL: Record<RunSummary['reason'], string> = {
  kpi_exceeds_capacity: '产能溢出',
  dismissal_severe: '严重低于预期',
};

export function ArchiveList(): preact.JSX.Element {
  const [meta, setMeta] = useState<MetaState | null>(null);

  useEffect(() => {
    void save.loadMeta().then(setMeta);
  }, []);

  const goBack = (): void => flow.request({ kind: 'main_menu' });

  const deleteEntry = async (runId: number): Promise<void> => {
    if (!meta) return;
    const next = removeFromArchive(meta, runId);
    await save.writeMeta(next);
    setMeta(next);
  };

  if (!meta) {
    return <div class="menu-root">载入档案中...</div>;
  }

  return (
    <div class="menu-root menu-root--archive">
      <h2 class="menu-title menu-title--small">归档目录 · 共 {meta.archive.length} 条</h2>
      {meta.archive.length === 0 ? (
        <p class="menu-subtitle">暂无归档记录</p>
      ) : (
        <ul class="archive-list">
          {meta.archive.map((entry) => (
            <li key={entry.runId} class="archive-row">
              <div class="archive-row-main">
                <span class="archive-runid">#{entry.runId}</span>
                <span class="archive-month">第 {entry.monthAtDeath} 月</span>
                <span class="archive-reason">{REASON_LABEL[entry.reason]}</span>
              </div>
              <p class="archive-eval">{HR_EVALUATION_LIBRARY[entry.hrEvaluationKey] ?? ''}</p>
              <button
                type="button"
                class="archive-delete"
                onClick={() => void deleteEntry(entry.runId)}
              >
                删除
              </button>
            </li>
          ))}
        </ul>
      )}
      {meta.hrWordLibrary.length > 0 && (
        <details class="archive-library">
          <summary>HR 词库 ({meta.hrWordLibrary.length} 项)</summary>
          <ul>
            {meta.hrWordLibrary.map((k) => (
              <li key={k}>{HR_EVALUATION_LIBRARY[k] ?? k}</li>
            ))}
          </ul>
        </details>
      )}
      <div class="menu-buttons">
        <button type="button" class="menu-button menu-button--primary" onClick={goBack}>
          回主菜单
        </button>
      </div>
    </div>
  );
}
