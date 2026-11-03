# OpenSpec conventions for build-product skills

Every skill that reads or writes requirements, tasks or tests follows
this file. It is the single source for the spec-driven development
(SDD) rules of the pipeline. Skills reference it as
`.claude/skills/build-product-v2/openspec-conventions.md`.

The pipeline is **spec-anchored**: specs live on after a change ships
and are updated through change proposals, never by hand-editing code
to drift away from them.

---

## 1. Where things live

**One fact, one home.** Behaviour lives in OpenSpec; everything made
for one change lives in that change's folder; `openspec/context/`
keeps only durable, non-behaviour context that OpenSpec has no
artifact for (OpenSpec ignores the folder; `config.yaml` `context`
points at it). Context files are kebab-case with no number prefix,
like the rest of OpenSpec. A skill that needs a fact another artifact owns links to it — it does
not copy it.

**Context files may live elsewhere.** `openspec/context/` is where
skills write; it is not a precondition for reading. Resolve every
context file with `scripts/context-path.sh <name>` and use the path it
prints. It checks, in order: a `state/state.json` `.context_paths.<name>`
override (any path, never moved), `openspec/context/<name>.md`, the
legacy `docs/` name from the "Moved" list below, then `docs/<name>.md`.
Exit 1 means none exists; it prints the canonical path, and the
skill's own missing-file rule applies. Before writing a context file,
run `scripts/context-path.sh --move <name>`: a legacy file is moved
(`git mv`) to the canonical path, so it is updated, not duplicated. An
override path is written in place.

| Kind | Artifact | Location | Owner |
|---|---|---|---|
| Principles | Tech-stack contract | `openspec/context/tech-stack.md` | `tech-stack-selector` |
| | Wedge, ICP, tier, stack flags, kill switches | `openspec/context/wedge.md` | `differentiation` |
| Product context | Market | `openspec/context/product-analysis.md` | `ceo` (`iterate` appends updates) |
| | Vision, personas, product KPIs, assumptions | `openspec/context/product.md` | `product-spec`, `spec-ingest` |
| | Pricing, positioning | `openspec/context/pricing.md`, `openspec/context/positioning.md` | `pricing`, `positioning` |
| Current system | Architecture (current state, no rationale) | `openspec/context/architecture.md` | `designer`; kept true by `[docs]` tasks |
| | UX | Figma + `openspec/context/ux-design.md` | `ux-designer` |
| | HTTP API contract | `openapi.yaml` | `api-docs` |
| | Ops docs (launch+) | `openspec/context/observability.md`, `openspec/context/runbook.md`, `openspec/context/data-retention.md`, `openspec/context/environments.md` | ops skills |
| Human quickstart | Fresh clone → running app | `docs/RUN.md` (the only file the pipeline writes to `docs/`) | orchestrator Phase 19a |
| **Behaviour (source of truth)** | Requirements + scenarios | `openspec/specs/<capability>/spec.md` | **only** `openspec archive` |
| **Change** | Folder | `openspec/changes/<change>/` | the skill running the change |
| | ├ why, stories, scope, non-goals, capabilities, success metric | `proposal.md` (§5) | `product-spec`, `iterate`, `signal-iterate`, `spec-ingest` |
| | ├ requirement deltas | `specs/<capability>/spec.md` | `analyst`, `spec-ingest`, `iterate`, `signal-iterate` |
| | ├ decisions, alternatives, risks, stack gaps, open questions | `design.md` | `designer` (+ `analyst`/`product-spec` for `OQ-`s) |
| | ├ implementation checklist | `tasks.md` (§6) | `designer`, `iterate`, `signal-iterate` |
| | └ evidence for this change | `reports/<name>.md` (below) | the skill that produced it |
| History | Every shipped change, with its evidence | `openspec/changes/archive/YYYY-MM-DD-<change>/` | `openspec archive` |
| Generated | Traceability (current) | `reports/traceability.md`, `state/artifacts/traceability.json` | `scripts/spec-coverage.sh` |

