# build-product-v2 — Orchestrator Workflow (Verified)

Source-of-truth diagrams of the orchestrator at
`.claude/skills/build-product-v2/`. Phase names, gate ordering, tier-skip
rules and verdict structures are extracted directly from the SKILL.md
and the scripts in `/scripts/`. Where this differs from `CLAUDE.md`, the
source is preferred.

---

## TL;DR

- **35 skills** organised across 9 phase groups (strategy → design →
  setup → build → QA → live → GTM → ops → iterate).
- **20 numbered phases** (with sub-steps `0`, `1`, `1c`, `2`, `2c`,
  `2.7`, …, `19.5`, `20`). Every strategic-artifact phase has a paired
  `_critic` gate run by a different model.
- **4 mandatory human checkpoints** — wedge/ICP, design target,
  pricing/positioning, GO/NO-GO before public URL.
- **4 scale tiers** — `toy`, `preview` (default), `launch`, `scale` —
  each skips a fixed list of ops phases.
- **State machine** — a single `state/state.json` blackboard updated
  via `scripts/state-set.sh` after every phase.

---

## 1. Master pipeline (full)

The headline diagram. Phase numbers are verbatim from `build-product-v2/SKILL.md`.

```mermaid
flowchart TB
    start(["Phase 0<br/>Bootstrap<br/>state-init.sh"]):::start

    subgraph STR ["Strategy (no code yet)"]
        direction TB
        ceo["1. ceo<br/>+ 1c. ceo_critic"]:::strat
        diff["2. differentiation<br/>+ 2c. diff_critic"]:::strat
        H1{{"HUMAN CHECKPOINT 1<br/>wedge · ICP · tier · stack constraints"}}:::human
        stack["2.7. tech-stack-selector<br/>+ 2.7c. stack_critic"]:::strat
        spec["3. product-spec<br/>+ 3c. spec_critic"]:::strat
    end

    subgraph DES ["Design"]
        direction TB
        anal["4. analyst<br/>(IEEE 830 SRS)"]:::design
        des["5. designer<br/>+ 5c. design_critic"]:::design
        ux["6. ux-designer<br/>+ 6c. ux_critic"]:::design
        H2{{"HUMAN CHECKPOINT 2<br/>design target"}}:::human
    end

    subgraph SET ["Setup (conditional)"]
        direction TB
        auth["6.7. auth-engineer"]:::setup
        ai["6.8. ai-features<br/>(if ai_heavy=true)"]:::setup
        em["6.9. email-templates<br/>(if needs email)"]:::setup
    end

    subgraph BLD ["Build (parallel fan-out)"]
        direction LR
        be["7. backend-developer"]:::build
        fe["7. frontend-developer"]:::build
        db["7. db-migrator"]:::build
    end

    subgraph QA ["Quality + Live"]
        direction TB
        api["7.5. api-docs"]:::qa
        e2e["7.7. e2e-tester"]:::qa
        qg["8. quality-gates<br/>(11 layers, hard pass)"]:::qa
        adv["9. adversarial-tester<br/>→ re-run quality-gates"]:::qa
        sec["10. security-auditor"]:::qa
        df["11. dogfood<br/>(real browser walk)"]:::qa
        perf["11.5. perf-tester<br/>(launch+ only)"]:::launchplus
        rev["11.7. reviewer<br/>(launch+ only)"]:::launchplus
    end

    subgraph GTM ["Go-to-market"]
        direction TB
        pri["12. pricing"]:::gtm
        pos["12. positioning<br/>(reads pricing)"]:::gtm
        H3{{"HUMAN CHECKPOINT 3<br/>tiers · prices · headline"}}:::human
        lp["13. landing-page"]:::gtm
        leg["13.5. legal-compliance<br/>(skip toy; hard-fail if regulated)"]:::gtm
    end

    Branch{{"Scale-tier branch"}}:::branch

    subgraph OPS ["Ops (launch+ only)"]
        direction TB
        bj["15. background-jobs"]:::ops
        env["16. env-manager"]:::ops
        ci["16. cicd"]:::ops
        dep["17. deployer"]:::ops
        obs["17. observability"]:::ops
        rb["17.5. rollback"]:::ops
        prr["18. production-readiness<br/>(scale only)"]:::ops
    end

    subgraph SHIP ["Ship + iterate"]
        direction TB
        ship["19. preview-ship<br/>(local + tier-dependent deploy)"]:::ship
        H4{{"HUMAN CHECKPOINT 4<br/>GO / NO-GO"}}:::human
        an["20. analytics"]:::ship
        si["signal-iterate<br/>(weekly, recurring)"]:::ship
    end

    start --> ceo --> diff --> H1
    H1 --> stack --> spec
    spec --> anal --> des --> ux --> H2
    H2 --> auth --> ai --> em
    em --> be & fe & db
    be & fe & db --> api --> e2e --> qg
    qg --> adv --> sec --> df
    df --> perf --> rev
    rev --> pri --> pos --> H3
    H3 --> lp --> leg --> Branch
    Branch -->|"toy / preview"| ship
    Branch -->|"launch / scale"| bj
    bj --> env --> ci --> dep --> obs --> rb --> prr --> ship
    ship --> H4 --> an --> si

    classDef start fill:#1f2937,color:#fff,stroke:#fff,stroke-width:2px
    classDef strat fill:#dbeafe,color:#000,stroke:#1e40af
    classDef design fill:#e0e7ff,color:#000,stroke:#3730a3
    classDef setup fill:#fce7f3,color:#000,stroke:#9d174d
    classDef build fill:#fef3c7,color:#000,stroke:#92400e
    classDef qa fill:#d1fae5,color:#000,stroke:#065f46
    classDef launchplus fill:#a7f3d0,color:#000,stroke:#065f46,stroke-dasharray: 4 4
    classDef gtm fill:#fed7aa,color:#000,stroke:#9a3412
    classDef ops fill:#e9d5ff,color:#000,stroke:#6b21a8
    classDef ship fill:#dcfce7,color:#000,stroke:#166534
    classDef human fill:#fde68a,color:#000,stroke:#b45309,stroke-width:3px
    classDef branch fill:#fed7aa,color:#000,stroke:#9a3412,stroke-width:2px
```

