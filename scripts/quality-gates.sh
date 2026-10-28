#!/usr/bin/env bash
# quality-gates.sh — layered hard quality gate runner for build-product-v2.
#
# Each gate is a separate hard pass. A gate failure exits non-zero with the
# gate name; the orchestrator uses the exit name to route the failure.
#
# Skips gates whose tooling is not present (logs SKIP, does not fail).
# Override which gates run with --only and --skip:
#
#   scripts/quality-gates.sh --only typecheck,unit
#   scripts/quality-gates.sh --skip mutation,visual
#
# Stop on first failure by default; --keep-going runs all gates and
# reports at the end.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# ---- argument parsing ----
ONLY=""
SKIP=""
KEEP_GOING=0
MUTATION_THRESHOLD="${MUTATION_THRESHOLD:-70}"
LIGHTHOUSE_PERF_BUDGET="${LIGHTHOUSE_PERF_BUDGET:-80}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)        ONLY="$2"; shift 2;;
    --skip)        SKIP="$2"; shift 2;;
    --keep-going)  KEEP_GOING=1; shift;;
    -h|--help)
      sed -n '2,12p' "$0"; exit 0;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done

# ---- gate registry (in dependency order) ----
GATES=(spec-validate typecheck lint seed-integrity unit mutation integration contract e2e traceability a11y lighthouse visual)

results=()         # "<gate>:<pass|fail|skip>:<reason>"
fail_count=0

# Helper: should we run this gate?
should_run() {
  local name="$1"
  if [[ -n "$ONLY" ]]; then
    [[ ",${ONLY}," == *",${name},"* ]] || return 1
  fi
  if [[ -n "$SKIP" ]]; then
    [[ ",${SKIP}," == *",${name},"* ]] && return 1
  fi
  return 0
}

summary() {
  echo
  echo "── Quality gates summary ──"
  for r in "${results[@]}"; do
    IFS=':' read -r name status reason <<< "$r"
    printf '  %-12s %-4s  %s\n' "$name" "$status" "$reason"
  done
  echo
  if [[ "$fail_count" -gt 0 ]]; then
    echo "RESULT: $fail_count gate(s) FAILED"
  else
    echo "RESULT: all gates pass"
  fi
}

record() {
  local name="$1" status="$2" reason="${3:-}"
  results+=("${name}:${status}:${reason}")
  case "$status" in
    pass) printf '  ✓ %-12s %s\n' "$name" "$reason";;
    fail) printf '  ✗ %-12s %s\n' "$name" "$reason"; ((fail_count++));;
    skip) printf '  · %-12s SKIP — %s\n' "$name" "$reason";;
  esac
  if [[ "$status" == "fail" && "$KEEP_GOING" -eq 0 ]]; then
    summary
    exit 1
  fi
}

run_gate() {
  local name="$1"
  shift
  if ! should_run "$name"; then
    record "$name" skip "filtered out"
    return 0
  fi
  mkdir -p ./reports/quality-gates
  if "$@" >./reports/quality-gates/"$name".log 2>&1; then
    record "$name" pass "ok"
  else
    record "$name" fail "see ./reports/quality-gates/$name.log"
  fi
}

# ---- gate implementations ----
gate_spec_validate() {
  # OpenSpec structure: every spec and active change parses and passes --strict.
  # Conventions: .claude/skills/build-product-v2/openspec-conventions.md
  if [[ ! -d openspec ]]; then
    echo "no openspec/ directory"; return 0
  fi
  OPENSPEC_TELEMETRY=0 DO_NOT_TRACK=1 OPENSPEC_NO_UPDATE_CHECK=1 \
    npx --yes "@fission-ai/openspec@${OPENSPEC_VERSION:-1.15.0}" validate --all --strict --no-interactive
}

gate_typecheck() {
  if [[ -f tsconfig.json ]]; then
    npx --yes tsc --noEmit
  elif command -v mypy >/dev/null && [[ -d src ]]; then
    mypy src
  else
    echo "no typechecker configured"; return 0
  fi
}

gate_lint() {
  if [[ -f .eslintrc.js || -f .eslintrc.json || -f eslint.config.js || -f eslint.config.mjs ]]; then
    npx --yes eslint . --max-warnings=0
  elif command -v ruff >/dev/null; then
    ruff check .
  else
    echo "no linter configured"; return 0
  fi
}

