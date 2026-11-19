// Pull user-facing string literals out of Dart source.
//
// This is deliberately a small lexer rather than a regex: it understands
// comments, raw strings, triple-quoted strings, escapes and ${...}
// interpolation, and joins Dart's adjacent-literal concatenation
// ('a ' 'b' -> 'a b') so a sentence split over several lines comes out whole.
// Plain JavaScript (ESM) so both the Next.js admin and the Node CLI scripts
// can import it.

/** @typedef {{ line: number, text: string }} DartString */

/**
 * @param {string} src
 * @returns {DartString[]}
 */
export function extractDartStrings(src) {
  /** @type {{line:number,text:string,start:number,end:number}[]} */
  const raw = [];
  let i = 0;
  let line = 1;
  const n = src.length;

  while (i < n) {
    const c = src[i];
    if (c === '\n') { line++; i++; continue; }
    // Comments
    if (c === '/' && src[i + 1] === '/') {
      while (i < n && src[i] !== '\n') i++;
      continue;
    }
    if (c === '/' && src[i + 1] === '*') {
      i += 2;
      while (i < n && !(src[i] === '*' && src[i + 1] === '/')) { if (src[i] === '\n') line++; i++; }
      i += 2;
      continue;
    }
    // String literal (optionally raw)
    let isRaw = false;
    const start = i;
    if ((c === 'r') && (src[i + 1] === '"' || src[i + 1] === "'") && !/[A-Za-z0-9_]/.test(src[i - 1] || '')) {
      isRaw = true; i++;
    }
    const q = src[i];
    if (q === '"' || q === "'") {
      const triple = src[i + 1] === q && src[i + 2] === q;
      const startLine = line;
      i += triple ? 3 : 1;
      let text = '';
      while (i < n) {
        const ch = src[i];
        if (triple ? (ch === q && src[i + 1] === q && src[i + 2] === q) : ch === q) {
          i += triple ? 3 : 1;
          break;
        }
        if (!triple && ch === '\n') break; // unterminated; bail
        if (ch === '\n') line++;
        if (!isRaw && ch === '\\') {
          const nx = src[i + 1];
          text += nx === 'n' ? '\n' : nx === 't' ? ' ' : nx;
          i += 2;
          continue;
        }
        if (!isRaw && ch === '$' && src[i + 1] === '{') {
          // Skip interpolation body, keep a placeholder.
          let depth = 0;
          i++;
          do {
            if (src[i] === '{') depth++;
            else if (src[i] === '}') depth--;
            else if (src[i] === '\n') line++;
            i++;
          } while (i < n && depth > 0);
          text += '{…}';
          continue;
        }
        text += ch;
        i++;
      }
      raw.push({ line: startLine, text, start, end: i });
      continue;
    }
    if (isRaw) { i = start + 1; continue; }
    i++;
  }

  // Join adjacent literals separated only by whitespace (Dart concatenation).
  /** @type {DartString[]} */
  const joined = [];
  for (let k = 0; k < raw.length; k++) {
    const cur = { line: raw[k].line, text: raw[k].text };
    let end = raw[k].end;
    while (k + 1 < raw.length && /^\s*$/.test(src.slice(end, raw[k + 1].start))) {
      k++;
      cur.text += raw[k].text;
      end = raw[k].end;
    }
    joined.push(cur);
  }

  return joined
    .map(s => ({ line: s.line, text: s.text.replace(/[ \t]+/g, ' ').trim() }))
    .filter(s => isUserFacing(s.text));
}

const PHONE_LIKE = /(?:\+?\d[\d\s-]{6,}\d)/;
const URL_LIKE = /(?:https?:\/\/|www\.)[^\s]+|\b[a-z0-9-]+\.(?:org\.uk|nhs\.uk|gov\.uk|co\.uk|org|com|uk)\b/i;

/** Is this literal something a person reads (rather than a key, path or code)? */
export function isUserFacing(text) {
  if (!text || text.length < 3) return false;
  if (/^(package|dart):/.test(text)) return false;
  if (/^assets\//.test(text)) return false;
  if (/^[a-z0-9_.\-/]+$/.test(text) && !URL_LIKE.test(text)) return false; // keys, ids, paths
  if (/^#?[0-9A-Fa-f]{6,8}$/.test(text)) return false;
  if (PHONE_LIKE.test(text) || URL_LIKE.test(text)) return true;
  const words = text.split(/\s+/).filter(w => /[A-Za-z]/.test(w));
  return words.length >= 2 || /^[A-Z][a-z]+/.test(text);
}

/** Map a lib/ path to an audit group (one audit area per group). */
export function groupForFeature(path) {
  const m = path.match(/^lib\/features\/([^/]+)\//);
  if (m) return m[1];
  if (path.startsWith('lib/core/widgets/')) return 'shared_widgets';
  if (path.startsWith('lib/core/services/')) return 'core_services';
  return 'core';
}
