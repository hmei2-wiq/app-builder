#!/usr/bin/env bash
# spec-coverage.test.sh — asserts requirement ↔ test traceability rules on
# throwaway OpenSpec trees. Network-free. Run: scripts/test/spec-coverage.test.sh
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SC="$ROOT/scripts/spec-coverage.sh"
PASS=0; FAIL=0
ok()  { echo "  ✓ $1"; PASS=$((PASS+1)); }
bad() { echo "  ✗ $1 (got: $2)"; FAIL=$((FAIL+1)); }
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# req <id> <priority> -> one requirement block
req() {
  printf '### Requirement: %s Something\nThe system SHALL do %s.\n\nPriority: %s · Wedge: critical\n\n#### Scenario: Works\n- **WHEN** x\n- **THEN** y\n\n' "$1" "$1" "$2"
}
# project <name> -> fresh tree with a main spec holding FR-A-01 (M) and FR-A-02 (C)
project() {
  local d="$TMP/$1"
  mkdir -p "$d/openspec/specs/alpha" "$d/e2e"
  { echo "# alpha Specification"; echo; echo "## Purpose"; echo "Alpha capability used by the tests."; echo; echo "## Requirements"; echo
    req FR-A-01 M; req FR-A-02 C; } > "$d/openspec/specs/alpha/spec.md"
  echo "$d"
}
run() { bash "$SC" --root "$1" --json --no-write "${@:2}" 2>&1; }
state_of() { jq -r --arg id "$2" '.requirements[] | select(.id == $id) | .state' <<< "$1"; }

# A: no openspec/ dir is a skip, exit 0
mkdir -p "$TMP/none"
OUT="$(bash "$SC" --root "$TMP/none" 2>&1)"; RC=$?
[[ "$RC" -eq 0 ]] && grep -q "no openspec/" <<< "$OUT" && ok "no openspec/ → skip, exit 0" || bad "no openspec" "$RC $OUT"

# B: Must requirement without a test fails; Could without a test does not
B="$(project uncovered)"
OUT="$(run "$B")"; RC=$?
[[ "$RC" -ne 0 ]] && ok "uncovered Must fails" || bad "exit" "$RC"
[[ "$(state_of "$OUT" FR-A-01)" == "uncovered" ]] && ok "FR-A-01 is uncovered" || bad "FR-A-01" "$(state_of "$OUT" FR-A-01)"
[[ "$(state_of "$OUT" FR-A-02)" == "untested" ]] && ok "untested Could is reported, not failed" || bad "FR-A-02" "$(state_of "$OUT" FR-A-02)"

# C: tagged test covers it; skipped test does not
C="$(project tagged)"
echo "test('@FR-A-01 › Works', async () => {});" > "$C/e2e/alpha.spec.ts"
OUT="$(run "$C")"; RC=$?
[[ "$RC" -eq 0 ]] && ok "tagged Must passes (static)" || bad "exit" "$RC $(jq -c .failures <<< "$OUT")"
[[ "$(state_of "$OUT" FR-A-01)" == "tagged" ]] && ok "state is tagged without runner results" || bad "state" "$(state_of "$OUT" FR-A-01)"
echo "test.skip('@FR-A-01 › Works', async () => {});" > "$C/e2e/alpha.spec.ts"
OUT="$(run "$C")"; RC=$?
[[ "$RC" -ne 0 && "$(state_of "$OUT" FR-A-01)" == "uncovered" ]] && ok "test.skip does not count as coverage" || bad "skip" "$RC $(state_of "$OUT" FR-A-01)"

# D: orphan tag and REMOVED requirement
D="$(project orphan)"
mkdir -p "$D/openspec/changes/drop-a/specs/alpha"
printf '## REMOVED Requirements\n\n### Requirement: FR-A-02 Something\n**Reason**: gone\n**Migration**: none\n' > "$D/openspec/changes/drop-a/specs/alpha/spec.md"
printf "test('@FR-A-01 › Works', () => {});\ntest('@FR-A-02 › Old', () => {});\ntest('@FR-Z-09 › Typo', () => {});\n" > "$D/e2e/alpha.spec.ts"
OUT="$(run "$D")"; RC=$?
[[ "$RC" -ne 0 ]] && ok "orphan tags fail" || bad "exit" "$RC"
jq -e '.orphan_tags | map(.id) | index("FR-Z-09")' <<< "$OUT" >/dev/null && ok "unknown ID is an orphan" || bad "FR-Z-09" "$(jq -c .orphan_tags <<< "$OUT")"
jq -e '.orphan_tags | map(.id) | index("FR-A-02")' <<< "$OUT" >/dev/null && ok "tag on REMOVED requirement is an orphan" || bad "FR-A-02" "$(jq -c .orphan_tags <<< "$OUT")"
[[ -z "$(state_of "$OUT" FR-A-02)" ]] && ok "REMOVED requirement leaves the matrix" || bad "removed" "$(state_of "$OUT" FR-A-02)"

