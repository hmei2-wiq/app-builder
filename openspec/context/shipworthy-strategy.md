# Shipworthy — Market Analysis & PLG Strategy

**Date:** 2026-06-04
**Author:** CEO / market-strategist pass
**Status:** **RECONCILED (2026-06-04, CEO review).** This PLG track is **not**
the opening move. Decision: **sequence, don't fork** — run the services-first
motion in `openspec/context/gtm-plan.md` for the next 90 days (cash-positive, retires
demand risk before spending AI tokens), and treat this document as the
**Phase 2 productization target**, funded and de-risked by services revenue.

Adopted from this doc **now** (near-zero COGS, serves both motions):
- the free **"Is your app Shipworthy?" audit scanner** as shared top-of-funnel;
- the **repo-tier → price mapping** as the productization blueprint;
- **continuity / unified runtime** as the stated long-term moat.

Deferred to **Phase 2** (only after services proves demand): free full
ideation + preview, the $49/mo self-serve Launch tier, and the self-serve
hosting/metering plane.

> **Headline:** Let generation be free and commoditized. Own the chasm
> between a working prototype and real paying users — where the pain is acute,
> the incumbents are absent, and willingness-to-pay is highest. Monetize the
> *journey to scale*, not the act of building.

---

## 1. Market read

The no-code / AI app-builder market was ~$6.6B in 2025, heading to ~$75B by
2034 (~31% CAGR). 63% of users have **no coding background** — the buyer base
is real and expanding fast. But the **generation layer is already won** by
well-funded incumbents, and competing there is a losing knife fight:

| Player | Traction (2026) | Model |
|---|---|---|
| Lovable | $0→$200M ARR in 12 mo; $6.6B valuation (Dec 2025) | $25/mo, exportable code |
| Base44 (Wix) | $100M ARR 9 mo post-acquisition; 2M users | Fully managed, all-in-one |
| Bolt.new | $20/mo, 10M tokens | Token-metered |
| Replit | $20-25 base; heavy users $100-300/mo | Effort-based |
| v0 (Vercel) | Credit-metered | Tied to Vercel deploy |

**We cannot win "build faster / cheaper."** That race is over and the prizes
are taken.

### The unowned gap: production & scale

The evidence that the *back half* of the loop is wide open is overwhelming:

- **~1 in 10 leaking data:** 170 of 1,645 audited Lovable apps shipped with
  broken/missing row-level security, exposing real user data publicly —
  without the founder knowing.
- Of **380,000** AI-generated apps scanned, ~5,000 were publicly reachable
  with **no auth**; ~40% of those held sensitive data.
- 41% of AI-generated backends ship over-broad permissions; 60% of devs never
  adjust scopes before deploy.
- Production incidents per PR rose **23.5%** (Dec 2025 → early 2026) as AI code
  volume outran testing discipline.
- Consensus diagnosis: *"a vibe-coded app is a prototype with the appearance
  of a finished product"* — and most never ship.

**Strategic truth:** everyone gives away a prototype; nobody safely carries it
to real users. That is exactly what this repo's pipeline already does
(security-auditor, quality-gates, RLS/dogfood, production-readiness,
observability, adversarial-tester). **The pipeline is a production-hardening
machine, not a code generator.** That is the differentiation axis.

---

## 2. The strategy

**Differentiation axis:** *production-grade + scale-readiness* (not build speed).

**One line:** *"Lovable gets you the demo. Shipworthy gets you to real users —
without the 3am data leak."*

### Three pillars

1. **Free ideation + 30-minute preview is the right Trojan horse — but it is
   also the most expensive COGS** (LLM tokens + hosting are precisely the free
   part). Cap it hard: 2-week trial **plus** credit caps **plus** auto-sleep on
   idle preview apps. Unbounded free bankrupts us faster than any competitor.

2. **Unified, cheap, multi-tenant hosting is the real moat** (and is currently
   underrated in our own docs). A single runtime on commodity infra
   (Fly.io / Cloudflare / Hetzner-class — *not* Vercel retail) lets us:
   (a) offer free preview without bleeding,
   (b) meter tokens + egress per tenant for clean unit economics,
   (c) **own the upgrade path** so the customer never "migrates to scale" — they
   change a tier. Lovable/Bolt hand over exportable code and wash their hands;
   we keep the user on rails from idea → scale. **That continuity is the
   product.**

3. **Charge on the transition, not the tool.** The conversion trigger is a
   *moment*, not a feature: trial ends, you got real users, you need a custom
   domain, you need it to not leak data. Money flows when value is undeniable.

### Mapping to the repo's scale tiers

The existing `toy / preview / launch / scale` tiers (see root `CLAUDE.md`) map
1:1 to the commercial tiers below — the machinery already exists.

---

## 3. Pricing (summary; full spec in `openspec/context/pricing.md`)

