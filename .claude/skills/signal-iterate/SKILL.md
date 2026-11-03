---
name: signal-iterate
description: Signal-Driven Iteration — replaces calendar-based `iterate` with a loop driven by REAL user signals (PostHog funnels, Sentry errors, support inbox, top-of-funnel analytics). Prioritizes the next iteration based on what users actually do, not what the model thinks the market wants.
argument-hint: "[optional: signal source override, e.g. 'posthog' or 'sentry-only']"
allowed-tools: WebSearch, WebFetch, Read, Write, Edit, Bash, Glob, Grep
effort: max
---

# Role: Signal-Driven Iteration Engineer

> **Context files may live elsewhere.** Resolve each `openspec/context/<name>.md`
> path below with `scripts/context-path.sh <name>` and read the path it prints
> (it falls back to the legacy `docs/` name or a `state.json` `.context_paths`
> override). Exit 1 means the file is missing: apply this skill's missing-file
> rule. Before writing one, run `scripts/context-path.sh --move <name>`.
> Conventions: `.claude/skills/build-product-v2/openspec-conventions.md` §1.

You are running the iteration loop *after* the product is in front of
real users. Unlike the original `iterate` skill (which re-scans the
market and runs gap analysis from imagination), you start from
**evidence**: what users did, what broke, what they asked for.

The hierarchy of signal quality:

1. **What users *did*** (PostHog funnels, session recordings, retention)
2. **What broke** (Sentry / observability errors, failed jobs, 5xx)
3. **What users *said*** (support tickets, NPS comments, in-app feedback)
4. **What the market is doing** (competitor launches — last priority)

This skill ignores #4 unless 1–3 are exhausted. That inversion is
the whole point.

**Optional signal source override:** $ARGUMENTS

---

## Inputs

Required:
- `openspec/context/wedge.md` — wedge sentence, ICP, kill switches
- `openspec/context/product.md` — KPI targets
- `openspec/specs/**` — current requirements (`openspec list --specs --json`);
  conventions in `.claude/skills/build-product-v2/openspec-conventions.md`
- A deployed product with at least one real signal source wired

Recommended:
- The last archived signal change (`openspec/changes/archive/*-iter-*-signal-*/`)
  — its `proposal.md` Success Metric (query, predicted lift, kill
  criterion) is what this run measures first
- `state/state.json` — KPI targets, kill switches
- Environment variables: `POSTHOG_API_KEY`, `SENTRY_API_TOKEN`,
  `SUPPORT_INBOX_URL` (where applicable)

---

## Phase 0 — Open the Change, Discover Signal Sources

Everything this run produces lives in one OpenSpec change
(conventions: `.claude/skills/build-product-v2/openspec-conventions.md`
§1, §4). It is opened now under a provisional name and renamed in
Phase 4 once the one change is known.

```bash
export OPENSPEC_TELEMETRY=0 DO_NOT_TRACK=1 OPENSPEC_NO_UPDATE_CHECK=1
OPENSPEC="npx --yes @fission-ai/openspec@1.15.0"
N=$(( $(ls -d openspec/changes/archive/*-iter-* 2>/dev/null | wc -l) + 1 ))
CHANGE="iter-$N-signal"
$OPENSPEC new change "$CHANGE"
scripts/state-set.sh '.active_change' "\"$CHANGE\""
REPORTS="openspec/changes/$CHANGE/reports"; mkdir -p "$REPORTS"
```

Detect available signal sources. For each, record availability and
freshness in `state/signals.json`:

```bash
# PostHog
[ -n "$POSTHOG_API_KEY" ] && curl -fsS \
  "https://app.posthog.com/api/projects/@current/" \
  -H "Authorization: Bearer $POSTHOG_API_KEY"

# Sentry
[ -n "$SENTRY_API_TOKEN" ] && curl -fsS \
  "https://sentry.io/api/0/projects/" \
  -H "Authorization: Bearer $SENTRY_API_TOKEN"
```

If none of #1–#3 are wired, stop and emit:
> ERROR: no real signals available. Wire at minimum PostHog or Sentry,
> then re-run. (Falling back to market re-analysis bypasses the point
> of this skill — invoke `iterate` instead.)

---

## Phase 1 — Behavior Signals (PostHog / analytics)

Pull these for the last 14 days (configurable):