Change reports (`openspec/changes/<change>/reports/`; OpenSpec ignores
the folder and archives it with the change):

| Report | Producer |
|---|---|
| `ingest.md` | `spec-ingest` |
| `gap-analysis.md`, `verification.md` | `iterate` |
| `signals-behavior.md`, `signals-failure.md`, `signals-voice.md` | `signal-iterate` |
| `e2e.md` | `e2e-tester` |
| `adversarial.md` | `adversarial-tester` |
| `security-audit.md` | `security-auditor` |
| `dogfood-<run>.md` (screenshots stay in `dogfood/`) | `dogfood` |
| `performance.md` | `perf-tester` |
| `code-review.md` | `reviewer` |
| `production-readiness.md` | `production-readiness` |
| `traceability.md` (snapshot at archive) | orchestrator / `iterate` / `signal-iterate` |

Resolve the report folder like this; with no active change (a skill
run by hand after archive), reports go to the generated `reports/`
folder instead:

```bash
CHANGE=$(jq -r '.active_change // empty' state/state.json 2>/dev/null)
REPORTS="${CHANGE:+openspec/changes/$CHANGE/reports}"; REPORTS="${REPORTS:-reports}"
mkdir -p "$REPORTS"
```

Reports cite requirement IDs and link to specs, `tasks.md` and
`reports/traceability.md`; they never restate requirement text or the
coverage matrix.

**Retired — do not create:** `docs/02-system-requirements.md` (→
`openspec/specs/**`), `docs/04-dev-plan.md` (→ `tasks.md`),
`docs/01b-product-spec.md` (→ `openspec/context/product.md` + `proposal.md`),
`docs/06-iteration-log.md` (→ `openspec/changes/archive/`),
`docs/06-gap-analysis.md`, `docs/iteration-N/`, `docs/dogfood/`,
`docs/05-code-review.md`, `docs/08-e2e-test-report.md`,
`docs/08b-adversarial-test-plan.md`, `docs/09-security-audit.md`,
`docs/10-performance-report.md` (→ change `reports/`),
`docs/11-traceability.md` (→ `reports/traceability.md`),
`docs/07-api-reference.md` (→ `openapi.yaml`),
`docs/15-production-readiness.md` (→ change `reports/`). If an older
project still has them, `spec-ingest --backfill` converts them once.

**Moved — `git mv` once if an older project has them:**
`docs/00-tech-stack.md` → `openspec/context/tech-stack.md`,
`01-market-analysis.md` → `product-analysis.md`,
`01b-product-context.md` → `product.md`, `01c-wedge.md` → `wedge.md`,
`03-system-design.md` → `architecture.md`,
`03b-ux-design.md` → `ux-design.md`, `16-pricing.md` → `pricing.md`,
`17-positioning.md` → `positioning.md`,
`11-observability.md` → `observability.md`,
`12-runbook.md` → `runbook.md`,
`13-data-retention-policy.md` → `data-retention.md`,
`14-environment-guide.md` → `environments.md`.

`openspec/config.yaml` sets the project context and per-artifact
rules; see §9.

---

## 2. Running the CLI

```bash
export OPENSPEC_TELEMETRY=0 DO_NOT_TRACK=1 OPENSPEC_NO_UPDATE_CHECK=1
OPENSPEC="npx --yes @fission-ai/openspec@1.15.0"

$OPENSPEC new change <change>                       # scaffold openspec/changes/<change>/
$OPENSPEC instructions <proposal|specs|design|tasks> --change <change>
                                                    # schema guidance + config rules for one artifact
$OPENSPEC list --specs --json                       # capability inventory
$OPENSPEC show <capability> --type spec --json      # one capability, full
$OPENSPEC show <change> --json --deltas-only        # what a change touches
$OPENSPEC validate <change> --strict --no-interactive
$OPENSPEC validate --all --strict --no-interactive  # used by the spec-validate gate
$OPENSPEC archive <change> --yes                    # merge deltas into openspec/specs/
```

Telemetry stays off: the workstation egress policy blocks it and it
adds nothing to the pipeline. Pin the version; bump it deliberately.

