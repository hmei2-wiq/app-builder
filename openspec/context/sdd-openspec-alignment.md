# SDD / OpenSpec alignment review of `.claude/skills`

Date: 2026-11-03 · Scope: the 36 skills under `.claude/skills/`, the
`scripts/` they call, and `CLAUDE.md`. `.gemini/` and `.codex/`
mirrors were not changed (see R7).

**Method.** I read every skill and script. I checked OpenSpec
behaviour against the pinned `@fission-ai/openspec@1.15.0` package:
its `spec-driven` schema, its templates and its CLI, run in a
throwaway repo. The comparison with spec-kit, Kiro and BMAD comes from
published documentation as I know it. It was not re-fetched, because
the workstation's egress policy blocks most of the web.

---

## 1. Where the pipeline sits in SDD

SDD tools fall into three levels: **spec-first** (write a spec, then
code, then drop the spec), **spec-anchored** (the spec stays and
changes through reviewed deltas) and **spec-as-source** (only the spec
is edited and code is generated from it). After commit `0e39132`,
build-product-v2 is **spec-anchored**. Requirements live in
`openspec/specs/`, every build is a change, archive merges the deltas
into the specs, and the `spec-validate` and `traceability` gates
enforce the link between specs and tests. That is the right level for
a pipeline that generates code with agents and still has to survive
hand edits.

| Concern | OpenSpec 1.15 | spec-kit | Kiro | This pipeline (after this change) |
|---|---|---|---|---|
| Principles / constitution | `config.yaml` `context` + `rules` | `memory/constitution.md` | `.kiro/steering/{product,tech,structure}.md` | `openspec/context/tech-stack.md`, `openspec/context/wedge.md`, referenced from `config.yaml` |
| Living behaviour spec | `openspec/specs/<cap>/spec.md` | none (per-feature specs only) | none (per-feature) | same as OpenSpec ✅ |
| Unit of work | change folder with deltas | `specs/<NNN-feature>/` | `.kiro/specs/<feature>/` | change folder ✅ |
| Why / scope | `proposal.md` | `spec.md` (user stories + acceptance) | `requirements.md` (EARS) | `proposal.md`: stories, non-goals, success metric |
| Requirements | SHALL + `#### Scenario` | FR-### + acceptance scenarios | EARS "WHEN … THE SYSTEM SHALL" | OpenSpec format + IDs, priority, wedge tag |
| Design | `design.md` per change | `plan.md`, `research.md`, `data-model.md`, `contracts/` | `design.md` | `design.md` (decisions) + living `openspec/context/architecture.md` (current state) |
| Tasks | `tasks.md` checkboxes with verification | `tasks.md` with `[P]` parallel markers | `tasks.md` linked to requirements | `tasks.md` with owner tag, `implements:`, `verify:` |
| Unknowns | design.md Open Questions (only questions that can wait) | `[NEEDS CLARIFICATION]` + `/clarify` | n/a | `[NEEDS CLARIFICATION: OQ-NN]` + human checkpoint |
| Consistency check | `validate --strict` | `/analyze` across all artifacts | n/a | `validate --strict` + `spec-coverage.sh` + critics |
| Evidence and history | archive moves the whole change folder | n/a | n/a | change `reports/` archived with the change ✅ |

The pipeline goes beyond all three in three places: requirement ↔
test traceability that runs as a gate, model-diverse critic gates, and
evidence that is archived alongside each change.

---

## 2. Duplication found (the main ask)

The pipeline had two parallel sets of artifacts. OpenSpec held the
requirements, while a numbered `docs/` series still restated them, or
held content that belongs to a single change.