### 1a. Wedge funnel performance

The wedge workflow from `openspec/context/wedge.md` is a funnel. For each step,
fetch the conversion rate from the previous step. Flag any step with
< 50% step-conversion as a leak.

```
signup → activation event → wedge step 2 → wedge step N → paid
```

Top three leaks become candidate problems.

### 1b. Activation event hit-rate

The activation event from `openspec/context/pricing.md` Phase 4 is the moment of
proven value. Cohort by signup-day; what fraction reach activation
within 24h, 72h, 7d?

Targets (sanity defaults):
- 24h activation ≥ 30%
- 7d activation ≥ 50%

### 1c. Retention curve

Day-1, day-7, day-30 retention. A "smile curve" (drops then rises)
is the gold standard; "death curve" (drops then flatlines at 0) is
a wedge problem.

### 1d. Session recordings (sample 10)

Watch (read transcripts of) 10 sessions of users who:
- Hit activation (5 sessions): what does *winning* look like?
- Bounced after signup (5 sessions): where did they get stuck?

Note: this requires PostHog session recordings or equivalent. If not
wired, skip and note `[Sampled = 0]`.

### 1e. Previous change outcome

If a previous signal change exists, run its Success Metric query and
record the measured lift against its predicted lift and kill
criterion. A lift below the kill criterion makes reverting that change
a candidate in Phase 4. (The archived change is never edited; its
outcome is recorded here.)

Write findings to `$REPORTS/signals-behavior.md`, starting with
`## Previous change outcome`.

---

## Phase 2 — Failure Signals (Sentry / observability)

Pull last 14 days:

- Top 10 issues by event count
- Top 10 issues by user count (different — a single high-value user
  hitting one bug 100 times is different from 100 users hitting it once)
- New issues introduced in the last 7 days
- Crash-free rate trend
- Slow endpoint p95 (from observability)
- Failed background jobs (from job queue)

For each top issue, classify:

| Class | Action |
|---|---|
| **Wedge-blocking** | Must fix this iteration. Stop everything else. |
| **Conversion-leaking** | Fix this iteration if behavior signal confirms |
| **Cosmetic** | Add to backlog |
| **Third-party flake** | Suppress filter; do not iterate |

Write to `$REPORTS/signals-failure.md`.

---

## Phase 3 — Voice Signals (support / NPS / inbox)

For each channel available:

- **Support tickets** — categorize last 30 by theme (5 buckets max)
- **NPS comments** — pull verbatims, separate promoter / detractor / passive
- **In-app feedback widget** — same
- **Discord / Slack / community** — pull last 100 messages, sentiment-tag

The thing to watch for: **the same complaint phrased three different
ways**. That is a real signal. A complaint mentioned once is noise.

Write to `$REPORTS/signals-voice.md`.

---

## Phase 4 — Synthesize: The One Question

Force a single answer to:

> **What is the one change that, if shipped this iteration, would move
> the most-leaking step of the wedge funnel by ≥ 5 percentage points?**

Not five changes. Not "three buckets." One.

If you can't name one, you don't have enough signal — go back to
Phase 1 and pull more, or extend the window.

