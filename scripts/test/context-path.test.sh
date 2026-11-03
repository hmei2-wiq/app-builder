#!/usr/bin/env bash
# context-path.test.sh — asserts context-file lookup order and --move on
# throwaway trees. Network-free. Run: scripts/test/context-path.test.sh
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CP="$ROOT/scripts/context-path.sh"
PASS=0; FAIL=0
ok()  { echo "  ✓ $1"; PASS=$((PASS+1)); }
bad() { echo "  ✗ $1 (got: $2)"; FAIL=$((FAIL+1)); }
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
run() { bash "$CP" --root "$@" 2>&1; }

# A: canonical file wins over legacy
A="$TMP/a"; mkdir -p "$A/openspec/context" "$A/docs"
touch "$A/openspec/context/wedge.md" "$A/docs/01c-wedge.md"
OUT="$(run "$A" wedge)"; RC=$?
[[ "$RC" -eq 0 && "$OUT" == "openspec/context/wedge.md" ]] && ok "canonical wins" || bad "canonical" "$RC $OUT"

# B: legacy docs/ name is found when canonical is missing
B="$TMP/b"; mkdir -p "$B/docs"; touch "$B/docs/00-tech-stack.md"
OUT="$(run "$B" tech-stack)"; RC=$?
[[ "$RC" -eq 0 && "$OUT" == "docs/00-tech-stack.md" ]] && ok "legacy fallback" || bad "legacy" "$RC $OUT"

# C: docs/<name>.md is found too
C="$TMP/c"; mkdir -p "$C/docs"; touch "$C/docs/pricing.md"
OUT="$(run "$C" pricing)"
[[ "$OUT" == "docs/pricing.md" ]] && ok "docs/<name>.md fallback" || bad "docs name" "$OUT"

# D: missing → canonical path, exit 1
D="$TMP/d"; mkdir -p "$D"
OUT="$(run "$D" architecture)"; RC=$?
[[ "$RC" -eq 1 && "$OUT" == "openspec/context/architecture.md" ]] && ok "missing → canonical, exit 1" || bad "missing" "$RC $OUT"

# E: state.json override beats everything and is never moved
E="$TMP/e"; mkdir -p "$E/state" "$E/notes" "$E/openspec/context"
touch "$E/notes/arch.md" "$E/openspec/context/architecture.md"
echo '{"context_paths":{"architecture":"notes/arch.md"}}' > "$E/state/state.json"
OUT="$(run "$E" --move architecture)"
[[ "$OUT" == "notes/arch.md" && -f "$E/notes/arch.md" ]] && ok "override wins, not moved" || bad "override" "$OUT"

# F: --move git-mvs a tracked legacy file to the canonical path
F="$TMP/f"; mkdir -p "$F/docs"; echo x > "$F/docs/01-market-analysis.md"
git -C "$F" init -q && git -C "$F" add . && git -C "$F" -c user.email=t@t -c user.name=t commit -qm init
OUT="$(run "$F" --move product-analysis)"
[[ "$OUT" == "openspec/context/product-analysis.md" && -f "$F/$OUT" && ! -e "$F/docs/01-market-analysis.md" ]] \
  && git -C "$F" status --short | grep -q '^R' && ok "--move renames tracked file" || bad "move" "$OUT $(git -C "$F" status --short)"

# G: several names, one line each; exit 1 if any is missing
OUT="$(run "$A" wedge architecture)"; RC=$?
[[ "$RC" -eq 1 && "$(wc -l <<< "$OUT")" -eq 2 ]] && ok "multiple names" || bad "multi" "$RC $OUT"

# H: extension names and the older docs/04 / demo.html layout
H="$TMP/h"; mkdir -p "$H/docs"; touch "$H/docs/demo.html" "$H/docs/04-system-design.md"
OUT="$(run "$H" ux-demo.html architecture)"
[[ "$OUT" == $'docs/demo.html\ndocs/04-system-design.md' ]] && ok "ux-demo.html and docs/04 fallback" || bad "ext" "$OUT"

echo "context-path: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
