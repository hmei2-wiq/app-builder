# build-product — project notes for Claude

## Default product builder

**When the user asks to "build a product" / "build me X" / "build a
SaaS" / similar, invoke `build-product-v2`.**

`build-product-v2` is the canonical orchestrator: state-machine,
critic gates, scale-tier branching, dogfood loop, human checkpoints,
and per-phase subagent contexts. See
`.claude/skills/build-product-v2/SKILL.md`.

## Pipeline architecture (one-screen overview)

```
(--from-spec <doc>: spec-ingest → [HUMAN] → tech-stack-selector → designer …)
ceo → differentiation → [HUMAN] → tech-stack-selector → product-spec
  → analyst → designer → ux-designer → [HUMAN]
  → auth-engineer → (email-templates if needed) → (ai-features if ai_heavy)
  → [backend + frontend + db-migrator]  (parallel)
  → api-docs → e2e-tester
  → quality-gates (spec-validate → typecheck → lint → unit → mutation → integration → contract → e2e → traceability → a11y → lighthouse → visual)
  → adversarial-tester → security-auditor → dogfood
  → (launch+ only: perf-tester → reviewer)
  → pricing → positioning → [HUMAN] → landing-page → legal-compliance
  → (launch+ only: background-jobs → env-manager → cicd → deployer → observability → rollback → production-readiness)
  → preview-ship → [HUMAN] → openspec archive → analytics
  → signal-iterate (recurring)
```

**Stack contract:** `differentiation` emits stack constraints
(realtime, ai_heavy, regulated, multi_tenant_b2b, eu_global_billing,
mobile_first, data_heavy). `tech-stack-selector` runs after the first
human checkpoint and writes `openspec/context/tech-stack.md` — the binding
contract every downstream skill reads. CI/CD defaults to **Buildkite**
(cost-effective; org has `$BK_API_TOKEN`); GitHub Actions / GitLab CI
are alternatives, opted into via the contract.

**Spec contract (SDD / OpenSpec):** requirements live in
`openspec/specs/<capability>/spec.md`; every build or iteration is one
change in `openspec/changes/<name>/` (proposal → delta specs → design →
tasks), validated `--strict` before code, implemented task by task,
proven by `@<ID>`-tagged tests (`traceability` gate), and archived at
ship. One fact, one home: behaviour in `openspec/specs/`, everything
made for one change (stories, decisions, tasks, evidence reports) in
`openspec/changes/<name>/` (`reports/` for evidence), and
`openspec/context/` only for durable non-behaviour context (stack, wedge, market, personas,
architecture, UX, pricing, ops). The archive replaces the iteration
log. Rules and the retired-docs list:
`.claude/skills/build-product-v2/openspec-conventions.md` §1.

Each `→` between two strategic artifacts has a critic gate (different
model from the producer). The four boxes marked HUMAN in
`build-product-v2` SKILL.md are non-skippable user confirmations.

## Scale tiers

Pick a tier early; later phases gate on it.

| Tier | When | Skips |
|---|---|---|
| `toy` | Throwaway prototype | jobs, env, cicd, infra, observability, PRR, deploy |
| `preview` | Public demo, ≤ 100 users | jobs, env, cicd, infra, observability, PRR (deploys to Vercel/Fly preview) |
| `launch` | Paying customers, single region | infra, observability, PRR |
| `scale` | Multi-region / enterprise | nothing — runs the full pipeline |

Default is `preview`. Don't run Terraform for an MVP.

## Project scripts

Live in `scripts/`. The orchestrator and skills assume they exist.

- `state-init.sh "<idea>"` — create / upgrade `state/state.json`
- `state-set.sh '<jq path>' '<json value>'` — atomic field write
- `state-decide.sh <phase> "<decision>" "<reason>"` — append ADR
- `quality-gates.sh [--only x,y] [--skip z] [--keep-going]` — layered hard gates
  (starts with `spec-validate`; `traceability` runs after `e2e`)
- `context-path.sh [--move] <name>…` — resolve a context file
  (`openspec/context/<name>.md`, falling back to legacy `docs/` names or
  a `state.json` `.context_paths` override); `--move` relocates a legacy
  file before writing
- `spec-coverage.sh [--json] [--no-write]` — requirement ↔ test traceability;
  writes `reports/traceability.md`
- `route-failure.sh --gate <g> --area <path>` — map failure → owner skill
- `shipworthy-scan.sh <url> [--json]` — passive security audit of a deployed
  app (leaked secrets, Supabase RLS-off, open APIs, headers, source maps); the
  free "Is your app Shipworthy?" top-of-funnel scanner (see `openspec/context/shipworthy-strategy.md`)
- `cogs-model.sh [--sweep]` — PLG free→paid unit-economics model; the Phase 2
  go/no-go gate for the self-serve tier

All are bash + jq, no Node deps (the `spec-validate` gate runs the pinned
OpenSpec CLI via `npx`). Tests live in `scripts/test/*.test.sh`.

## Skills inventory

See `openspec/context/pipeline-research.md` for the full list,
the design rationale, and the open backlog.

New (round 1 + round 2): `differentiation`, `pricing`, `positioning`,
`adversarial-tester`, `dogfood`, `signal-iterate`, `build-product-v2`.
Round 3 (SDD): `spec-ingest` (existing PRD → OpenSpec change).

## Notes for collaboration

- The user prefers terse responses; don't summarize what's already in
  the diff.
- Don't add backwards-compat shims when retiring legacy code; just
  delete it.
- For UI changes, use the `dogfood` skill or the `browse` skill —
  don't claim a UI works without driving it in a real browser.