**Key:**
- Yellow diamonds = non-skippable human checkpoints.
- Dashed-border phases (`perf-tester`, `reviewer`) run only at launch tier or above.
- The Ops subgraph is entirely skipped for `toy` / `preview`.

---

## 2. Producer / critic gate pattern

Every strategic artifact phase is paired with a critic gate. The critic
is a separate subagent on a different model — fresh context, no
monoculture.

```mermaid
flowchart LR
    Prod(["<b>Producer phase</b><br/>e.g. ceo / differentiation /<br/>product-spec / designer /<br/>ux-designer / pricing / positioning /<br/>tech-stack-selector"]):::prod

    Prod --> Art["openspec/context/*.md"]:::art

    Art --> Crit["<b>Critic subagent</b><br/>spawned via Task()<br/>different model from producer<br/>invokes /codex or hardcoded checklist"]:::crit

    Crit --> V{"CRITIC_VERDICT<br/>verdict: pass / fail<br/>must_fix · nice_to_have<br/>evidence_quality"}:::verdict

    V -->|"pass"| Adv(["Advance to<br/>next phase"]):::ok
    V -->|"fail · DRAFT"| Loop(["Loop producer<br/>with must_fix"]):::loop
    V -->|"fail · LOCKED"| Demote(["Demote to DRAFT<br/>+ loop producer"]):::loop

    classDef prod fill:#dbeafe,color:#000,stroke:#1e40af
    classDef art fill:#f3f4f6,color:#000,stroke:#374151
    classDef crit fill:#fef3c7,color:#000,stroke:#92400e
    classDef verdict fill:#1f2937,color:#fff,stroke:#fff
    classDef ok fill:#dcfce7,color:#000,stroke:#166534
    classDef loop fill:#fee2e2,color:#000,stroke:#991b1b
```