---

## 3. Requirement format

```markdown
### Requirement: FR-ING-01 Daily PMR load
The system SHALL load promotions for Ends from PMR via its BigQuery
source once a day at a scheduled time.

Priority: M · Wedge: critical

#### Scenario: Scheduled load runs
- **WHEN** the scheduled load time is reached
- **THEN** promotions are loaded and the load time and row count are logged
```

Rules:

1. **Header = `<ID> <short name>`.** OpenSpec matches requirements by
   header text, so the header never changes except through a
   `RENAMED` delta.
2. **IDs.** Functional: `FR-<AREA>-NN`. Non-functional:
   `NFR-<CAT>-NN` with `CAT` in `PERF | AVL | SEC | OBS | ALERT | QUAL
   | A11Y | DATA | COMP`. `AREA` is a 2–5 letter code per capability
   (e.g. `ING`, `NOM`, `PLAN`, `AUTH`). IDs are never reused; a
   dropped requirement is `REMOVED`, its ID retired. If a source
   document already has IDs, keep them verbatim.
3. **Description** starts with one SHALL/MUST sentence, one behaviour
   only, ≤ 500 characters (`--strict` fails beyond that). Split
   multi-behaviour requirements into separate requirements.
4. **Metadata line**, directly after the description:
   `Priority: M|S|C · Wedge: critical|supporting|v2`
   - `M` must (MVP), `S` should, `C` could. Won't-haves are not
     written as requirements; list them under proposal "Non-goals".
   - `Wedge: v2` means out of wedge; it must also have `Priority: C`.
   - Optional `· Source: <ref>` names where it came from: a story
     (`US-NOM-02`), a source-document section, or a signal
     (`iter-3 signal`).
5. **Scenarios.** At least one `#### Scenario:` (exactly four `#`)
   per requirement, `- **WHEN**` / `- **THEN**` bullets (optional
   `- **GIVEN**` first, `- **AND**` extras). Each scenario must be
   testable; a "design review" verification becomes a scenario whose
   THEN names the reviewable artifact.
6. **NFRs** carry a number and a measurement condition in the THEN
   (e.g. "within 5 s at p95 under the NFR-PERF-04 profile"). An NFR
   without a number is a critic failure.
7. **Unknowns.** Append `[NEEDS CLARIFICATION: OQ-NN]` to the metadata
   line and record `OQ-NN` under design.md `## Open Questions`. A
   `Priority: M` requirement with an open `OQ` blocks the spec critic.
8. **Capabilities** are durable behaviours (`nominations`,
   `store-pdf`), not work items (`add-pdf-button`). NFRs that apply
   system-wide go in their own capability (`performance`,
   `availability`, `security`, `observability`); NFRs tied to one
   capability may live in it.

---

## 4. Change lifecycle

```
propose ──► validate --strict ──► critic ──► [human checkpoint] ──► apply
   ▲                                                                  │
   └──── code must deviate? edit THIS change's delta, re-validate ◄───┤
                                                                      ▼
                         archive ◄── gates green (incl. traceability)
```

- **Change names**: kebab-case. First build: `mvp`. Imported spec:
  `import-<slug>`. Iterations: `iter-<N>-<slug>`. Signal-driven:
  `iter-<N>-signal-<slug>` (opened as `iter-<N>-signal` to collect
  evidence, renamed with `mv` once the slug is known — before the first
  validate). `N` = number of archived `iter-*` changes + 1.
- **One active change at a time per pipeline run**, recorded in
  `state.json` `.active_change`.
- **MODIFIED** deltas copy the whole existing requirement block
  (header through every scenario), then edit. Partial copies lose
  scenarios at archive.
- **REMOVED** deltas include `**Reason**:` and `**Migration**:`.
- **Never edit `openspec/specs/` directly**, with one exception: fixing
  a `## Purpose` placeholder left by archive.
- **No-behaviour changes** (pure refactor, tooling, docs): set
  `skip_specs: true` in the change's `.openspec.yaml` and archive with
  `--skip-specs`.
