#!/usr/bin/env bash
# spec-coverage.sh — requirement ↔ test traceability for OpenSpec projects.
#
# Reads requirement headers from openspec/specs/**/spec.md and from the
# delta specs of active changes (openspec/changes/*/specs/**, archive
# excluded), then scans test files for @FR-…/@NFR-… tags. See
# .claude/skills/build-product-v2/openspec-conventions.md §3 and §6.
#
# Fails (exit 1) when:
#   - a requirement header has no FR-/NFR- ID, or no "Priority:" line
#   - a Priority: M requirement has no non-skipped tagged test
#   - a test tag names an ID that does not exist or was REMOVED
#   - runner JSON results exist and no tagged test of an M requirement passed
#
# Runner results (optional): Playwright / Vitest / Jest JSON reports in
# reports/test-results/*.json (override with --results a.json,b.json).
#
# Writes state/artifacts/traceability.json and docs/11-traceability.md
# unless --no-write. --json prints the JSON report to stdout.
#
#   scripts/spec-coverage.sh
#   scripts/spec-coverage.sh --json --no-write
#   scripts/spec-coverage.sh --root path/to/project --results reports/pw.json

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JSON=0
WRITE=1
RESULTS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)     ROOT="$(cd "$2" && pwd)"; shift 2;;
    --results)  RESULTS="$2"; shift 2;;
    --json)     JSON=1; shift;;
    --no-write) WRITE=0; shift;;
    -h|--help)  sed -n '2,24p' "$0"; exit 0;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done

cd "$ROOT"

if ! command -v jq >/dev/null; then
  echo "jq is required" >&2; exit 2
fi
if [[ ! -d openspec ]]; then
  echo "no openspec/ directory — nothing to trace"
  exit 0
fi