| Was | Duplicated | Now |
|---|---|---|
| `docs/01b-product-spec.md` story map with WHEN/THEN acceptance | the spec scenarios | stories are one line each in `proposal.md` What Changes; acceptance criteria exist only as `#### Scenario`s |
| `01b` MVP scope / out of scope | proposal What Changes / Non-goals | proposal only |
| `01b` Open Questions | `design.md` Open Questions | `design.md` only |
| `01b` personas, KPIs, vision, assumptions | — (durable) | `openspec/context/product.md` (see §2a) |
| `openspec/context/architecture.md` §8 stack recap | `openspec/context/tech-stack.md` | removed |
| `03` §9 stack gaps, "we chose X over Y" rationale | the change `design.md` | `design.md` `## Stack Gaps` / `## Decisions` |
| `03` §10 traceability matrix | `tasks.md` `implements:` + traceability report | removed |
| `03` `[Iteration N]` section tags | archive history | removed; `[docs]` tasks keep `architecture.md` current |
| `docs/06-iteration-log.md` | `openspec/changes/archive/` | retired; the archive is the log |
| `docs/06-gap-analysis.md` | evidence for one change | `changes/iter-N-…/reports/gap-analysis.md` |
| `docs/iteration-N/the-one-change.md` | signal-iterate's `proposal.md` (it copied the numbers across) | proposal only |
| `docs/iteration-N/signals-*.md`, `kill-switch-tripped.md` | evidence for one change | change `reports/`; a tripped kill switch becomes a `skip_specs` change, so the decision is archived |
| `docs/08-e2e-test-report.md` coverage table | `docs/11-traceability.md` | `reports/e2e.md` links to the matrix |
| `docs/11-traceability.md` | generated output kept under `docs/` | `reports/traceability.md`, snapshotted into the change at archive |
| `docs/07-api-reference.md` | `openapi.yaml` | `openapi.yaml` only, with `x-requirements` on each operation |
| `docs/05`, `08b`, `09`, `10`, `docs/dogfood/iteration-N.md` | per-change evidence with no link to the change | change `reports/{code-review,adversarial,security-audit,performance,dogfood-<run>}.md` |
| `03b` "Accessibility requirements" | `NFR-A11Y-*` | "Accessibility approach" citing the IDs |

The rule, now §1 of `openspec-conventions.md`: **one fact, one home.**
- Behaviour lives in `openspec/specs/`.
- Anything made for one change lives in `openspec/changes/<change>/`,
  with evidence under `reports/`.
- `openspec/context/` keeps only durable context that isn't behaviour
  and that OpenSpec has no artifact for: stack, wedge, market,
  personas, architecture, UX, pricing, positioning and ops docs.

### 2a. Durable context moved under `openspec/`

The numbered `docs/NN-*.md` files the pipeline still wrote moved to
`openspec/context/`, renamed to OpenSpec's kebab-case style with no
number prefix: `tech-stack`, `product-analysis`, `product` (was
`01b-product-context`), `wedge`, `architecture` (was
`03-system-design`), `ux-design`, `pricing`, `positioning`,
`observability`, `runbook`, `data-retention`, `environments`.
`15-production-readiness.md` is evidence for the shipping change, so it
became `reports/production-readiness.md`. The only file the pipeline
still writes to `docs/` is `RUN.md`, the human quickstart. OpenSpec
1.15 reserves only `specs/`, `changes/`, `schemas/`, `config.yaml` and
the legacy `project.md` under `openspec/`; a sandbox run confirmed
`list`, `validate --all --strict` and `archive` ignore `context/`. This
is close to Kiro's steering files (`.kiro/steering/{product,tech,
structure}.md`), kept next to the specs they constrain.

Skills don't require the files to be there. `scripts/context-path.sh
<name>` resolves each one: a `state.json` `.context_paths` override,
then `openspec/context/<name>.md`, then the legacy `docs/` name, then
`docs/<name>.md`. Writers call it with `--move` first, so a legacy file
is relocated rather than duplicated. This repo's own strategy docs
moved under `openspec/context/` as well (`ideas/` for product
one-pagers, `sources/` for client input documents); only
`USER-MANUAL.md` and `orchestrator-workflow.md` stay in `docs/`.

I verified the layout against OpenSpec 1.15 in a sandbox:
- extra proposal sections pass `validate --strict`;
- a `reports/` folder is ignored by validation and moved by `archive`;
- a change folder can be renamed (`mv`) before its first validation;
- a `skip_specs: true` change with no tasks archives with `--skip-specs`;
- the new `config.yaml`, including `operations.archive.guidance`, loads,
  and its rules appear in `openspec instructions`.

---

## 3. Format alignment with upstream OpenSpec

- **tasks.md.** The 1.15 `tasks` instruction says each task states how
  it is verified, tests land in the group that owes them (no final
  testing group), and archive steps go under `## Workflow follow-up`.
  The old pipeline format ended with a "Verification" group. The
  format is now `… — implements: <IDs> — verify: <check>`, and the
  last group holds only cross-cutting e2e and perf checks. The owner
  grep the orchestrator uses still matches.
- **proposal.md** keeps the template's sections and adds Non-goals,
  Success Metric and the story map (§5).
- **config.yaml** adds the rules above, "link, don't copy" to
  `context`, and an archive guidance entry that tells the agent to
  snapshot traceability first.
