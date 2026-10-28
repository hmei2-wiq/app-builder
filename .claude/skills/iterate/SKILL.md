---
name: iterate
description: Iterative Refinement — performs enhanced market re-analysis and gap analysis between the OpenSpec specs and the implementation, proposes one OpenSpec change (ADDED/MODIFIED/REMOVED deltas + tasks), implements it, runs full verification including the traceability gate, then archives the change into the specs. Can be invoked repeatedly.
argument-hint: "[focus area or specific aspect to investigate, optional]"
allowed-tools: WebSearch, WebFetch, Read, Write, Edit, Bash, Glob, Grep
effort: max
---

# Role: Product Iteration Engineer

You are running an iterative refinement cycle on an existing product. You will discover gaps between what was planned and what was built, find new market requirements, capture them as one OpenSpec change, implement it, verify everything with tests, and archive the change into the specs. This skill can be invoked multiple times — each run is one iteration.

**Focus area (optional):** $ARGUMENTS

---

## Setup — Determine Iteration Number

1. Check if `docs/06-iteration-log.md` exists.
   - If yes: read it, count existing iterations, this run is N+1.
   - If no: this is iteration 1. Create the file with a header.

---

## Phase 1 — Enhanced Market Re-Analysis

1. Read the current `docs/01-market-analysis.md`.
2. Use `WebSearch` and `WebFetch` to research:
   - New competitors or product launches since the original analysis
   - Updated market trends, pricing changes, regulatory changes
   - User feedback patterns for similar products (Reddit, Product Hunt, G2, forums)
   - If a focus area was provided, deep-dive into that specific aspect
3. Compare findings against the existing market analysis.
4. Append an **Iteration N Update** section to `docs/01-market-analysis.md`:
   ```
   ## Iteration N Update — [date]
   ### New Findings
   - ...
   ### Revised Competitive Position
   - ...
   ### New Opportunities
   - ...
   ### Updated Risks
   - ...
   ```

**Do not stop. Proceed immediately to Phase 2.**

---

## Phase 2 — Gap Analysis

Perform a systematic comparison between specifications and implementation.
Requirements live in OpenSpec (`openspec/specs/**`); conventions:
`.claude/skills/build-product-v2/openspec-conventions.md`.

```bash
export OPENSPEC_TELEMETRY=0 DO_NOT_TRACK=1 OPENSPEC_NO_UPDATE_CHECK=1
OPENSPEC="npx --yes @fission-ai/openspec@1.15.0"
```

### 2a. Requirements vs Implementation

1. `$OPENSPEC list --specs --json`, then `$OPENSPEC show <capability> --type spec --json` for each — extract every `FR-…` / `NFR-…` requirement with its priority and scenarios.
2. Run `scripts/spec-coverage.sh --no-write --json` for the test side of the picture.
3. Use `Glob` + `Grep` + `Read` to scan the actual codebase.
4. For each requirement, determine:
   - **Implemented**: code exists and a tagged test passes
   - **Partially implemented**: code exists but incomplete, or untested
   - **Missing**: no implementation found
   - **Divergent**: implemented differently than specified — decide which side is right (see 3b)

### 2b. Design vs Implementation

1. Read `docs/03-system-design.md`.
2. Check for deviations: missing API endpoints, different data models, architectural drift. Include `api-docs` orphan endpoints and open `OQ-` items from the last archived change.

### 2c. New Requirements from Market Update

1. From Phase 1 findings, derive new functional requirements that should be added.
2. Prioritize them (`M` for competitive parity on the wedge, `S`/`C` otherwise; out-of-wedge → `Wedge: v2`).

### 2d. Write Gap Analysis

Write `docs/06-gap-analysis.md` (create or update):

```markdown
# Gap Analysis — Iteration N

## Date: [date]

## Requirements Coverage Matrix

| Req ID | Priority | Status | Decision | Notes |
|--------|----------|--------|----------|-------|
| FR-NOM-05 | M | Implemented / Partial / Missing / Divergent | — / fix code / MODIFY spec / REMOVE | ... |

## Design Conformance Issues
- ...

## Proposed New Requirements
| Proposed ID | Requirement | Priority | Source |
|-------------|-------------|----------|--------|
| FR-NOM-12 | ... | M / S / C | Market update / Gap analysis |

## Summary
- Total requirements: X
- Implemented: X
- Partial: X
- Missing: X
- Divergent: X (fix code: X, modify spec: X)
- New requirements: X
- Priority items for this iteration: X
```

New IDs continue the capability's sequence (`FR-NOM-12` after `FR-NOM-11`); never reuse a retired ID.

**Do not stop. Proceed immediately to Phase 3.**

---

## Phase 3 — Propose the Change

Everything this iteration changes goes through one OpenSpec change. Do
not edit `openspec/specs/` directly.

### 3a. Open the change

```bash
CHANGE="iter-<N>-<slug>"          # slug from the focus area, e.g. iter-4-team-accounts
$OPENSPEC new change "$CHANGE"
scripts/state-set.sh '.active_change' "\"$CHANGE\""
```

Write the artifacts in order, running `$OPENSPEC instructions <artifact> --change "$CHANGE"` before each:

1. **`proposal.md`** — Why (market finding or gap, wedge sentence), What Changes, Capabilities (new + modified, exact paths from `openspec list --specs`), Impact.
2. **`specs/<capability>/spec.md`** — delta per capability:
   - **ADDED** — new requirements from 2c, with scenarios, `Priority`, `Wedge` and `Source: iter-N market|gap`.
   - **MODIFIED** — Divergent requirements where the code (or the market) is right: copy the whole existing block, then edit.
   - **REMOVED** — requirements the product no longer wants, with `**Reason**:` and `**Migration**:`.
   - **RENAMED** — only when a name is wrong; IDs stay.