# E: ADDED delta in an active change counts; archive is ignored
E="$(project change)"
mkdir -p "$E/openspec/changes/add-b/specs/beta" "$E/openspec/changes/archive/2026-01-01-old/specs/alpha"
{ echo "## ADDED Requirements"; echo; req FR-B-01 M; } > "$E/openspec/changes/add-b/specs/beta/spec.md"
{ echo "## ADDED Requirements"; echo; req FR-OLD-01 M; } > "$E/openspec/changes/archive/2026-01-01-old/specs/alpha/spec.md"
echo "test('@FR-A-01 › Works', () => {});" > "$E/e2e/alpha.spec.ts"
OUT="$(run "$E")"; RC=$?
[[ "$(state_of "$OUT" FR-B-01)" == "uncovered" ]] && ok "active change ADDED requirement is traced" || bad "FR-B-01" "$(state_of "$OUT" FR-B-01)"
[[ -z "$(state_of "$OUT" FR-OLD-01)" ]] && ok "archived changes are ignored" || bad "archive" "$(state_of "$OUT" FR-OLD-01)"

# F: header without ID and missing Priority line both fail
F="$(project malformed)"
printf '### Requirement: No id here\nThe system SHALL x.\n\n#### Scenario: s\n- **WHEN** a\n- **THEN** b\n\n### Requirement: FR-A-03 No priority\nThe system SHALL y.\n\n#### Scenario: s\n- **WHEN** a\n- **THEN** b\n' >> "$F/openspec/specs/alpha/spec.md"
echo "test('@FR-A-01 @FR-A-03 › Works', () => {});" > "$F/e2e/alpha.spec.ts"
OUT="$(run "$F")"; RC=$?
jq -e '.unidentified | length == 1' <<< "$OUT" >/dev/null && ok "header without ID is reported" || bad "unidentified" "$(jq -c .unidentified <<< "$OUT")"
[[ "$(state_of "$OUT" FR-A-03)" == "no-priority" ]] && ok "missing Priority line is reported" || bad "FR-A-03" "$(state_of "$OUT" FR-A-03)"
[[ "$RC" -ne 0 ]] && ok "malformed spec fails" || bad "exit" "$RC"

# G: runner results — Playwright pass, Vitest fail
G="$(project results)"
echo "test('@FR-A-01 › Works', () => {});" > "$G/e2e/alpha.spec.ts"
mkdir -p "$G/reports/test-results"
echo '{"suites":[{"title":"alpha","specs":[{"title":"@FR-A-01 › Works","tests":[{"status":"expected"}]}]}]}' > "$G/reports/test-results/playwright.json"
OUT="$(run "$G")"; RC=$?
[[ "$RC" -eq 0 && "$(state_of "$OUT" FR-A-01)" == "passing" ]] && ok "Playwright pass → passing" || bad "pw" "$RC $(state_of "$OUT" FR-A-01)"
rm "$G/reports/test-results/playwright.json"
echo '{"testResults":[{"assertionResults":[{"title":"@FR-A-01 › Works","fullName":"alpha @FR-A-01 › Works","status":"failed"}]}]}' > "$G/reports/test-results/vitest.json"
OUT="$(run "$G")"; RC=$?
[[ "$RC" -ne 0 && "$(state_of "$OUT" FR-A-01)" == "not-passing" ]] && ok "Vitest fail → not-passing" || bad "vitest" "$RC $(state_of "$OUT" FR-A-01)"

# H: writes the report files
H="$(project write)"
echo "test('@FR-A-01 › Works', () => {});" > "$H/e2e/alpha.spec.ts"
bash "$SC" --root "$H" >/dev/null 2>&1
[[ -f "$H/state/artifacts/traceability.json" && -f "$H/docs/11-traceability.md" ]] && ok "writes traceability.json and docs/11-traceability.md" || bad "write" "$(ls "$H" "$H/docs" 2>&1)"
grep -q "| FR-A-01 | M | tagged |" "$H/docs/11-traceability.md" && ok "markdown matrix has the row" || bad "md" "$(cat "$H/docs/11-traceability.md")"

echo
echo "spec-coverage: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
