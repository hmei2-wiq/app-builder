# Pricing — Shipworthy

**Date:** 2026-06-04
**Basis:** `openspec/context/shipworthy-strategy.md`. Pricing model matches the
differentiation axis (**production-grade + scale-readiness**), not build speed.
**Status:** Draft for the PLG-first track. Pending reconciliation with the
services-first ladder in `openspec/context/gtm-plan.md`.

---

## 1. Pricing principle

We monetize the **journey from prototype to scale**, not the act of building.
Generation is free and commoditized; willingness-to-pay spikes at the
*transition* moments (trial ends, real users arrive, custom domain needed,
"it must not leak"). Price each tier to that moment.

Anchor **above** the generation tools ($20-25): Lovable/Bolt/Replit/v0 sell
build credits; we sell *won't-get-hacked, won't-fall-over*. Parity pricing
would mis-anchor us as a clone.

---

## 2. Tiers

### Ideation / Preview — **$0** (14-day trial)

Maps to repo tier `preview`. The activation funnel.

**Included**
- Unlimited ideation chat → spec → prototype
- 1 live preview deployment (≤30 min to URL)
- Shared `*.shipworthy.app` subdomain
- Capped build credits / month
- Basic hardening report (read-only "what's unsafe")

**Hard limits (COGS protection — non-negotiable)**
- 14-day preview lifetime, then auto-sleep
- Idle preview apps auto-sleep after 48h no traffic
- Monthly credit cap on LLM generation
- No custom domain, no production guarantees

**Goal:** activation + the "you have real users now" upgrade trigger.

---

### Launch — **$49 / mo** (+ metered overage)

Maps to repo tier `launch`. The recurring-revenue engine.

**Included**
- Everything in Preview, uncapped lifetime
- **Unified managed hosting** on commodity infra (per-tenant metered)
- Custom domain + managed TLS
- **Full production hardening:** RLS enforcement, auth, secret scanning,
  11-layer quality gates, security-auditor + adversarial-tester pass
- Monitoring + error tracking + health checks
- Autoscale within caps; spend guardrails (DDoS / bot cost protection)
- Minimal support (async, best-effort SLA)

**Metered overage (transparent, per-tenant)**
- LLM generation credits beyond plan allotment
- Bandwidth / egress beyond included quota
- Compute beyond the autoscale cap

**Why $49 and not $25:** the value is risk removal, not build throughput.
$49 stays an easy solo-founder yes while signaling a different category.

---

### Scale — **Consulting retainer + usage** ($3k–$10k / engagement)

Maps to repo tier `scale`. High-touch; margin + enterprise lead-gen.

**Included**
- Multi-region / enterprise architecture
- Full pipeline with human-in-the-loop (perf-tester, production-readiness
  review, observability, rollback, env separation)
- Dedicated consult: migration, load testing, compliance (GDPR/SOC2 path)
- Priority support + onboarding

**Pricing shape**
- Engagement fee $3k–$10k depending on scope
- Ongoing usage billed on the Launch metering model (higher caps)
- Optional retainer for continued scale support

**Why consulting, not a SaaS tier:** at scale the work is genuinely bespoke,
willingness-to-pay is high, and each engagement teaches us what to productize
next. It does not need to scale — it funds and informs the product.

---

## 3. Conversion triggers (where money flows)

| Trigger | From → To |
|---|---|
| 14-day trial ends | Preview → Launch |
| First real users / traffic | Preview → Launch |
| Needs custom domain | Preview → Launch |
| Hardening report shows a leak | Preview → Launch |
| Traffic spike hits autoscale cap | Launch → Scale |
| Multi-region / compliance / enterprise buyer | Launch → Scale |

---

## 4. Unit-economics guardrails

The free tier is the existential COGS variable. Launch margin only holds if:

1. **Metering ships day one** — token + egress + compute per tenant.
2. **Auto-sleep is enforced** on idle preview *and* idle Launch background work.
3. **Hosting runs on commodity infra**, not retail PaaS markup.
4. **Spend guardrails** cap runaway bills (bot/DDoS) before the customer — or we
   — get a surprise invoice.

If any of these slips, the free→Launch funnel runs at negative gross margin.

**Modeled (see `scripts/cogs-model.sh --sweep`).** The dominant lever is *not*
conversion rate — it is **cost per ideation run**. At a cheap ~$0.50/run the
funnel is healthy (>3× LTV:CAC) even at 1% conversion; at an Opus-heavy
~$3.00/run you need ~3% conversion just to clear 3×, and 1% goes underwater.
**Implication:** ideation must run on a cheaper/cached model with hard credit
caps — the free tier's viability is a *model-cost* decision, not a marketing
one. Re-run the model with real token costs before the Phase 2 greenlight.

---

## 5. Open questions for the pricing gate

- Credit cap sizing on free: generous enough to reach the "wow," tight enough to
  protect COGS — needs a real token-cost model.
- Launch overage: clear per-unit pricing vs. opaque "credits"? (We criticize
  competitors' opacity — we should be transparent.)
- Annual discount on Launch (cash + retention) vs. monthly-only simplicity.
- Where exactly the Launch autoscale cap sits before forcing a Scale conversation.
