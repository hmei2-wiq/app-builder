#!/usr/bin/env bash
# quality-gates.test.sh — asserts gates without tooling are SKIP (never PASS)
# and that root package.json scripts decide how a gate runs. Network-free:
# runs a copy of the script inside throwaway project trees.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PASS=0; FAIL=0
ok()  { echo "  ✓ $1"; PASS=$((PASS+1)); }
bad() { echo "  ✗ $1 (got: $2)"; FAIL=$((FAIL+1)); }
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# project <name> <package.json or ""> -> path of a tree with the script copied in
project() {
  local d="$TMP/$1"
  mkdir -p "$d/scripts"
  cp "$ROOT/scripts/quality-gates.sh" "$d/scripts/"
  [[ -n "$2" ]] && echo "$2" > "$d/package.json"
  echo "$d"
}
line() { grep -E "^  $2 +(pass|fail|skip) " <<< "$1" | awk '{print $2}'; }

# Scenario A: empty project. Every gate is skipped, nothing passes, exit 0.
A="$(project empty "")"
OUT="$(bash "$A/scripts/quality-gates.sh" --keep-going 2>&1)"; RC=$?
[[ "$RC" -eq 0 ]] && ok "empty project exits 0" || bad "exit" "$RC"
for g in typecheck lint seed-integrity unit integration contract e2e a11y lighthouse visual mutation; do
  [[ "$(line "$OUT" "$g")" == "skip" ]] && ok "$g is skip without tooling" || bad "$g" "$(line "$OUT" "$g")"
done
grep -q "SKIP — no typechecker configured" <<< "$OUT" && ok "skip reason is shown" || bad "reason" "$OUT"
grep -q "RESULT: all gates pass (11 skipped)" <<< "$OUT" && ok "summary counts skips" || bad "summary" "$(grep RESULT <<< "$OUT")"

# Scenario B: package.json scripts decide. Passing and failing scripts map to pass/fail.
B="$(project scripts '{"scripts":{"typecheck":"true","lint":"exit 1","test:unit":"true","test:integration":"true","test:contract":"true","test:e2e":"true","test:a11y":"exit 1","test:visual":"true","mutation":"true","test:lighthouse":"true"}}')"
OUT="$(bash "$B/scripts/quality-gates.sh" --keep-going --skip seed-integrity 2>&1)"; RC=$?
for g in typecheck unit integration contract e2e visual mutation lighthouse; do
  [[ "$(line "$OUT" "$g")" == "pass" ]] && ok "$g runs its npm script" || bad "$g" "$(line "$OUT" "$g")"
done
[[ "$(line "$OUT" lint)" == "fail" ]] && ok "failing lint script fails the gate" || bad "lint" "$(line "$OUT" lint)"
[[ "$(line "$OUT" a11y)" == "fail" ]] && ok "failing a11y script fails the gate" || bad "a11y" "$(line "$OUT" a11y)"
[[ "$RC" -eq 2 ]] && ok "exit code = failed gate count (2)" || bad "exit" "$RC"

# Scenario C: stop on first failure without --keep-going.
OUT="$(bash "$B/scripts/quality-gates.sh" --skip seed-integrity 2>&1)"; RC=$?
[[ "$RC" -eq 1 ]] && ok "stops on first failure" || bad "exit" "$RC"
[[ -z "$(line "$OUT" e2e)" ]] && ok "later gates do not run" || bad "e2e ran" "$(line "$OUT" e2e)"

echo
echo "quality-gates: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