TAG_RE='@(FR|NFR)-[A-Z0-9]+-[0-9]+'
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# ---- 1. requirements: id \t priority \t status \t file ----
parse_spec() {
  awk -v file="$1" '
    function flush() {
      if (inreq) print id "\t" pri "\t" (sec == "" ? "active" : sec) "\t" file
      inreq = 0
    }
    /^## / {
      flush()
      if ($0 ~ /^## +REMOVED +Requirements/) sec = "removed"
      else if ($0 ~ /^## +((ADDED|MODIFIED|RENAMED) +)?Requirements/) sec = "active"
      else sec = "other"
      next
    }
    /^### +Requirement:/ {
      flush()
      if (sec == "other") next
      hdr = $0; sub(/^### +Requirement: */, "", hdr)
      if (match(hdr, /^(FR|NFR)-[A-Z0-9]+-[0-9]+/)) id = substr(hdr, RSTART, RLENGTH)
      else { id = "?" hdr; gsub(/\t/, " ", id) }
      pri = "?"; inreq = 1
      next
    }
    inreq && pri == "?" && match($0, /Priority: *[MSCW]/) { pri = substr($0, RSTART + RLENGTH - 1, 1) }
    END { flush() }
  ' "$1"
}

: > "$TMP/reqs.tsv"
# Main specs first, then active change deltas, so a change's row wins below.
while IFS= read -r f; do parse_spec "$f" >> "$TMP/reqs.tsv"; done \
  < <(find openspec/specs -name spec.md 2>/dev/null | sort)
while IFS= read -r f; do parse_spec "$f" >> "$TMP/reqs.tsv"; done \
  < <(find openspec/changes -path openspec/changes/archive -prune -o -path '*/specs/*' -name spec.md -print 2>/dev/null | sort)

# ---- 2. test tags: id \t file:line \t skipped(0|1) ----
: > "$TMP/tags.tsv"
while IFS= read -r f; do
  grep -nE "$TAG_RE" "$f" 2>/dev/null | while IFS= read -r hit; do
    lineno="${hit%%:*}"; text="${hit#*:}"
    skipped=0
    [[ "$text" =~ (\.skip\(|\.todo\(|\.fixme\(|xit\(|xtest\(|pytest\.mark\.skip) ]] && skipped=1
    grep -oE "$TAG_RE" <<< "$text" | sort -u | while read -r tag; do
      printf '%s\t%s:%s\t%s\n' "${tag#@}" "$f" "$lineno" "$skipped"
    done
  done
done < <(find . \( -name node_modules -o -name .git -o -name openspec -o -name docs \
                  -o -name dist -o -name build -o -name .next -o -name coverage -o -name reports \) -prune \
              -o -type f \( -name '*.spec.*' -o -name '*.test.*' -o -name 'test_*.py' -o -name '*_test.py' \
                  -o -name '*_test.go' -o -path '*/e2e/*' -o -path '*/perf/*' -o -path '*/evals/*' \) -print \
         | sed 's|^\./||' | sort) >> "$TMP/tags.tsv"

# ---- 3. runner results: title \t pass|skip|fail ----
: > "$TMP/results.tsv"
if [[ -n "$RESULTS" ]]; then
  IFS=',' read -ra RESULT_FILES <<< "$RESULTS"
else
  RESULT_FILES=()
  for f in reports/test-results/*.json; do [[ -f "$f" ]] && RESULT_FILES+=("$f"); done
fi
for f in "${RESULT_FILES[@]:-}"; do
  [[ -f "$f" ]] || continue
  jq -r '
    def norm: if . == "passed" or . == "expected" or . == "flaky" then "pass"
              elif . == "skipped" or . == "pending" or . == "todo" or . == "disabled" then "skip"
              else "fail" end;
    ( .. | objects | select(has("assertionResults")) | .assertionResults[]
        | [(.fullName // .title), (.status | norm)] ),
    ( .. | objects | select(has("specs")) | .specs[]
        | [.title, ([.tests[]?.status] as $s
                    | if any($s[]; . == "expected" or . == "flaky") then "pass"
                      elif ($s | length) > 0 and all($s[]; . == "skipped") then "skip"
                      else "fail" end)] )
    | @tsv' "$f" >> "$TMP/results.tsv" 2>/dev/null || echo "warn: could not parse $f" >&2
done
HAVE_RESULTS=0
[[ -s "$TMP/results.tsv" ]] && HAVE_RESULTS=1

# ---- 4. assemble ----
REPORT="$(jq -n \
  --rawfile reqs "$TMP/reqs.tsv" \
  --rawfile tags "$TMP/tags.tsv" \
  --rawfile results "$TMP/results.tsv" \
  --argjson have_results "$HAVE_RESULTS" '
  def rows($s): $s | split("\n") | map(select(length > 0) | split("\t"));

  (rows($reqs) | map({id: .[0], priority: .[1], status: .[2], file: .[3]})) as $raw
  | (rows($tags) | map({id: .[0], at: .[1], skipped: (.[2] == "1")})) as $tags
  | (rows($results) | map({title: .[0], result: .[1]})) as $results

  # A change row (later in the list) overrides the main spec row; REMOVED anywhere wins.
  | ($raw | map(select(.id | startswith("?") | not)) | group_by(.id)
      | map((last) + {status: (if any(.[]; .status == "removed") then "removed" else "active" end),
                      files: map(.file) | unique})) as $reqs
  | ($raw | map(select(.id | startswith("?"))) | map({header: .id[1:], file})) as $unidentified
  | ($reqs | map(select(.status == "active")) | map(.id)) as $live

  | ($reqs | map(select(.status == "active")) | map(
      . as $r
      | ($tags | map(select(.id == $r.id))) as $t
      | ($results | map(select(.title | test("@" + $r.id + "(?![0-9])")))) as $res
      | {id, priority, files,
         tests: ($t | map(.at)),
         live_tests: ($t | map(select(.skipped | not)) | length),
         passed: ($res | map(select(.result == "pass")) | length),
         ran: ($res | length)}
      | .state = (if .priority == "?" then "no-priority"
                  elif .live_tests == 0 then (if .priority == "M" then "uncovered" else "untested" end)
                  elif $have_results == 1 and .passed == 0 then (if .priority == "M" then "not-passing" else "untested" end)
                  elif $have_results == 1 then "passing"
                  else "tagged" end))) as $matrix

  | {
      generated_at: (now | todate),
      runner_results: ($have_results == 1),
      requirements: $matrix,
      unidentified: $unidentified,
      orphan_tags: ($tags | map(select(.id as $i | $live | index($i) | not))),
      summary: {
        total: ($matrix | length),
        must: ($matrix | map(select(.priority == "M")) | length),
        must_covered: ($matrix | map(select(.priority == "M" and (.state == "passing" or .state == "tagged"))) | length)
      }
    }
  | .failures = (
        (.requirements | map(select(.state == "uncovered" or .state == "not-passing" or .state == "no-priority"))
                       | map("\(.id): \(.state)"))
      + (.unidentified | map("requirement without FR-/NFR- ID: \"\(.header)\" (\(.file))"))
      + (.orphan_tags | map("tag @\(.id) at \(.at) names no live requirement")))
')"

if [[ "$WRITE" -eq 1 ]]; then
  mkdir -p state/artifacts docs
  echo "$REPORT" > state/artifacts/traceability.json
  {
    echo "# Requirements Traceability"
    echo
    echo "_Generated by \`scripts/spec-coverage.sh\` — do not edit by hand._"
    echo
    jq -r '"Must covered: \(.summary.must_covered)/\(.summary.must) · Requirements: \(.summary.total) · Runner results: \(if .runner_results then "yes" else "no (static scan only)" end)"' <<< "$REPORT"
    echo
    echo "| Requirement | Priority | State | Tests |"
    echo "|---|---|---|---|"
    jq -r '.requirements[] | "| \(.id) | \(.priority) | \(.state) | \(if (.tests | length) == 0 then "—" else (.tests | join("<br>")) end) |"' <<< "$REPORT"
    if [[ "$(jq '.failures | length' <<< "$REPORT")" -gt 0 ]]; then
      echo
      echo "## Failures"
      jq -r '.failures[] | "- \(.)"' <<< "$REPORT"
    fi
  } > docs/11-traceability.md
fi

if [[ "$JSON" -eq 1 ]]; then
  echo "$REPORT"
else
  jq -r '"spec-coverage: Must covered \(.summary.must_covered)/\(.summary.must), \(.summary.total) requirements, runner results: \(.runner_results)"' <<< "$REPORT"
  jq -r '.failures[] | "  ✗ \(.)"' <<< "$REPORT"
fi

[[ "$(jq '.failures | length' <<< "$REPORT")" -eq 0 ]]