- **Decisions without behaviour** (e.g. a tripped kill switch) are
  also `skip_specs: true` changes: proposal + reports, archived, so the
  decision sits in history next to the evidence.
- **Archive** only after `scripts/quality-gates.sh` is green. First
  copy `reports/traceability.md` into the change's `reports/` (the
  proof at ship time). Archive is the step that makes the change true.
- **Never edit `openspec/changes/archive/`.** A later change records
  what it learned about an earlier one in its own reports (e.g. the
  measured lift of `iter-3-signal-…` lands in `iter-4-signal-…`'s
  `reports/signals-behavior.md`).
- **Living docs move with the code.** When a change alters
  architecture or UX, `tasks.md` carries a `[docs]` task that edits
  `openspec/context/architecture.md` / `ux-design` in the same change, so they are
  true when the change archives. The *why* stays in `design.md`.

---

## 5. proposal.md format

Sections from the OpenSpec template, plus the pipeline's own (OpenSpec
keeps extra sections). Keep it to 1–2 pages; detail belongs in specs
and design.

```markdown
# Proposal

## Why
<wedge sentence, quoted from openspec/context/wedge.md> — <the problem / gap / leaking funnel step, 1–2 sentences>

## What Changes
### nominations
- US-NOM-01 (M · critical) As a category manager, I want to nominate a promotion for an end so that it is planned.
- US-NOM-02 (S · supporting) …

## Non-goals
- <won't-have, and why>

## Capabilities
### New Capabilities
- `nominations`: nominating promotions for ends before the weekly deadline
### Modified Capabilities

## Success Metric
<iterations only — the first build's KPIs live in openspec/context/product.md: metric, query, predicted lift, kill criterion>

## Impact
<systems, data, integrations, dates>
```

- **Stories live here and only here**: one line each, `US-<AREA>-NN
  (<Priority> · <Wedge>) As a <persona>, I want … so that …`, grouped
  by capability. No acceptance criteria — those are the spec
  scenarios, and each requirement points back with `Source: US-…`.
  Personas are named, not described (descriptions are in `openspec/context/product.md`).
- **Non-goals** replace the "MVP scope / out of scope" sections of
  older product specs; Won't-haves go here, never into specs.
- `signal-iterate` adds `### Rejected alternatives` under Why, and
  fills Success Metric with the PostHog query and kill criterion.

---

## 6. tasks.md format

Follows the OpenSpec `tasks` instruction (each task says how it is
verified; tests land in the group that owes them; archive steps are
plain bullets under `## Workflow follow-up`), plus owner and
requirement tags.

```markdown
## 1. Database
- [ ] 1.1 [db] Promotion + load-log tables — implements: FR-ING-01, FR-ING-06 — verify: migration applies on a clean DB; seed-integrity gate green

## 2. Backend
- [ ] 2.1 [backend] Scheduled PMR loader with stale-data fallback — implements: FR-ING-01, FR-ING-06 — verify: @FR-ING-01, @FR-ING-06 integration tests pass

## 3. Frontend
- [ ] 3.1 [frontend] "Data as at" banner on noms tab and planner — implements: FR-ING-02 — verify: @FR-ING-02 component test passes
- [ ] 3.2 [docs] Update openspec/context/ux-design.md screen index for the banner — implements: none (docs) — verify: screen index lists the new frame

## 4. Integration
- [ ] 4.1 [e2e] Wedge workflow end to end — implements: FR-ING-01, FR-ING-02, FR-ING-06 — verify: @FR-ING-* Playwright scenarios pass

## Workflow follow-up
- Snapshot reports/traceability.md into this change, then `openspec archive`.
```

- Every task: `- [ ] X.Y [owner] <description> — implements: <IDs> —
  verify: <test, command or artifact>`. Owner is one of `db | auth |
  backend | frontend | ai | email | e2e | perf | ops | docs`.
- A task with no requirement is allowed only for `ops`/`docs` and
  says `implements: none (scaffolding)` or `implements: none (docs)`.
