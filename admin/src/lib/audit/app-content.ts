// Server-side: turn the app content snapshot into audit items.
//
// One item per source file; long files are split into parts so each item
// stays a reviewable size. Every line keeps its source line number, so a
// finding can be traced to the exact place in the app's code.

import snapshot from './evidence/app-content-snapshot.json';
import { APP_CONTENT_AREAS, APP_SNAPSHOT_TABLE } from './app-areas';
import type { ExtractedContentArea, ExtractedContentItem } from './types';

interface SnapshotFile { path: string; group: string; strings: { line: number; text: string }[] }
interface Snapshot { generated_at: string; git_commit: string | null; file_count: number; string_count: number; files: SnapshotFile[] }

const SNAPSHOT = snapshot as unknown as Snapshot;
const MAX_ITEM_CHARS = 12000;

export function appSnapshotInfo() {
  return {
    generated_at: SNAPSHOT.generated_at,
    git_commit: SNAPSHOT.git_commit,
    file_count: SNAPSHOT.file_count,
    string_count: SNAPSHOT.string_count,
  };
}

/** All snapshot files, for the evidence scan. */
export function appSnapshotFiles(): SnapshotFile[] {
  return SNAPSHOT.files;
}

export function extractAppContentArea(areaId: string): ExtractedContentArea | null {
  const area = APP_CONTENT_AREAS.find(a => a.id === areaId);
  if (!area) return null;

  const items: ExtractedContentItem[] = [];
  for (const file of SNAPSHOT.files.filter(f => area.groups.includes(f.group))) {
    const parts: { line: number; text: string }[][] = [[]];
    let size = 0;
    for (const s of file.strings) {
      if (size + s.text.length > MAX_ITEM_CHARS && parts[parts.length - 1].length > 0) {
        parts.push([]);
        size = 0;
      }
      parts[parts.length - 1].push(s);
      size += s.text.length;
    }
    const name = file.path.split('/').pop() || file.path;
    parts.forEach((strings, i) => {
      const suffix = parts.length > 1 ? ` (part ${i + 1} of ${parts.length})` : '';
      items.push({
        id: `${file.path}#${i + 1}`,
        label: `${name}${suffix}`,
        source_table: APP_SNAPSHOT_TABLE,
        content_area: areaId,
        data: {
          file: file.path,
          lines: `${strings[0].line}-${strings[strings.length - 1].line}`,
          snapshot_commit: SNAPSHOT.git_commit,
          text: strings.map(s => `[L${s.line}] ${s.text}`).join('\n'),
        },
      });
    });
  }
  return { id: area.id, label: area.label, items };
}
