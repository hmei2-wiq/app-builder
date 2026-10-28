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

| Artifact | Location | Owner |
|---|---|---|
| Tech-stack contract (principles) | `docs/00-tech-stack.md` | `tech-stack-selector` |
| Wedge, ICP, tier, stack flags (principles) | `docs/01c-wedge.md` | `differentiation` |
| Market, pricing, positioning (strategy) | `docs/01`, `docs/16`, `docs/17` | `ceo`, `pricing`, `positioning` |
| Personas, scope, KPIs (product context) | `docs/01b-product-spec.md` | `product-spec` |
| **Current behaviour (source of truth)** | `openspec/specs/<capability>/spec.md` | written **only** by `openspec archive` |
| **Proposed change** | `openspec/changes/<change>/` | the skill running the change |
| ├ why / what / capabilities | `proposal.md` | `product-spec`, `iterate`, `signal-iterate`, `spec-ingest` |
| ├ requirement deltas | `specs/<capability>/spec.md` | `analyst`, `spec-ingest`, `iterate` |
| ├ change-level design + open questions | `design.md` | `designer`, `iterate` |
| └ implementation checklist | `tasks.md` | `designer` (first build), `iterate`, `signal-iterate` |
| System architecture (project-wide) | `docs/03-system-design.md` | `designer` |
| UX (project-wide) | `docs/03b-ux-design.md` + Figma | `ux-designer` |
| Traceability report | `docs/11-traceability.md`, `state/artifacts/traceability.json` | `scripts/spec-coverage.sh` |

Retired: `docs/02-system-requirements.md` (now `openspec/specs/**`) and
`docs/04-dev-plan.md` (now each change's `tasks.md`). Do not create
them. If an older project still has them, `spec-ingest --backfill`
converts them once.

`openspec/config.yaml` sets the project context and per-artifact
rules; see §8.

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
  `iter-<N>-signal-<slug>`.
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
- **Archive** only after `scripts/quality-gates.sh` is green. Archive
  is the step that makes the change true.

---

## 5. tasks.md format

```markdown
## 1. Database
- [ ] 1.1 [db] Promotion + load-log tables — implements: FR-ING-01, FR-ING-06

## 2. Backend
- [ ] 2.1 [backend] Scheduled PMR loader with stale-data fallback — implements: FR-ING-01, FR-ING-06

## 3. Frontend
- [ ] 3.1 [frontend] "Data as at" banner on noms tab and planner — implements: FR-ING-02

## 4. Verification
- [ ] 4.1 [e2e] Scenarios for FR-ING-01..06 — implements: FR-ING-01, FR-ING-02, FR-ING-06
```

- Every task: `- [ ] X.Y [owner] <description> — implements: <IDs>`.
  Owner is one of `db | auth | backend | frontend | ai | email | e2e
  | perf | ops | docs`.
- A task with no `implements:` is allowed only for `ops`/`docs`
  scaffolding and must say `implements: none (scaffolding)`.
- Implementers tick `- [x]` when the task's tests pass. Only `x`
  counts as done.
- Implementers refuse work that maps to no task; they add a task to
  the active change first (and a requirement delta if behaviour is
  new).

---

## 6. Test tagging (traceability)

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

## 7. Finding IDs and where findings go

Findings keep their own namespaces (`CR-`, `SA-`, `AT-`, `DF-`), but
each finding names the requirement(s) it violates. Findings that show
the **spec** is wrong or ambiguous do not edit `openspec/specs/`:

- ambiguity → add `OQ-NN` to the active change's `design.md`
  (or open `iter-<N>-clarify-<slug>` if no change is active);
- spec is wrong / code is right → MODIFIED delta in the active change;
- code is wrong → fix code (or route to the implementer).

---

## 8. openspec/config.yaml (written by Phase 0 of build-product-v2)

```yaml
schema: spec-driven
context: |
  Binding principles: docs/00-tech-stack.md (stack contract) and
  docs/01c-wedge.md (wedge, ICP, scale tier, anti-axis). Product
  context: docs/01b-product-spec.md. Conventions:
  .claude/skills/build-product-v2/openspec-conventions.md
rules:
  proposal:
    - Quote the wedge sentence under Why; out-of-wedge work goes under Non-goals.
  specs:
    - "Header is '<ID> <short name>' with FR-<AREA>-NN or NFR-<CAT>-NN IDs; keep source IDs verbatim."
    - "Line after the description: 'Priority: M|S|C · Wedge: critical|supporting|v2'."
    - "Unknowns: append [NEEDS CLARIFICATION: OQ-NN] and add OQ-NN to design.md Open Questions."
    - Every NFR scenario states a number and a measurement condition.
  design:
    - Reference docs/03-system-design.md for architecture; do not re-pick vendors from docs/00-tech-stack.md.
  tasks:
    - "Each task: '- [ ] X.Y [owner] description — implements: <IDs>'."
```