**Mechanism note:** critics are NOT separate skill folders — the
orchestrator spawns a `general-purpose` subagent per gate. The subagent
either invokes the `codex` skill (when present) or runs a per-phase
checklist embedded in `build-product-v2/SKILL.md`.

---

## 3. Scale-tier branching (what each tier skips)

The single most consequential branch in the pipeline. Default is
`preview` — the cheapest tier that still proves customer demand.

```mermaid
flowchart TB
    Q{"What's<br/>the goal?"}:::q

    Q -->|"Throwaway prototype"| Toy["<b>toy</b>"]:::toy
    Q -->|"Public demo · ≤100 users<br/>(DEFAULT)"| Prev["<b>preview</b>"]:::prev
    Q -->|"Paying customers<br/>single region"| Lau["<b>launch</b>"]:::lau
    Q -->|"Multi-region · enterprise"| Sca["<b>scale</b>"]:::sca

    Toy --> ToyS["SKIPS:<br/>perf-tester · reviewer ·<br/>legal-compliance · background-jobs ·<br/>env-manager · cicd · deployer ·<br/>observability · rollback · PRR<br/>(no public deploy)"]:::skip
    Prev --> PrevS["SKIPS:<br/>perf-tester · reviewer ·<br/>background-jobs · env-manager · cicd ·<br/>deployer · observability · rollback · PRR<br/>(deploys to Vercel / Fly preview)"]:::skip
    Lau --> LauS["SKIPS:<br/>production-readiness only<br/>(single region · no multi-region<br/>or enterprise deltas)"]:::skip
    Sca --> ScaS["SKIPS: nothing<br/>(full pipeline · multi-region ·<br/>read-replicas · OpenTelemetry)"]:::skipnone

    classDef q fill:#1f2937,color:#fff,stroke:#fff,stroke-width:2px
    classDef toy fill:#fee2e2,color:#000,stroke:#991b1b
    classDef prev fill:#fef3c7,color:#000,stroke:#92400e,stroke-width:2px
    classDef lau fill:#dbeafe,color:#000,stroke:#1e40af
    classDef sca fill:#dcfce7,color:#000,stroke:#166534
    classDef skip fill:#f3f4f6,color:#000,stroke:#374151
    classDef skipnone fill:#dcfce7,color:#000,stroke:#166534
```

`preview ⊂ launch ⊂ scale` — each higher tier is a strict superset of
the lower tier's phases. Terraform, BullMQ, PRR are opt-in, never
implicit.

---

## 4. Quality gates — 11 layers, strict order

`scripts/quality-gates.sh` runs gates in dependency order. Each gate
exits with the count of failed gates. Failures route via
`scripts/route-failure.sh --gate <gate> --area <path>` to the owner skill.

```mermaid
flowchart LR
    G1["typecheck"]:::gate --> G2["lint"]:::gate --> G3["seed-integrity"]:::gate
    G3 --> G4["unit"]:::gate --> G5["mutation<br/>≥70%"]:::gate --> G6["integration"]:::gate
    G6 --> G7["contract"]:::gate --> G8["e2e"]:::gate --> G9["a11y"]:::gate
    G9 --> G10["lighthouse<br/>≥80"]:::gate --> G11["visual"]:::gate
    G11 --> Pass(["✓ All gates passed"]):::pass

    classDef gate fill:#fef3c7,color:#000,stroke:#92400e
    classDef pass fill:#dcfce7,color:#000,stroke:#166534,stroke-width:2px
```

**Hard-fail thresholds:**
- `mutation` — score < 70% (env: `$MUTATION_THRESHOLD`)
- `lighthouse` — perf < 80 (env: `$LIGHTHOUSE_PERF_BUDGET`)
- `seed-integrity` — manifest missing, scripts missing, or non-idempotent seed
- After **3 failed attempts** on the same gate, escalate to user.