If you can name three plausible changes, run a tiny effort/impact
matrix (1–5 each), pick the highest impact / lowest effort, and
write down explicitly *why the other two were rejected this iteration*
(not "we'll get to them" — *why* they're not the answer).

Name the slug and rename the change (before any validate):

```bash
mv "openspec/changes/$CHANGE" "openspec/changes/iter-$N-signal-<slug>"
CHANGE="iter-$N-signal-<slug>"; REPORTS="openspec/changes/$CHANGE/reports"
scripts/state-set.sh '.active_change' "\"$CHANGE\""
```

Then write `openspec/changes/$CHANGE/proposal.md` (conventions §5) —
this is the only place the one change is written down:

```markdown
# Proposal

## Why
<wedge sentence> — <leaking funnel step: current % → target %; links to reports/signals-*.md>

### Rejected alternatives (and why not now)
1. <alt 1> — rejected because <reason>
2. <alt 2> — rejected because <reason>

## What Changes
- <the one change, one paragraph or story line>

## Capabilities
### New Capabilities
### Modified Capabilities
- `<capability>`: <what requirement changes>

## Success Metric
- Funnel step: <step name from wedge workflow>
- Predicted lift: <X pp, with reasoning>
- Query: <PostHog HogQL or insight URL — filled in Phase 7>
- Kill criterion: <lift threshold below which we revert>

## Impact
<surfaces touched>
```

---

## Phase 5 — Kill Switch Check

Re-read kill switches from `openspec/context/wedge.md`. For each:

- **Demand kill** — do current signals trip it? (e.g. trial-to-paid
  rate below threshold for 30 days)
- **Build kill** — has the wedge workflow proven undeliverable?
- **Defensibility kill** — has a top-3 incumbent shipped the wedge?

If any kill switch is tripped, **stop the iteration loop entirely**.
Record the decision as a no-behaviour change so it sits in history
with its evidence:

```bash
mv "openspec/changes/$CHANGE" "openspec/changes/iter-$N-signal-kill-switch"
CHANGE="iter-$N-signal-kill-switch"
echo 'skip_specs: true' >> "openspec/changes/$CHANGE/.openspec.yaml"
```

Write its `proposal.md`: Why = which kill switch tripped and the
numbers (link `reports/signals-*.md`); What Changes = the
recommendation (pivot, narrow further, or shut down); no capabilities.
Validate, surface to the user, and archive with
`$OPENSPEC archive "$CHANGE" --yes --skip-specs` only after the user
confirms the decision.

This is the only skill that is allowed to recommend killing the
project.

---

## Phase 6 — Plan & Implement

The one change is the change opened in Phase 0 and named in Phase 4;
its `proposal.md` is already written.

- **`specs/<capability>/spec.md`** — the behaviour change as ADDED or
  MODIFIED requirements (`Source: iter-N signal`). A pure copy or
  layout tweak with no behaviour change sets `skip_specs: true` in the
  change's `.openspec.yaml` instead.
- **`tasks.md`** — the implementation task(s) plus the Phase 7
  instrumentation task (`[frontend]`/`[backend]` → `implements:` IDs).
- `$OPENSPEC validate "$CHANGE" --strict --no-interactive` must pass.

Spawn the implementer (`backend-developer` or `frontend-developer`
depending on the change) against the change's tasks. Run quality gates
(including `spec-validate` and `traceability`) and `dogfood` after.
When green and deployed:

```bash
scripts/spec-coverage.sh && cp reports/traceability.md "$REPORTS/traceability.md"
$OPENSPEC archive "$CHANGE" --yes        # add --skip-specs if skip_specs: true
scripts/state-set.sh '.active_change' 'null'
scripts/state-decide.sh signal-iterate "archived $CHANGE" "<one change; predicted lift>"
```

Iteration N+1 measures the lift (Phase 1e) and records it in its own
`reports/signals-behavior.md`; the archived change stays as shipped.

Do NOT bundle other changes into this iteration. Resist scope creep
— the discipline is half the point.

---

## Phase 7 — Instrument the Test

Before shipping, add the analytics event that will measure success.
The success metric from Phase 4 must be queryable in PostHog within
24 hours of deploy.

Write the exact PostHog query (HogQL or insight URL) into the
change's `proposal.md` `## Success Metric` → Query. This is what
`signal-iterate` iteration N+1 reads first.

---

## Phase 8 — Record

There is no separate iteration log. The archived change
(`openspec/changes/archive/<date>-iter-<N>-signal-<slug>/`) holds the
proposal (one change, rejected alternatives, predicted lift, query,
kill criterion), the deltas, the tasks and the signal reports. Its
status is the state of the change: active (proposed / implemented) or
archived (deployed); the measured lift arrives with iteration N+1.

---

## Git Commit & Push

```bash
git add openspec/
git commit -m "feat: iteration N — signal-driven, ship the one change"
git push origin HEAD 2>/dev/null || git push --set-upstream origin HEAD 2>/dev/null || true
```

---

## Completion summary

```
## Signal-driven iteration N complete

- Signal sources:        <list, with freshness>
- Top leak step:         <step name>, <current%> → <target%>
- The one change:        <one line>
- Predicted lift:        <X pp>
- Kill switches:         <0 tripped | N tripped → STOP>
- Implemented:           <yes | no>
- Measurement query:     <PostHog URL or HogQL>
- Re-run in:             <14 days, or sooner if signals move>
```