gate_seed_integrity() {
  # Verifies db-migrator's manifest against the filesystem and (optionally)
  # against a live database. Catches the "phantom artifact" failure mode
  # where the skill's decision-record claims a seed/migration/compose file
  # that was never actually written.
  #
  # Hard checks (always run):
  #   1. Every required entry in manifest.files exists on disk.
  #   2. Every entry in manifest.package_scripts has a key in package.json#scripts.
  #
  # Runtime checks (opt-in via SEED_INTEGRITY_RUNTIME=1, requires DATABASE_URL):
  #   3. boot_command runs cleanly.
  #   4. Each table in seed_expectations.tables has rows >= min_rows.
  #   5. Re-running seed_command leaves row counts unchanged (idempotency).

  local manifest="state/artifacts/db-migrator.json"
  if [[ ! -f "$manifest" ]]; then
    echo "no manifest at $manifest (db-migrator may not have run yet)"
    return 0   # treat as skip
  fi
  if ! command -v jq >/dev/null; then
    echo "jq not installed; cannot parse manifest"
    return 1
  fi

  # 1. File existence
  local missing_files=""
  while IFS=$'\t' read -r path kind min_entries; do
    [[ -z "$path" ]] && continue
    if [[ "$kind" == "dir" ]]; then
      if [[ ! -d "$path" ]]; then
        missing_files+="  - $path (dir)"$'\n'
      elif [[ -n "$min_entries" && "$min_entries" != "null" ]]; then
        local n
        n=$(find "$path" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')
        if [[ "$n" -lt "$min_entries" ]]; then
          missing_files+="  - $path: $n entries < min_entries=$min_entries"$'\n'
        fi
      fi
    else
      [[ -e "$path" ]] || missing_files+="  - $path"$'\n'
    fi
  done < <(jq -r '(.files // []) | map(select(.required != false))[] | [.path, (.kind // "file"), (.min_entries // "null")] | @tsv' "$manifest")

  if [[ -n "$missing_files" ]]; then
    echo "manifest claims files that do not exist:"
    echo "$missing_files"
    return 1
  fi

  # 2. package.json scripts
  if [[ -f package.json ]]; then
    local missing_scripts=""
    while read -r script; do
      [[ -z "$script" ]] && continue
      jq -e ".scripts.\"$script\"" package.json >/dev/null 2>&1 \
        || missing_scripts+="  - $script"$'\n'
    done < <(jq -r '(.package_scripts // [])[]' "$manifest")

    if [[ -n "$missing_scripts" ]]; then
      echo "manifest claims package.json scripts that do not exist:"
      echo "$missing_scripts"
      return 1
    fi
  fi

  # 3-5. Runtime checks (opt-in)
  if [[ "${SEED_INTEGRITY_RUNTIME:-0}" != "1" ]]; then
    echo "manifest valid (file/script existence). Set SEED_INTEGRITY_RUNTIME=1 with a live DATABASE_URL for full row-count + idempotency checks."
    return 0
  fi

  if [[ -z "${DATABASE_URL:-}" ]]; then
    echo "SEED_INTEGRITY_RUNTIME=1 requires DATABASE_URL"
    return 1
  fi
  if ! command -v psql >/dev/null; then
    echo "SEED_INTEGRITY_RUNTIME=1 requires psql on PATH"
    return 1
  fi

  # 3. boot_command
  local boot_cmd
  boot_cmd=$(jq -r '.boot_command // empty' "$manifest")
  if [[ -n "$boot_cmd" ]]; then
    echo "running boot_command: $boot_cmd"
    bash -c "$boot_cmd" || { echo "boot_command failed"; return 1; }
  fi

  # 4. Row count assertions
  local row_fail=""
  while IFS=$'\t' read -r name min query; do
    [[ -z "$name" ]] && continue
    [[ "$query" == "null" || -z "$query" ]] && query="SELECT COUNT(*) FROM \"$name\""
    local count
    count=$(psql "$DATABASE_URL" -tAc "$query" 2>/dev/null | tr -d ' ')
    [[ -z "$count" ]] && count=0
    if [[ "$count" -lt "$min" ]]; then
      row_fail+="  - $name: $count rows < manifest min_rows=$min"$'\n'
    fi
  done < <(jq -r '(.seed_expectations.tables // [])[] | [.name, (.min_rows | tostring), (.count_query // "null")] | @tsv' "$manifest")

  if [[ -n "$row_fail" ]]; then
    echo "seed produced fewer rows than manifest promises:"
    echo "$row_fail"
    return 1
  fi

  # 5. Idempotency
  local seed_cmd
  seed_cmd=$(jq -r '.seed_command // empty' "$manifest")
  if [[ -n "$seed_cmd" ]] && jq -e '.seed_expectations.idempotent == true' "$manifest" >/dev/null; then
    # Capture pre-rerun counts
    local pre_counts post_counts
    pre_counts=$(jq -r '(.seed_expectations.tables // [])[] | [.name, (.count_query // "null")] | @tsv' "$manifest" \
      | while IFS=$'\t' read -r name query; do
          [[ "$query" == "null" || -z "$query" ]] && query="SELECT COUNT(*) FROM \"$name\""
          printf '%s:%s\n' "$name" "$(psql "$DATABASE_URL" -tAc "$query" 2>/dev/null | tr -d ' ')"
        done)
    bash -c "$seed_cmd" || { echo "second seed_command run failed"; return 1; }
    post_counts=$(jq -r '(.seed_expectations.tables // [])[] | [.name, (.count_query // "null")] | @tsv' "$manifest" \
      | while IFS=$'\t' read -r name query; do
          [[ "$query" == "null" || -z "$query" ]] && query="SELECT COUNT(*) FROM \"$name\""
          printf '%s:%s\n' "$name" "$(psql "$DATABASE_URL" -tAc "$query" 2>/dev/null | tr -d ' ')"
        done)
    if [[ "$pre_counts" != "$post_counts" ]]; then
      echo "seed is not idempotent — row counts changed on second run"
      diff <(echo "$pre_counts") <(echo "$post_counts") || true
      return 1
    fi
  fi

  return 0
}

gate_unit() {
  if [[ -f vitest.config.ts || -f vitest.config.js ]]; then
    npx --yes vitest run --reporter=verbose
  elif [[ -f jest.config.js || -f jest.config.ts ]]; then
    npx --yes jest --ci
  elif [[ -f pyproject.toml ]] && grep -q pytest pyproject.toml; then
    pytest -q
  else
    npm test --silent || return 1
  fi
}

gate_mutation() {
  if [[ ! -f stryker.conf.js && ! -f stryker.conf.json && ! -f stryker.config.json ]]; then
    echo "stryker not configured"; return 0   # treat as skip
  fi
  npx --yes stryker run --maxConcurrentTestRunners=2
  # Parse score from reports/mutation/mutation.json if present.
  if [[ -f reports/mutation/mutation.json ]]; then
    local score
    score=$(node -e "
      const r = require('./reports/mutation/mutation.json');
      const f = r.metrics?.mutationScore ?? r.systemUnderTestMetrics?.metrics?.mutationScore;
      if (f === undefined) { console.error('no score'); process.exit(1); }
      console.log(Math.round(f));
    ")
    echo "mutation score: $score (threshold $MUTATION_THRESHOLD)"
    [[ "$score" -ge "$MUTATION_THRESHOLD" ]]
  fi
}

gate_integration() {
  if [[ -d tests/integration ]]; then
    npx --yes vitest run tests/integration --reporter=verbose
  elif [[ -d e2e ]] && grep -q '"test:integration"' package.json 2>/dev/null; then
    npm run test:integration
  else
    echo "no integration suite"; return 0
  fi
}

gate_contract() {
  if [[ -f openapi.yaml ]]; then
    # Validate OpenAPI spec parses
    npx --yes @redocly/cli lint openapi.yaml
    # If a contract test runner is wired, run it
    if grep -q '"test:contract"' package.json 2>/dev/null; then
      npm run test:contract
    fi
  else
    echo "no openapi.yaml"; return 0
  fi
}

gate_e2e() {
  if [[ -f playwright.config.ts || -f playwright.config.js ]]; then
    npx --yes playwright test
  else
    echo "no playwright config"; return 0
  fi
}

gate_traceability() {
  # Every Priority: M requirement has a passing (or, without runner JSON,
  # a non-skipped) test tagged @<ID>; no tag names a missing requirement.
  if [[ ! -d openspec ]]; then
    echo "no openspec/ directory"; return 0
  fi
  bash "$ROOT/scripts/spec-coverage.sh"
}

gate_a11y() {
  # Standalone axe-core run if a script is wired; otherwise rely on
  # @axe-core/playwright assertions inside the e2e suite.
  if grep -q '"test:a11y"' package.json 2>/dev/null; then
    npm run test:a11y
  else
    echo "no a11y script (covered by e2e if @axe-core/playwright is used)"; return 0
  fi
}

gate_lighthouse() {
  if ! command -v npx >/dev/null; then return 0; fi
  if [[ -z "${LIGHTHOUSE_URL:-}" ]]; then
    echo "LIGHTHOUSE_URL unset"; return 0
  fi
  npx --yes lighthouse "$LIGHTHOUSE_URL" \
    --output=json --output-path=./reports/lighthouse.json --quiet \
    --chrome-flags='--headless=new --no-sandbox'
  local perf
  perf=$(node -e "console.log(Math.round(require('./reports/lighthouse.json').categories.performance.score * 100))")
  echo "lighthouse perf: $perf (budget $LIGHTHOUSE_PERF_BUDGET)"
  [[ "$perf" -ge "$LIGHTHOUSE_PERF_BUDGET" ]]
}

gate_visual() {
  if grep -q '"test:visual"' package.json 2>/dev/null; then
    npm run test:visual
  else
    echo "no visual regression script"; return 0
  fi
}

# ---- run ----
echo "Quality gates — root: $ROOT"
echo "  only=${ONLY:-<all>}  skip=${SKIP:-<none>}  keep_going=$KEEP_GOING"
echo

for g in "${GATES[@]}"; do
  case "$g" in
    spec-validate)   run_gate "$g" gate_spec_validate;;
    typecheck)       run_gate "$g" gate_typecheck;;
    lint)            run_gate "$g" gate_lint;;
    seed-integrity)  run_gate "$g" gate_seed_integrity;;
    unit)            run_gate "$g" gate_unit;;
    mutation)    run_gate "$g" gate_mutation;;
    integration) run_gate "$g" gate_integration;;
    contract)    run_gate "$g" gate_contract;;
    e2e)         run_gate "$g" gate_e2e;;
    traceability) run_gate "$g" gate_traceability;;
    a11y)        run_gate "$g" gate_a11y;;
    lighthouse)  run_gate "$g" gate_lighthouse;;
    visual)      run_gate "$g" gate_visual;;
  esac
done

summary
exit "$fail_count"