---

## 5. Failure routing — `route-failure.sh`

When a gate fails, the orchestrator routes the failure to the owning
skill, which loops with the gate output.

```mermaid
flowchart LR
    Fail(["Gate failure"]):::fail

    Fail -->|"typecheck · lint · unit"| Code["backend-developer<br/>or frontend-developer<br/>(based on --area path)"]:::skill
    Fail -->|"seed-integrity"| DBM["db-migrator"]:::skill
    Fail -->|"integration · contract"| BE["backend-developer"]:::skill
    Fail -->|"e2e"| E2E["e2e-tester<br/>(or feature owner via dogfood)"]:::skill
    Fail -->|"mutation"| Owner["owner of the<br/>untested module"]:::skill
    Fail -->|"a11y · lighthouse · visual"| FE["frontend-developer<br/>+ ux-designer"]:::skill
    Fail -->|"3rd attempt"| User(["Surface to USER"]):::user

    classDef fail fill:#fee2e2,color:#000,stroke:#991b1b,stroke-width:2px
    classDef skill fill:#dbeafe,color:#000,stroke:#1e40af
    classDef user fill:#fde68a,color:#000,stroke:#b45309,stroke-width:2px
```

---

## 6. Dogfood verdict routing

Dogfood (Phase 11) walks the wedge workflow in a real browser, scores
0–10, and routes the verdict back into the pipeline.

```mermaid
flowchart TB
    DF(["dogfood<br/>real browser walk<br/>score 0–10"]):::df

    DF --> V{"Verdict"}:::q

    V -->|"BLOCKED<br/>(seed/db broken)"| R1["→ db-migrator<br/>fix data layer"]:::route
    V -->|"SHIP<br/>(score ≥ 8)"| R2["→ perf-tester<br/>(launch+)<br/>or → pricing<br/>(toy/preview)"]:::route
    V -->|"POLISH<br/>(small UI gaps)"| R3["→ frontend-developer<br/>UI polish loop"]:::route
    V -->|"LOOP<br/>(workflow friction)"| R4["→ ux-designer<br/>+ frontend-developer"]:::route
    V -->|"RETHINK<br/>(wedge doesn't work)"| R5["→ designer<br/>(architectural rethink)"]:::rethink

    classDef df fill:#1f2937,color:#fff,stroke:#fff,stroke-width:2px
    classDef q fill:#fef3c7,color:#000,stroke:#92400e
    classDef route fill:#dbeafe,color:#000,stroke:#1e40af
    classDef rethink fill:#fee2e2,color:#000,stroke:#991b1b,stroke-width:2px
```

`RETHINK` is the only verdict that loops back to a strategic phase —
everything else loops within the build/UI layer.

---

## 7. State machine — `state/state.json` as blackboard

A single source of truth. The orchestrator reads it before every phase
and writes back after every phase.

```mermaid
flowchart LR
    subgraph Scripts ["scripts/"]
        SI["state-init.sh<br/>(bootstrap)"]:::script
        SS["state-set.sh<br/>(atomic writes)"]:::script
        SD["state-decide.sh<br/>(append ADR)"]:::script
        RF["route-failure.sh<br/>(gate → skill)"]:::script
    end

    subgraph S ["state/state.json"]
        direction TB
        K1["product_idea<br/>scale_tier<br/>current_phase"]:::field
        K2["wedge_sentence · icp ·<br/>axis · anti_axis"]:::field
        K3["phase_status[phase]<br/>critic_verdicts[phase]"]:::field
        K4["decisions[]<br/>open_issues[]<br/>kill_switches[]"]:::field
        K5["kpi_targets<br/>signal_sources<br/>(posthog · sentry · support)"]:::field
    end

    P(["Each phase subagent"]):::sub

    SI -->|"writes"| S
    P -->|"reads before run"| S
    P -->|"emits PHASE_RESULT"| SS
    SS -->|"merges into"| S
    P -->|"on decision"| SD
    SD -->|"appends to decisions[]<br/>+ state/decisions.md"| S
    S -->|"reads scale_tier · phase_status"| RF

    classDef script fill:#fef3c7,color:#000,stroke:#92400e
    classDef field fill:#dbeafe,color:#000,stroke:#1e40af
    classDef sub fill:#dcfce7,color:#000,stroke:#166534
```