- **Never edit the archive.** signal-iterate used to write the
  measured lift back into the archived proposal. Iteration N+1 now
  records it in its own `reports/signals-behavior.md`.

---

## 4. Defects found along the way

| # | Defect | Status |
|---|---|---|
| D1 | `scripts/spec-coverage.sh` truncated split IDs (`FR-NOM-01a` → `FR-NOM-01`), which spec-ingest creates when it splits a requirement. Both halves collapsed into one row, and one test covered both. | **Fixed**: the ID and tag regexes accept a `[a-z]` suffix and result matching uses `(?![0-9a-z])`; new test case I |
| D2 | The orchestrator ran `yq '.ci.provider' openspec/context/tech-stack.md`, but the contract is markdown with a fenced YAML block, so `yq` cannot read it. `yq` is also not installed on this workstation. | **Partly fixed**: the YAML block is extracted to `state/artifacts/tech-stack.yaml` first. `yq` is still an undeclared dependency (CLAUDE.md says "bash + jq") |
| D3 | `rollback` wrote `docs/12-runbook.md`; the orchestrator said `docs/19-rollback-runbook.md`. | **Fixed**: now `openspec/context/runbook.md` |
| D4 | `docs/11-` was used twice (observability and traceability). | **Fixed**: traceability moved to `reports/` |
| D5 | Phase 12 was labelled "PARALLEL", then said "actually sequential". The gate list in principle 7 left out spec-validate and traceability. | **Fixed** |
| D6 | USER-MANUAL still listed the retired `02`/`04`, `18-production-readiness` (the real file is 15) and `08b-adversarial-report`. | **Fixed** for the file map, iterate section and skill table |
| D7 | `scripts/test/quality-gates.test.sh` fails 16 of 27 on a clean `HEAD` (an environment issue, not caused by this change). | **Open** |
| D8 | `auth-engineer` and `cicd` run `jq` on the markdown contract in their commit messages (they fall back silently). | **Open**: low impact |
| D9 | `adversarial-tester/SKILL.md` contains non-UTF-8 bytes, so git shows it as binary and its diffs can't be reviewed. | **Open**: re-save as UTF-8 |

---

## 5. Further recommendations (not implemented)

Ordered by value for the effort.

- **R1. A deterministic cross-artifact lint gate** (spec-kit
  `/analyze`). Today the critics check by prompt. A small
  `scripts/spec-lint.sh` could check by rule, after `spec-validate`:
  - every `US-` in the proposal is cited by some `Source:`;
  - every capability in the proposal has a delta file;
  - every `implements:` ID exists;
  - no `Priority: M` requirement has an unresolved `OQ-`;
  - no file in the retired list exists.
- **R2. A project-local schema** (`openspec schema fork spec-driven
  build-product`) that carries the §5/§6 templates. With it,
  `openspec instructions` and the `/opsx:*` commands hand humans the
  pipeline's own format instead of relying on `config.yaml` rules.
  The schema commands are marked experimental in 1.15, so pin and test
  before adopting.
- **R3. Answered questions.** OpenSpec says design.md Open Questions
  are only for unknowns that can wait. The pipeline parks *blocking*
  questions there until a human checkpoint. Keep the blocking flow,
  but move answered `OQ-`s into a `## Clarifications` log in
  `proposal.md` (spec-kit style), so design.md only lists questions
  that are still open.
- **R4. EARS wording for requirement descriptions** ("WHEN <trigger>,
  the system SHALL …"). It fits OpenSpec's SHALL rule, makes the
  analyst's one-behaviour split mechanical, and maps directly onto
  scenarios.
- **R5. Parallel-safe task markers** (spec-kit `[P]`) in `tasks.md`.
  Phase 7 could then fan out at task level rather than per owner.
- **R6. Treat `state.json` copies as a cache.** `wedge_sentence`,
  `scale_tier` and `tech_stack.*` copy `wedge.md` and `tech-stack.md`. Re-derive them
  after each producer phase and never hand-edit them; this change
  added that note for `tech_stack`.
- **R7. Sync the mirrors.** `.gemini/` and `.codex/` mirror these
  skills but missed the `0e39132` OpenSpec rework, and they miss this
  change too. A generator script (`.claude` → mirrors) would stop the
  drift.
- **R8. Nested capability paths** (`identity/user-auth`) are supported
  in 1.15. Adopt them once a product has more than about 10
  capabilities.
- **R9. Version.** 1.16.0 is out. Stay on 1.15.0 until R2 or a needed
  fix calls for a deliberate bump with the sandbox checks in §2 rerun.