3. **`design.md`** — only if architecture changes; reference and update `docs/03-system-design.md` sections. Unknowns → `## Open Questions` (`OQ-NN`).
4. **`tasks.md`** — conventions §5 format: Partial/Missing requirements (fix code) and every ADDED/MODIFIED requirement get tasks with `implements:` IDs.

### 3b. Validate

```bash
$OPENSPEC validate "$CHANGE" --strict --no-interactive
```

Fix and re-run until it passes. A `Priority: M` requirement with an open `OQ-` stops the iteration: ask the user (`AskUserQuestion`) before Phase 4.

If `docs/03-system-design.md` changes, edit it now and tag the edited sections `[Iteration N — <change>]`.

**Do not stop. Proceed immediately to Phase 4.**

---

## Phase 4 — Implementation (apply)

For each unticked task in `openspec/changes/$CHANGE/tasks.md`, in order:

```
LOOP:
  1. Implement the feature (write/edit source files)
  2. Write or update tests, titled `@<ID> › <scenario>` for every ID the task implements
  3. Run tests via Bash
  4. If tests fail:
       a. Read the failure output
       b. Identify root cause
       c. Fix the code or test
       d. Go to step 3
  5. If the implementation must differ from the delta: edit the delta (MODIFIED/ADDED),
     re-run `$OPENSPEC validate "$CHANGE" --strict`, then continue
  6. If tests pass: tick the task `- [x]` in tasks.md
  7. Move to next task
```

Do NOT move to the next task until the current task's tests pass.

**Do not stop. Proceed immediately to Phase 5.**

---

## Phase 5 — Full Verification

Run ALL quality checks, not just unit tests. Changes made during iteration may introduce security, performance, or E2E regressions.

### 5a. Unit + Integration + Smoke Tests
1. Run the **entire** test suite (unit + integration + smoke).
2. If any test fails: diagnose → fix → re-run until all green.
3. Run linting if configured.

### 5b. E2E Tests
1. Run Playwright E2E tests if they exist: `npx playwright test 2>/dev/null || true`.
2. If any E2E test fails due to new/changed features: update the test or fix the code.
3. If new features were added, write new E2E tests covering them.

### 5c. Security Re-Check
1. Run `npm audit` — fix any new Critical/High vulnerabilities introduced.
2. Use `Grep` to scan new/changed files for hardcoded secrets, SQL injection, XSS patterns.
3. Verify new API endpoints have auth middleware and input validation.

### 5d. Performance Spot-Check
1. Run `npm run build` — check for bundle size regressions.
2. Scan new database queries for N+1 patterns or missing indexes.
3. Verify new endpoints have pagination if returning lists.

### 5e. Spec gates
1. `scripts/quality-gates.sh --only spec-validate,traceability` — every `Priority: M` requirement (including this change's deltas) has a passing tagged test; no orphan tags.
2. Fix failures by the routing in `scripts/route-failure.sh`.

### 5f. Final Confirmation
1. Confirm 0 failures across all test types.
2. Confirm no Critical/High security issues introduced.
3. Confirm no major performance regressions.
4. Confirm every task in `tasks.md` is ticked.

### 5g. Archive the change
Only when 5a–5f are green:

```bash
$OPENSPEC archive "$CHANGE" --yes
scripts/state-set.sh '.active_change' 'null'
scripts/state-decide.sh iterate "archived $CHANGE" "<one-line summary of what became true>"
scripts/spec-coverage.sh          # refresh docs/11-traceability.md against the merged specs
```

Archive merges the deltas into `openspec/specs/` — this is the step that makes the change true. If archive reports a conflict (a MODIFIED header no longer matches), fix the delta, re-validate, and archive again.

---

## Phase 6 — Update Iteration Log

Append to `docs/06-iteration-log.md`:

```markdown
## Iteration N — [date]

### Market Findings
- [key new findings]

### Change
- `openspec/changes/archive/<date>-<change>/` — ADDED X, MODIFIED X, REMOVED X

### Gaps Addressed
- [list of gaps closed with their requirement IDs]

### New Features Implemented
- [list of new features with requirement and task IDs]

### Remaining Gaps
- [list of gaps deferred to next iteration]

### Test Results
- Unit: X passed, 0 failed
- Integration: X passed, 0 failed
- Smoke: X passed, 0 failed
- E2E: X passed, 0 failed
- Security: no new Critical/High issues
- Performance: no regressions
- Traceability: Must covered X/X (docs/11-traceability.md)

### Files Changed
- [list of key files added/modified]
```

## Git Commit & Push

```
git add .
git commit -m "feat: iteration N — [brief summary of key changes]"
git push origin HEAD 2>/dev/null || git push --set-upstream origin HEAD 2>/dev/null || true
```

---

## Completion

Print a summary:

```
## Iteration N Complete

- Market re-analysis:    ✅  [X new findings]
- Gap analysis:          ✅  [X gaps found, Y addressed]
- Change:                ✅  [change name] archived (+X ~Y -Z requirements)
- Implementation:        ✅  [X tasks completed]
- Test suite:            ✅  all passing
- Traceability:          ✅  Must covered X/X
- Remaining gaps:        [X items for next iteration]
```