**`PHASE_RESULT` block** (returned by every subagent):
```
phase · status · artifact_path · wedge_sentence (if set) ·
scale_tier (if set) · critic_required · open_issue_count · summary
```

The orchestrator never trusts the conversational text from a
subagent — only the structured `PHASE_RESULT` block is merged into state.

---

## 8. Iterate loop — signal-driven, weekly cadence

`signal-iterate` is the recurring loop after the public URL ships
(Phase 20 in the master pipeline). Unlike the older calendar-based
`iterate` skill, it starts from real user evidence — PostHog funnels,
Sentry errors, support inbox — and forces a single one-change-per-cycle
discipline.

```mermaid
flowchart TB
    Start(["signal-iterate<br/>weekly · recurring"]):::start

    Start --> P0["Phase 0<br/>Signal-source discovery<br/>(write state/signals.json)"]:::phase

    P0 --> Q0{"Any of<br/>PostHog · Sentry ·<br/>Support wired?"}:::q
    Q0 -->|"no"| Fall(["fallback → iterate skill<br/>(calendar-based · market re-scan ·<br/>gap analysis)"]):::fallback
    Q0 -->|"yes"| Sigs

    subgraph Sigs ["Phases 1-3 · 14-day signal window"]
        direction LR
        P1["1. Behavior<br/>wedge funnel ·<br/>activation hit-rate ·<br/>retention curve ·<br/>session recordings"]:::phase
        P2["2. Failure<br/>top issues ·<br/>crash-free trend ·<br/>slow p95 ·<br/>failed jobs"]:::phase
        P3["3. Voice<br/>support tickets ·<br/>NPS verbatims ·<br/>in-app feedback ·<br/>community sentiment"]:::phase
    end

    Sigs --> P4["Phase 4 · The One Question<br/>force ONE change that moves<br/>the leakiest funnel step ≥ 5pp<br/>(reject the other two with reasons)"]:::synth

    P4 --> P5{"Phase 5<br/>Kill switch<br/>tripped?<br/>(demand · build · defensibility)"}:::q

    P5 -->|"yes"| Kill(["STOP iteration loop<br/>rename change → iter-N-signal-kill-switch<br/>(skip_specs) · recommend: pivot · narrow ·<br/>shutdown → surface to user"]):::kill
    P5 -->|"no"| P6

    P6["Phase 6 · Plan & Implement<br/>deltas + tasks in the change<br/>validate --strict · spawn backend or<br/>frontend implementer"]:::phase

    P6 --> QG["quality-gates<br/>+ dogfood"]:::gate

    QG --> P7["Phase 7 · Instrument the test<br/>add PostHog event ·<br/>write success-metric query"]:::phase

    P7 --> P8["Phase 8 · Archive the change<br/>openspec/changes/archive/ is the log<br/>(N+1 measures the lift in its own<br/>reports: this is the self-correction)"]:::phase

    P8 --> Wait(["wait 14 days<br/>or until signals move"]):::wait
    Wait -.->|"next cycle reads<br/>last cycle's metric"| Start

    classDef start fill:#1f2937,color:#fff,stroke:#fff,stroke-width:2px
    classDef phase fill:#dbeafe,color:#000,stroke:#1e40af
    classDef synth fill:#fef3c7,color:#000,stroke:#92400e,stroke-width:2px
    classDef q fill:#fef3c7,color:#000,stroke:#92400e
    classDef gate fill:#d1fae5,color:#000,stroke:#065f46
    classDef wait fill:#f3f4f6,color:#000,stroke:#374151
    classDef fallback fill:#fed7aa,color:#000,stroke:#9a3412
    classDef kill fill:#fee2e2,color:#000,stroke:#991b1b,stroke-width:2px
```

