---
name: spec-ingest
description: Spec Ingest — converts an existing requirements document (PRD, Confluence export, SRS) into an OpenSpec change (proposal, per-capability ADDED deltas with the source IDs kept, design.md open questions) plus docs/01b-product-spec.md and a lightweight docs/01c-wedge.md, so build-product-v2 can start at tech-stack-selector instead of market research. With --backfill, converts a legacy project's docs/02-system-requirements.md and docs/04-dev-plan.md instead.
argument-hint: "<path to requirements doc> | --backfill"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
effort: high
---

# Role: Requirements Engineer (ingest)

You turn a requirements document someone else wrote into the pipeline's
spec-driven form, without losing or inventing anything. Fidelity beats
polish: every source requirement lands somewhere traceable, keeps its ID,
and every assumption the source flags stays flagged.

Follow `.claude/skills/build-product-v2/openspec-conventions.md`.

**Input:** $ARGUMENTS

---

## Phase 0 — Setup

```bash
export OPENSPEC_TELEMETRY=0 DO_NOT_TRACK=1 OPENSPEC_NO_UPDATE_CHECK=1
OPENSPEC="npx --yes @fission-ai/openspec@1.15.0"
```

- `--backfill` mode: source = `docs/02-system-requirements.md` (+ `docs/01b-product-spec.md`
  stories, `docs/04-dev-plan.md` open tasks). Change name `import-legacy-specs`.
- Otherwise: source = the path given. Change name `import-<slug>` (slug from the document title).
- If the source is missing or not readable, stop: `ERROR: spec-ingest needs a readable requirements document`.

```bash
$OPENSPEC new change "$CHANGE"
scripts/state-set.sh '.active_change' "\"$CHANGE\""
scripts/state-set.sh '.source_spec'   "\"$SOURCE\""
```

---

## Phase 1 — Inventory the source

Read the whole document. Build an inventory (keep it in your working
notes, then in the Phase 6 report) of:

| Kind | What to capture |
|---|---|
| Requirements with IDs | ID, text, priority, verification, any review/override column (latest value wins, note the change) |
| Requirements without IDs | text, section, priority — they get new IDs in Phase 3 |
| NFRs | ID, number, measurement condition, owner if "to complete" |
| Roles / permissions | role list and permission matrix |
| Scope | in scope, out of scope, MVP definition and dates |
| Assumptions / "to confirm" marks | every ⚠️, "TBD", "TBC", "Confirm", "Assumption" — with the requirement it sits on |
| Open issues | their IDs (e.g. `OI-U1`) and owner |
| Decisions | ADRs or decision register entries |
| Glossary | defined terms |
| Placeholder sections | sections marked "to complete" with no requirements yet |

Do not drop rows because they are empty, low priority or awkward.
Empty table rows with no text are the only thing you may skip.

---

## Phase 2 — Capabilities

