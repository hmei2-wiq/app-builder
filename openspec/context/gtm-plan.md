# GTM Execution Plan: The Build Loop

**Date:** 2026-06-02
**Basis:** `openspec/context/product-analysis.md` (2026-05-29). Strategy is settled there;
this doc is execution only.
**2026-06-04 (CEO review):** This services-first motion is **confirmed as the
opening move.** The PLG/self-serve alternative (`openspec/context/shipworthy-strategy.md`)
is sequenced as **Phase 2**, funded by the revenue this plan produces. Two PLG
ideas are pulled forward into this plan now because they are near-zero COGS and
strengthen *this* motion: the free **"Is your app Shipworthy?" audit scanner**
as top-of-funnel, and the repo-tier→price mapping as the productization target.

> **The one job of the next 90 days:** prove that the lead ICP will *pay* for the
> business layer before we build any self-serve product. Everything below is
> sequenced to retire **Risk #3 (demand-side bet)** first and cheapest, and to
> instrument **Risk #1 (platform/substrate)** as a standing kill-switch.

---

## 0. The decision this plan forces

The analysis recommends: domain-expert solopreneur ICP, productized
"business-in-a-week" service, offer ladder Validate $499 → Launch $2.5K+$99/mo →
Scale $8K+$499/mo, proof via a public as-built gallery, service motion first /
SaaS later.

We are **not** re-deciding any of that. We are running the smallest sequence of
moves that produces a binary answer: **5 paid Validate + 1–2 paid Launch
customers in 90 days, or we pivot the ICP/offer.**

---

## 1. Critical insight — sell before you build

The biggest GTM mistake here would be to keep hardening the orchestrator. The
orchestrator is *already* leverage; it is not the bottleneck. **Distribution and
willingness-to-pay are.** So the first dollar of effort goes to demand, not code:

- **Sell the $499 Validate tier by hand, this month, to real people.** No
  funnel, no landing page automation, no SaaS. DM + 1:1 sales call + manual
  delivery using the existing skills as private leverage.
- A paid $499 is the cleanest signal we can buy. A free pilot proves nothing
  about WTP (Risk #3). Charge from customer #1; comp it *after* if the build
  flops, but quote the price first.

---

## 2. Workstreams (run in parallel)

### A. Demand validation sprint — *owner: founder, weeks 1–6*
1. Build a list of **40 named domain-expert solopreneurs** (coaches,
   consultants, clinicians, niche creators, 1K–50K audience) you can reach
   warm or 1-degree-out.
2. Write the **one-call pitch** off the wedge sentence: *"Bring your method,
   leave with a priced, positioned, deployed, legal product in a week."*
3. Book **15 sales calls**, sell the **$499 Validate** (strategy-only:
   wedge + pricing + positioning doc, no build). Validate doubles as the
   qualifier for Launch.
4. **Gate (end wk 6):** ≥5 paid Validate. If <3 → the ICP or the offer is
   wrong; stop and re-run `differentiation` on a different persona (P2
   "shipped-a-Lovable-MVP, now stuck" is the designated fallback).

### B. Proof engine — *owner: founder, weeks 2–10*
1. Convert **1–2 Validate buyers into Launch ($2.5K + $99/mo)** — full deployed
   product using the pipeline end-to-end.
2. Stand up the **public as-built gallery**: live customer URL + a redacted
   wedge/pricing one-pager per build. This is the single most credible asset we
   own; ship it as soon as build #1 is live.
3. Capture a **before/after testimonial** (video or written) per Launch
   customer. Testimonials are the conversion lever for calls in workstream A.

### C. Channel test — *owner: founder, weeks 3–12*
- Run **exactly one** top-of-funnel channel hard, don't spread thin. Rank:
  1. **YouTube/long-form "idea → live URL in 60 min"** live builds (highest-
     signal demo of the wedge; doubles as sales collateral).
  2. **"Shipped-with-Lovable, now what" SEO/content** aimed at P2.
- Pick #1 unless you have an existing content audience that makes #2 cheaper.
- **Avoid Product Hunt / HN** for this motion — wrong audience, will reject the
  "done-for-you business" framing.
- **Gate (wk 12):** one channel showing a repeatable cost-per-booked-call.

### D. Platform-risk watch — *owner: founder, continuous*
- Standing monitor on Anthropic (Agent Teams, Agent SDK, `/goal`), OpenAI Codex,
  GitHub Copilot, **and Lovable's roadmap**.
- **Pre-declared kill-switch:** if an incumbent ships *strategy-artifacts +
  signal-driven iteration* as a first-party feature within 6 months, we stop
  selling the orchestrator-as-leverage story and re-anchor entirely on
  vertical brand + service relationship + gallery (the only non-copyable moat).

---

## 3. 90-day timeline

| Weeks | Focus | Exit gate |
|---|---|---|
| 1–2 | List of 40; pitch + call script; price the offer | 15 calls booked |
| 3–6 | Sell Validate; start channel #1; first live build | **≥5 paid Validate** |
| 7–10 | Convert to Launch; ship the gallery; testimonials | **1–2 paid Launch + gallery live** |
| 11–12 | Double down on the working channel; write the playbook | Repeatable cost-per-call; go/no-go decision |

**90-day target (from the analysis):** 5 Validate + 1–2 Launch. *Signal over
revenue.* Revenue scale is the 90–180 day phase, not this one.

---

## 4. Metrics that decide go / pivot / kill

| Metric | Go | Pivot ICP/offer | Kill |
|---|---|---|---|
| Paid Validate @ $499 (wk 6) | ≥5 | 1–4 | 0 after 15 calls |
| Validate → Launch conversion | ≥1 in 5 | <1 in 5 → fix the build/handoff | — |
| Call → Validate close rate | ≥30% | 10–30% → fix pitch | <10% → wrong ICP |
| Platform-risk event (workstream D) | none | — | incumbent ships the loop |

---

## 5. Explicitly NOT in the next 90 days

Deferred until the service motion produces 15–25 referenceable builds
(per the analysis's 6–18 month phase):

- The thin self-serve SaaS layer / plain-English orchestrator UI.
- The P4 agency-reseller B2B line (parallel motion *after* proof).
- The cohort/workshop (it's a 90–180 day case-study factory, not a wk-1 move).
- Paid acquisition. Validate the organic channel economics first.

---

## 6. Immediate next actions (this week)

1. Draft the 40-name target list and the one-call pitch.
2. Lock the offer ladder copy and set up a way to take a $499 payment (Stripe
   payment link — no product build needed).
3. Run the first `differentiation` pass to pin the *exact* wedge sentence for
   the chosen sub-niche (feeds the pitch). → `openspec/context/wedge.md`.
4. Stand up the empty as-built gallery shell so build #1 can drop straight in.