**Key invariants:**
- **Signal hierarchy is strict** — behavior > failure > voice >
  market. Market re-analysis is only reached via the `iterate`
  fallback when no real signals exist.
- **One change per cycle** — Phase 4 is non-negotiable. Three plausible
  ideas → effort/impact matrix → pick one → write down *why* the other
  two are rejected (not "later").
- **`signal-iterate` is the only skill allowed to recommend killing the
  project** (Phase 5 kill-switch trip).
- **Self-correcting loop** — the "Measured lift" field is left blank
  this iteration; the next iteration's first job is to fill it in
  using the PostHog query stored from Phase 7.

---

## 9. Iterate loop — calendar-based fallback

`iterate` is the original refinement skill. It is the fallback path
from `signal-iterate` Phase 0 when no real user signals are wired —
useful pre-traction or for projects without telemetry. Unlike
`signal-iterate`, every cycle starts with a fresh market re-scan and
closes many gaps at once.

```mermaid
flowchart TB
    Start(["iterate<br/>per-invocation · calendar cadence"]):::start

    Start --> Setup["Setup · N = archived iter-* changes + 1<br/>open change iter-N-slug<br/>read last gap-analysis report"]:::phase

    Setup --> P1["Phase 1 · Market re-analysis<br/>WebSearch + WebFetch ·<br/>new competitors · trends ·<br/>pricing · regulatory · forums<br/>append Iteration N Update to<br/>openspec/context/product-analysis.md"]:::phase

    P1 --> P2sub

    subgraph P2sub ["Phase 2 · Gap analysis"]
        direction TB
        P2a["2a · Requirements vs impl<br/>scan FR-xxx / NFR-xxx ·<br/>classify Implemented · Partial ·<br/>Missing · Divergent"]:::phase
        P2b["2b · Design vs impl<br/>missing endpoints · model drift ·<br/>architectural deviation"]:::phase
        P2c["2c · New requirements from market<br/>derive · prioritize<br/>(must · should · nice)"]:::phase
        P2d["2d · Write change reports/gap-analysis.md<br/>coverage matrix + new-req table"]:::phase

        P2a --> P2b --> P2c --> P2d
    end

    P2sub --> P3["Phase 3 · Propose the change<br/>proposal · ADDED / MODIFIED / REMOVED<br/>deltas · design · tasks<br/>validate --strict"]:::phase

    P3 --> P4["Phase 4 · Implementation loop<br/>per task: implement →<br/>write/update tests →<br/>fix until green → mark ✅<br/>(do not advance until tests pass)"]:::phase

    P4 --> P5sub

    subgraph P5sub ["Phase 5 · Full verification"]
        direction TB
        V1["5a · unit + integration + smoke<br/>+ lint"]:::gate
        V2["5b · E2E (Playwright)<br/>add new tests for new features"]:::gate
        V3["5c · security re-check<br/>npm audit · grep secrets / SQLi /<br/>XSS · auth on new endpoints"]:::gate
        V4["5d · perf spot-check<br/>bundle size · N+1 ·<br/>missing indexes · pagination"]:::gate
        V5["5e · final confirmation<br/>0 failures · 0 new High CVEs ·<br/>no major regressions"]:::gate

        V1 --> V2 --> V3 --> V4 --> V5
    end

    P5sub --> P6["5g–5h · reports/verification.md<br/>snapshot traceability · archive<br/>(the archived change is the log)<br/>git commit + push"]:::phase

    P6 --> Done(["next invocation<br/>= iteration N+1"]):::start

    classDef start fill:#1f2937,color:#fff,stroke:#fff,stroke-width:2px
    classDef phase fill:#dbeafe,color:#000,stroke:#1e40af
    classDef gate fill:#d1fae5,color:#000,stroke:#065f46
```

