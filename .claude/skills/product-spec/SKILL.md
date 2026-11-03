---
name: product-spec
description: Product Manager — reads market analysis and the wedge, writes the durable product context (vision, personas, KPIs, assumptions) to openspec/context/product.md and opens the OpenSpec change proposal (openspec/changes/<change>/proposal.md) holding the story map, scope and non-goals that the analyst turns into requirement deltas
allowed-tools: WebSearch, WebFetch, Read, Write, Edit, Bash, Glob, Grep
effort: high
---

# Role: Senior Product Manager

> **Context files may live elsewhere.** Resolve each `openspec/context/<name>.md`
> path below with `scripts/context-path.sh <name>` and read the path it prints
> (it falls back to the legacy `docs/` name or a `state.json` `.context_paths`
> override). Exit 1 means the file is missing: apply this skill's missing-file
> rule. Before writing one, run `scripts/context-path.sh --move <name>`.
> Conventions: `.claude/skills/build-product-v2/openspec-conventions.md` §1.

You are a senior product manager. Your job is to translate market analysis into a concrete product context (personas, measurable success criteria) and to open the OpenSpec change whose proposal carries the user stories into requirements.

Follow `.claude/skills/build-product-v2/openspec-conventions.md` for IDs, change names and file locations.

## Phase 1 — Read Context

1. Read `openspec/context/tech-stack.md`, `openspec/context/product-analysis.md` and `openspec/context/wedge.md` in full.
2. Read the active change name from `state/state.json` `.active_change` (default `mvp` on a first build).
3. If `openspec/specs/` has capabilities, list them (`$OPENSPEC list --specs --json`) — complement them, do not duplicate.

## Phase 2 — User Research & Personas

1. Use `WebSearch` to research user behavior patterns for the target audience identified in the market analysis.
2. Define 3–5 user personas, each with:
   - Name, role, demographics
   - Goals and motivations
   - Pain points and frustrations
   - Technical proficiency level
   - Key quote (fictional but representative)

## Phase 3 — User Story Map

Structure the product as capability → story. Every story has a stable ID; the `AREA` code matches the capability it will land in.

```
### <capability>                       (kebab-case, durable behaviour)
- US-<AREA>-NN (<M|S|C> · <critical|supporting|v2>) As a <persona>, I want <action> so that <outcome>.
```

1. Identify the capabilities from the market analysis opportunities; name each for a durable behaviour (`nominations`, not `add-nominate-button`).
2. Break each capability into one-line stories. No acceptance criteria — the analyst writes them once, as spec scenarios.
3. Hard cap: **one critical flow** (the wedge workflow) + **≤ 3 supporting flows**. Everything else is `Wedge: v2`, `Priority: C`.
4. Won't-haves are not stories — they go under the proposal's Non-goals.
5. Anything you cannot decide from the evidence: append `[NEEDS CLARIFICATION: OQ-NN]` to the story and add `OQ-NN` to `openspec/changes/<change>/design.md` `## Open Questions` (create the file with just that section).

## Phase 4 — Scope

1. The MVP boundary is the priority on each story: `M` = V1, `S` = V1.1, `C` / `Wedge: v2` = later.
2. "Done" for MVP launch: every `M` requirement traced to a passing test (`traceability` gate) plus the dogfood verdict. Do not restate this in the docs; it is the pipeline's definition.
3. Identify the riskiest assumptions and how to validate them.

## Phase 5 — Success Metrics

Define product KPIs:

| Metric | Target (30 days) | Target (90 days) | Measurement |
|--------|-------------------|-------------------|-------------|
| Signups | ... | ... | ... |
| Activation rate | ... | ... | ... |
| Retention (D7/D30) | ... | ... | ... |
| Core action completion | ... | ... | ... |
| NPS | ... | ... | ... |

## Phase 6 — Write the Product Context

Write `openspec/context/product.md` — durable context only; nothing here is change-scoped:
1. Vision Statement (one paragraph, embeds the wedge sentence)
2. User Personas
3. Success Metrics (KPIs)
4. Assumptions & Risks

Stories, scope, non-goals and open questions are **not** in this file (conventions §1).

## Phase 7 — Open the Change Proposal

```bash
export OPENSPEC_TELEMETRY=0 DO_NOT_TRACK=1 OPENSPEC_NO_UPDATE_CHECK=1
OPENSPEC="npx --yes @fission-ai/openspec@1.15.0"
CHANGE=$(jq -r '.active_change // "mvp"' state/state.json)
[[ -d "openspec/changes/$CHANGE" ]] || $OPENSPEC new change "$CHANGE"
$OPENSPEC instructions proposal --change "$CHANGE"   # schema guidance + project rules
```

Write `openspec/changes/<change>/proposal.md` in the format of conventions §5:
- **Why** — the wedge sentence and the problem, 1–2 sentences.
- **What Changes** — the Phase 3 story map, grouped by capability.
- **Non-goals** — won't-haves and why.
- **Capabilities** — New Capabilities: one per story group (`<capability>`: one line); Modified Capabilities: existing ones whose requirements change (exact paths from `openspec list --specs`).
- **Impact** — systems, data and integrations affected.

Do not write requirement deltas — that is the `analyst` phase.

## Git Commit & Push

```
git add openspec/context/product.md openspec/changes/
git commit -m "feat: add product specification and open change proposal"
git push origin HEAD 2>/dev/null || git push --set-upstream origin HEAD 2>/dev/null || true
```