- Unit and integration tests are part of the implementing task, not a
  final testing group. The last group holds cross-cutting e2e / perf
  checks only.
- Implementers tick `- [x]` when the task's verification passes. Only
  `x` counts as done.
- Implementers refuse work that maps to no task; they add a task to
  the active change first (and a requirement delta if behaviour is
  new).

---

## 7. Test tagging (traceability)

Every automated test that verifies a requirement carries the
requirement ID as an `@`-tag in its title. The scenario name follows
after `›` when the test covers a specific scenario.

| Runner | Form |
|---|---|
| Playwright | `test('@FR-PLAN-04 › Drag a nomination onto an empty end', …)` |
| Vitest / Jest | `it('@FR-NOM-05 › Nominate after deadline is refused', …)` |
| pytest | `def test_fr_nom_05_after_deadline_refused():` with docstring `"""@FR-NOM-05 › …"""` |
| k6 | `group('@NFR-PERF-02 › Switch week under peak', …)` |

A test may carry several tags. `scripts/spec-coverage.sh` scans test
files for `@(FR|NFR)-[A-Z0-9]+-[0-9]+` and checks:

- every `Priority: M` requirement in `openspec/specs/**` and active
  change deltas has ≥ 1 tagged test,
- no tag names an ID that does not exist (or was REMOVED),
- when runner JSON reports exist, at least one tagged test per `M`
  requirement passed (all-skipped counts as uncovered).

`test.skip` on a `Priority: M` requirement is a gate failure, not a
way to finish. Route the missing feature to its implementer.

---

## 8. Finding IDs and where findings go

Findings keep their own namespaces (`CR-`, `SA-`, `AT-`, `DF-`), but
each finding names the requirement(s) it violates. Findings that show
the **spec** is wrong or ambiguous do not edit `openspec/specs/`:

- ambiguity → add `OQ-NN` to the active change's `design.md`
  (or open `iter-<N>-clarify-<slug>` if no change is active);
- spec is wrong / code is right → MODIFIED delta in the active change;
- code is wrong → fix code (or route to the implementer).

---

## 9. openspec/config.yaml (written by Phase 0 of build-product-v2)

```yaml
schema: spec-driven
context: |
  Binding principles: openspec/context/tech-stack.md (stack contract) and
  openspec/context/wedge.md (wedge, ICP, scale tier, anti-axis). Product
  context (personas, KPIs): openspec/context/product.md. Current
  architecture: openspec/context/architecture.md. Conventions:
  .claude/skills/build-product-v2/openspec-conventions.md
  One fact, one home: link to these files, never copy from them.
rules:
  proposal:
    - Quote the wedge sentence under Why; out-of-wedge work goes under Non-goals.
    - "Stories under What Changes, one line each: 'US-<AREA>-NN (<M|S|C> · <wedge>) As a <persona>, I want … so that …'; no acceptance criteria."
  specs:
    - "Header is '<ID> <short name>' with FR-<AREA>-NN or NFR-<CAT>-NN IDs; keep source IDs verbatim."
    - "Line after the description: 'Priority: M|S|C · Wedge: critical|supporting|v2'."
    - "Unknowns: append [NEEDS CLARIFICATION: OQ-NN] and add OQ-NN to design.md Open Questions."
    - Every NFR scenario states a number and a measurement condition.
  design:
    - Reference openspec/context/architecture.md for architecture; do not re-pick vendors from openspec/context/tech-stack.md.
    - Decisions (with alternatives), risks, stack gaps and OQ-NN open questions live here, not in openspec/context/.
  tasks:
    - "Each task: '- [ ] X.Y [owner] description — implements: <IDs> — verify: <check>'."
    - Tests land in the implementing task; the last group is cross-cutting e2e/perf only.
operations:
  archive:
    guidance:
      - Copy reports/traceability.md into the change's reports/ before archiving.
      - Never edit openspec/changes/archive/ afterwards.
```

Evidence produced for a change goes under `openspec/changes/<change>/reports/`
(§1), which OpenSpec leaves alone and archives with the change.