### Side-by-side comparison

| Dimension | `iterate` | `signal-iterate` |
|---|---|---|
| Trigger | per-invocation, ad-hoc | weekly · or when signals move |
| Starting point | market re-scan (imagination) | user behavior (evidence) |
| Required inputs | spec docs + shipped product | shipped product + ≥1 wired signal source |
| Scope per cycle | many gaps closed | **one change**, alternatives rejected with reasons |
| Output artifact | change `iter-N-<slug>` (+ `reports/gap-analysis.md`) | change `iter-N-signal-<slug>` (proposal = the one change + PostHog query) |
| Kill authority | none | **can recommend pivot / shutdown** |
| Self-correction | next run reads the last archived gap analysis | N+1 measures last cycle's lift in its own `reports/` |
| When to use | pre-traction · no telemetry | post-traction · real users |
| Pipeline role | fallback when no signals exist | canonical Phase 20 recurring loop |

The key inversion: `signal-iterate` ignores market re-analysis until
behavior, failure, and voice signals are exhausted. `iterate` starts
from market re-scan every cycle — fine when there are no users yet,
counterproductive once there are.

---

## 10. Skills inventory by phase

35 skills total. Bold = critic gate exists.

| Phase group | Skills |
|---|---|
| **Strategy** | **ceo** · **differentiation** · **tech-stack-selector** · **product-spec** |
| **Design** | analyst · **designer** · **ux-designer** |
| **Setup** (conditional) | auth-engineer · ai-features (if `ai_heavy=true`) · email-templates (if needed) |
| **Build** (parallel) | backend-developer · frontend-developer · db-migrator |
| **QA** | api-docs · e2e-tester · adversarial-tester · security-auditor |
| **Live** | dogfood · perf-tester *(launch+)* · reviewer *(launch+)* |
| **GTM** | **pricing** · **positioning** · landing-page · legal-compliance |
| **Ops** (launch+) | background-jobs · env-manager · cicd · deployer · observability · rollback · production-readiness *(scale only)* |
| **Iterate** | analytics · signal-iterate · iterate |
| **Orchestration** | build-product-v2 |

---

## 11. The four human checkpoints (verbatim)

| # | After phase | Confirms |
|---|---|---|
| **HC1** | `differentiation` (2c) | wedge · ICP · scale tier · stack constraints |
| **HC2** | `ux-designer` (6c) | design target — competitor teardown + wireframes |
| **HC3** | `positioning` (12) | tiers · prices · headline · trial mechanic |
| **HC4** | `preview-ship` (19) | GO / NO-GO before public URL |

These are the only points where the pipeline pauses for the user.
Everything else loops within the orchestrator.

---

## 12. Discrepancies vs `CLAUDE.md`

The one-screen summary in `CLAUDE.md` reads cleanly but compresses
some details. Verified differences:

- **`legal-compliance` placement** — `CLAUDE.md` shows it after
  `landing-page`; the SKILL.md confirms this (Phase 13.5) and adds the
  `regulated / eu_global_billing` hard-fail rule.
- **`reviewer` is launch+ only** — `CLAUDE.md` lists it as
  `launch+ only` correctly; SKILL.md confirms phase 11.7.
- **Quality-gate count** — `CLAUDE.md` says "typecheck → lint → unit →
  mutation → integration → contract → e2e → a11y → lighthouse → visual"
  (10 gates). The actual script runs **11** — `seed-integrity` sits
  between `lint` and `unit`.
- **`signal-iterate` cadence** — `CLAUDE.md` says "recurring";
  SKILL.md specifies **weekly schedule** driven by PostHog / Sentry /
  support signals.

Everything else in `CLAUDE.md` matches source.
