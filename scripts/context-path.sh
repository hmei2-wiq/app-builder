#!/usr/bin/env bash
# context-path.sh — resolve a durable context file (openspec/context/<name>.md)
# that may not be in that folder yet.
#
# Usage:
#   scripts/context-path.sh [--root DIR] [--move] <name>...
#
# Examples:
#   WEDGE=$(scripts/context-path.sh wedge)              # read
#   scripts/context-path.sh --move tech-stack           # before writing
#   scripts/context-path.sh tech-stack wedge product    # one path per line
#
# Lookup order, first existing file wins:
#   1. state/state.json .context_paths.<name>   (explicit override, any path)
#   2. openspec/context/<name>.md               (canonical)
#   3. the legacy docs/ name (docs/00-tech-stack.md, docs/01c-wedge.md, …)
#   4. docs/<name>.md
# A name with an extension (ux-demo.html) is used as the file name as is.
# Exit 0 and print the path found. If none exists, print the canonical path
# and exit 1, so callers can apply their own missing-file rule.
# --move: a file found at 3 or 4 is moved (git mv when tracked) to the
# canonical path first. Overrides (1) are never moved.

set -euo pipefail

ROOT="."
MOVE=0
NAMES=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) ROOT="$2"; shift 2 ;;
    --move) MOVE=1; shift ;;
    -h|--help) sed -n '2,23p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "Unknown flag: $1" >&2; exit 2 ;;
    *) NAMES+=("$1"); shift ;;
  esac
done
[[ ${#NAMES[@]} -gt 0 ]] || { echo "Usage: $0 [--root DIR] [--move] <name>..." >&2; exit 2; }

legacy() {
  case "$1" in
    tech-stack)       echo docs/00-tech-stack.md ;;
    product-analysis) echo docs/01-market-analysis.md; echo openspec/context/market-analysis.md ;;
    product)          echo docs/01b-product-context.md; echo docs/02-product-idea.md ;;
    wedge)            echo docs/01c-wedge.md ;;
    architecture)     echo docs/03-system-design.md; echo docs/04-system-design.md ;;
    ux-design)        echo docs/03b-ux-design.md ;;
    pricing)          echo docs/16-pricing.md ;;
    positioning)      echo docs/17-positioning.md ;;
    observability)    echo docs/11-observability.md ;;
    runbook)          echo docs/12-runbook.md ;;
    data-retention)   echo docs/13-data-retention-policy.md ;;
    environments)     echo docs/14-environment-guide.md ;;
    ux-demo.html)     echo docs/demo.html ;;
  esac
  [[ "$1" == *.* ]] && echo "docs/$1" || echo "docs/$1.md"
}

RC=0
for name in "${NAMES[@]}"; do
  canon="openspec/context/$name.md"; [[ "$name" == *.* ]] && canon="openspec/context/$name"
  over=""
  if [[ -f "$ROOT/state/state.json" ]] && command -v jq >/dev/null; then
    over=$(jq -r --arg n "$name" '.context_paths[$n] // empty' "$ROOT/state/state.json" 2>/dev/null || true)
  fi
  if [[ -n "$over" && -f "$ROOT/$over" ]]; then echo "$over"; continue; fi
  if [[ -f "$ROOT/$canon" ]]; then echo "$canon"; continue; fi
  found=""
  while read -r p; do
    [[ -f "$ROOT/$p" ]] && { found="$p"; break; }
  done < <(legacy "$name")
  if [[ -z "$found" ]]; then echo "$canon"; RC=1; continue; fi
  if [[ "$MOVE" -eq 1 ]]; then
    mkdir -p "$ROOT/openspec/context"
    if git -C "$ROOT" ls-files --error-unmatch "$found" >/dev/null 2>&1; then
      git -C "$ROOT" mv "$found" "$canon"
    else
      mv "$ROOT/$found" "$ROOT/$canon"
    fi
    echo "$canon"
  else
    echo "$found"
  fi
done
exit "$RC"