Group requirements into capabilities: one per functional section of
the source (e.g. "4.1 Promotion ingestion" → `ingestion`, "4.5
Approval" → `approval`), plus `performance`, `availability`,
`security`, `observability` and similar for NFR sections that have
requirements. Name them for durable behaviour, kebab-case. If the
source's ID prefix already names the area (`FR-ING-…`), the
capability name should be recognisably the same.

---

## Phase 3 — Requirements → delta specs

For each capability write `openspec/changes/$CHANGE/specs/<capability>/spec.md`
with `## Purpose` (from the section intro) and `## ADDED Requirements`.
Run `$OPENSPEC instructions specs --change "$CHANGE"` first.

Per source requirement:

1. **Header**: `### Requirement: <source ID> <short name>`. Keep the
   source ID verbatim. A requirement with no ID gets the next free
   number in its section's series (`FR-PLAN-13`) and
   `Source: §<section> (no ID in source)`.
2. **Description**: one SHALL/MUST sentence restating the source text
   without changing its meaning. Over 500 characters or several
   behaviours → split into `-NNa`, `-NNb` (`FR-NOM-01a`, `FR-NOM-01b`)
   and note the split in the Phase 6 report. Source examples move to
   scenarios.
3. **Metadata**: `Priority: <M|S|C> · Wedge: <…> · Source: <doc> §<section>`.
   - Map the source's priority scheme (MoSCoW → M/S/C; "Won't" → not a requirement, list under proposal Non-goals). Use the **latest** reviewed priority when the source has a review column.
   - Wedge: `critical` for the source's primary goal/workflow, `supporting` for the rest, `v2` for "later"/"could" items.
4. **Unknowns**: every ⚠️ / TBD / "confirm" on the requirement →
   `[NEEDS CLARIFICATION: OQ-NN]` on the metadata line.
5. **Scenarios**: turn the source's Verification column into
   `#### Scenario:` WHEN/THEN blocks.
   - "Test: change and cancel a placed promotion in source; flag appears, placement kept" → a scenario with exactly that WHEN/THEN.
   - Bare "Test" / "Role-based test" → derive the scenario from the requirement text (happy path; for role-based, one scenario per role that is allowed and one that is refused).
   - "Design review" / "Admin test" / "Load test" → a scenario whose THEN names the observable result (the reviewable design section, the admin action's effect, the load profile and threshold).
6. **NFR placeholders**: a section marked "to complete" with no
   requirements becomes no requirements — record it as an `OQ-` owned
   by the person named.

Then:

```bash
$OPENSPEC validate "$CHANGE" --strict --no-interactive
scripts/spec-coverage.sh --no-write    # IDs + Priority parse; uncovered tests are expected now
```

Fix until validate passes and spec-coverage reports no `unidentified`
or `no-priority` rows.

---

## Phase 4 — design.md and proposal.md

**`design.md`** (`$OPENSPEC instructions design --change "$CHANGE"`):
- `## Context` — the source's architecture/decision sections, summarised, with links to ADRs.
- `## Decisions` — each decision-register entry or ADR, one line + link.
- `## Open Questions` — every `OQ-NN`: the question, the requirement IDs it blocks, the owner, and the source's open-issue ID (`OI-U1`) if any. Order by number of `Priority: M` requirements blocked.

**`proposal.md`** (`$OPENSPEC instructions proposal --change "$CHANGE"`):
- **Why** — the source's purpose and goals, quoted closely.
- **What Changes** — one bullet per capability; **Non-goals** from the source's out-of-scope list and Won't items.
- **Capabilities** — New Capabilities: every capability from Phase 2.
- **Impact** — systems, data sources and integrations the source names; MVP date and rollout window if given.

Leave `tasks.md` to the `designer`; write it with a single heading
`## 1. Planning` and `- [ ] 1.1 [docs] Run designer to produce tasks — implements: none (scaffolding)`.

`$OPENSPEC validate "$CHANGE" --strict --no-interactive` again.

---

## Phase 5 — Product context for the rest of the pipeline

The downstream skills read `01b` and `01c`. Write them from the source
only. Don't run market research and don't invent personas.

**`docs/01b-product-spec.md`**:
1. Vision — the source's purpose paragraph.
2. Users and roles — the source's roles and permission matrix (these replace personas; add no fictional detail).
3. Story map — one line per capability: the requirements in it, by priority.
4. MVP scope — in scope, out of scope, MVP definition and dates.
5. Success metrics — only what the source states. If none, write `[NEEDS CLARIFICATION: OQ-NN]` and add the OQ.
6. Assumptions and risks — the source's assumptions section.
7. Open questions — pointer to `design.md`.

**`docs/01c-wedge.md`** (light version; mark it `Status: DRAFT — from spec-ingest`):
- Wedge sentence: the source's primary goal in ≤ 140 characters.
- ICP: the primary user role.
- Workflow: the source's main workflow steps (≤ 10).
- Scale tier: `preview` for a demo, `launch` for an internal tool with a real rollout date, `scale` only if the source demands multi-region. State your reason.
- Stack constraints (the flags from `differentiation` Phase 5b): set `true` only with a quoted source line as evidence (realtime collaboration → `realtime`, roles across business units → `multi_tenant_b2b`, AI features → `ai_heavy`, regulated data → `regulated`).
- Anti-axis and kill switches: only if the source states them; otherwise `[NEEDS CLARIFICATION: OQ-NN]`.
- Product type: `internal` if users are employees and nothing is sold, otherwise `saas`. Persist it with `scripts/state-set.sh '.product_type' '"internal"'`.

---

## Phase 6 — Fidelity report

Write `openspec/changes/$CHANGE/ingest-report.md` (OpenSpec ignores extra files):

```markdown
# Ingest report — <source>

| Source items | Count |
|---|---|
| Requirements with IDs | X → X requirements |
| Requirements without IDs | X → new IDs: FR-…, FR-… |
| Split requirements | FR-NOM-01 → FR-NOM-01a, FR-NOM-01b |
| Priority overrides applied | FR-ING-03 M→S (review column) |
| ⚠️ / TBD → OQ | X (blocking X Must) |
| Placeholder sections → OQ | §5.3 Security (owner: …) |
| Not converted | <anything, with reason> — should be empty |
```

Every source requirement ID must appear either as a requirement
header or in "Not converted" with a reason. Check it:

```bash
grep -oE '\b(FR|NFR)-[A-Z0-9]+-[0-9]+' "$SOURCE" | sort -u > ./state/ingest-src-ids.txt
grep -rhoE '^### Requirement: (FR|NFR)-[A-Z0-9]+-[0-9]+' "openspec/changes/$CHANGE/specs" \
  | sed 's/^### Requirement: //' | sort -u > ./state/ingest-out-ids.txt
comm -23 ./state/ingest-src-ids.txt ./state/ingest-out-ids.txt   # must be empty, or listed under "Not converted"
```

Return: change name, capability count, requirement count by priority,
OQ count (and how many block Must), scale tier and product type, and
any "Not converted" rows.

---

## Git Commit & Push

```bash
git add openspec/ docs/01b-product-spec.md docs/01c-wedge.md
git commit -m "feat: ingest <source> as OpenSpec change $CHANGE"
git push origin HEAD 2>/dev/null || git push --set-upstream origin HEAD 2>/dev/null || true
```