| Tier | Repo tier | Price | What | Goal |
|---|---|---|---|---|
| **Ideation / Preview** | preview | $0, 2-wk trial | Unlimited ideation, prototype, 1 preview deploy, capped credits, auto-sleep | Activation |
| **Launch** | launch | **$49/mo** + metered overage | Unified hosting, custom domain, full hardening (RLS/security/quality gates/monitoring), autoscale caps, minimal support | Recurring revenue |
| **Scale** | scale | **Consulting retainer + usage** ($3-10k/engagement) | Multi-region, enterprise, full pipeline, human-in-loop | Margin + enterprise lead-gen |

Price Launch **above** the $20-25 generation tools. We don't compete on build
cost — we sell "won't get hacked, won't fall over." $49 is defensible; $25
anchors us as a Lovable clone.

---

## 4. Name

Naming in this space is crowded; the right name signals the wedge
(*production-grade, survives real users*), not "build."

| Name | Rationale |
|---|---|
| **Shipworthy** ✅ | Literally "ready for real users" — seaworthy for production. On-thesis, ownable, memorable. **Recommended.** |
| Keel | What keeps a ship stable as it scales — strong metaphor, but crowded (.dev/.so taken). |
| Liftoff | Momentum, idea→scale — but overused (Mailchimp, others). |
| Graduate | App graduates prototype→product — clear, softer. |

**Recommendation: Shipworthy.** It names the exact promise the whole market is
failing to deliver — and it's the one word a non-technical founder understands
instantly the day their Lovable app leaks data.

---

## 5. How to sell it (GTM)

- **Lead with fear + relief, not features.** Top-of-funnel is a free
  **"Is your app Shipworthy?" scanner** that checks RLS / auth / secrets on
  *any* deployed URL (yours or a Lovable/Bolt one). It generates the leak stat
  for *their* app. This is the viral wedge, the best ad, and it weaponizes the
  exact industry research above.
- **Bottom-up, founder-led PLG.** Free ideation → preview → the trial-end /
  "you have real users now" moment converts to Launch. No sales team for the
  first two tiers.
- **Sell the continuity, not the generation.** Demo idea → deployed → hardened
  in one session; the punchline is *"you never had to migrate, configure infra,
  or hire DevOps."*
- **Scale tier is high-touch and that's fine** — it doesn't need to scale; it's
  margin and the enterprise pipeline. Each consult teaches us what to
  productize next.
- **Distribution rides incumbents' weakness:** "Lovable alternative for
  production," "make your Bolt app secure," comparison content, with the audit
  scanner as the SEO/social engine.

---

## 6. Risks & open tensions

1. **Fork with the settled strategy — RESOLVED (2026-06-04).** The CEO review
   confirmed PLG-first and services-first are incompatible *as a first move*
   (PLG needs a self-serve + low-COGS hosting plane built *before* revenue;
   services needs neither). Decision: **services-first now, PLG as Phase 2.**
   This risk is retired by sequencing rather than choosing one forever.
2. **Free-tier COGS is an existential variable — now modeled, not asserted.**
   `scripts/cogs-model.sh --sweep` shows the dominant lever is **cost per
   ideation run**, not conversion: cheap runs (~$0.50) stay healthy even at 1%
   conversion; Opus-heavy runs (~$3.00) go underwater below ~1.3%. So free-tier
   viability is a *model-cost* decision — cheap/cached ideation model + hard
   credit caps + idle-sleep, with metering shipping day one. Re-run with real
   token costs before the Phase 2 greenlight.
3. **"Won't leak" is a promise we must keep.** Selling production-safety means
   our own hardening (RLS, auth, secrets) has to be genuinely better than
   Lovable's — a single Shipworthy app leaking data kills the brand.
4. **Incumbents can close the gap.** Lovable/Base44 can add a "security pass."
   The defensible moat is the *unified runtime + continuity*, not the audit
   checklist — lean there.

---

## 7. Recommended next move (post-decision)

Sequencing is set. The immediate, near-zero-COGS move that serves the
services-first 90 days **and** seeds Phase 2: **ship the free "Is your app
Shipworthy?" scanner** as standalone top-of-funnel. It is the cheapest possible
demand instrument — it generates the leak stat for a prospect's *own* app, feeds
the services pipeline now, and measures latent appetite for the PLG product
later, all without building the hosting plane.

**Phase 2 trigger:** only build the $49 self-serve Launch tier + hosting/metering
plane once services-first clears its 01d bar (5 paid Validate + 1–2 paid Launch
in 90 days). If services-first misses that bar, the PLG build does not start —
the ICP/offer gets re-examined first.

### Open follow-up: the name

The CEO review flagged that **"Shipworthy" names the feature (production-safety),
not the moat (continuity / idea→scale)** — and production-safety is the more
contested wedge. Revisit the name when Phase 2 productization begins; do not
commit a domain/TM until then. Until Phase 2, the services motion sells under
the existing "Build Loop" identity.
