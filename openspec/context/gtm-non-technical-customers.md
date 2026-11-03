# Selling `build-product-v2` to Non-Technical Customers

**Audience:** founders, marketers, owners of this orchestrator deciding how
to package and sell it.
**Subject:** people with an idea but no engineering background — solopreneurs,
domain experts (coaches, consultants, lawyers, clinicians), SMB owners,
"idea people," creators trying to productize an audience.
**Date:** 2026-05-01

---

## 1. Executive summary

The orchestrator's strongest non-obvious asset is that it ships a *whole
business*, not just code: market analysis, wedge, pricing, positioning,
landing page, legal pages, deploy, analytics. A non-technical buyer does
not want "an AI dev pipeline." They want "I have an idea on Monday, a
URL I can send to my first customer on Friday, and someone telling me
what to charge." That is exactly what this pipeline does — but the
current packaging (state machines, critic gates, scale tiers, model
routing) is opaque to that buyer.

The path to selling is therefore not adding features. It is:

1. **Re-language** the product around outcomes, not architecture.
2. **Re-package** into 2–3 done-for-you tiers that map to scale tiers
   (`preview` / `launch` / `scale`), priced by business value, not
   compute.
3. **Lead with demos**, not docs — record the pipeline running live,
   end-to-end, on real ideas the audience submitted.
4. **Sell the marketing + pricing layer first**, code second. That is
   the wedge competitors (Lovable, Bolt, v0, Replit Agents) do not
   have.
5. **Add a concierge layer** — you (or an operator) sit on the four
   human checkpoints with the customer over a 60-minute call. This
   converts the orchestrator's biggest UX liability (it stops and asks
   technical-sounding questions) into a high-ticket service.

---

## 2. Who actually buys this

The orchestrator can serve five buyer archetypes. Pick **one** to lead
with; mixing them dilutes messaging.

| Archetype | Pain | Budget | Channel |
|---|---|---|---|
| **Domain-expert solopreneur** (coach, consultant, fitness pro, therapist, course creator) | "I have a method I sell 1:1; I want to scale it as software" | $500–$5K one-time, or $99–$299/mo tool | YouTube, podcasts, LinkedIn, niche communities |
| **Indie-hacker-curious creator** (newsletter, audience 1K–50K) | "I want to ship something to my list this quarter" | $99–$499/mo, $1–3K one-time | X/Twitter, IndieHackers, YouTube, newsletter swaps |
| **Aspiring non-tech founder** ("I have an idea") | "Quoted $40K from an agency, $80/hr from freelancers, I just want a v1" | $2K–$10K one-time | TikTok/Reels, YouTube ads, FB groups, "no-code" subreddits |
| **SMB owner needing internal tool** (clinic, agency, contractor) | "Spreadsheets are killing us; an off-the-shelf SaaS costs $300/seat" | $3K–$15K one-time + $99/mo | LinkedIn, Google search ("custom CRM for X"), local referrals |
| **Agency / consultancy reseller** (1–10 person dev shop) | "I need to deliver client MVPs in days, not months" | $500–$2K/mo seat | Twitter/X dev community, agency Slack groups, Producthunt |

**Recommended lead-with archetype: domain-expert solopreneur.**

Why: highest willingness-to-pay, clearest "before/after" story, most
shareable case studies, and they already have an audience to bring you
referrals. The orchestrator's market-analysis + pricing + positioning
phases are the most valuable to this archetype because they have *zero*
muscle for those decisions.

---

## 3. What you're actually selling (outcome reframe)

The buyer does not care about any of the things the README brags about.
Translate every internal concept into an outcome.

| What it is internally | What you sell |
|---|---|
| State-machine orchestrator with 20+ phases | "From your idea to a live URL in a week" |
| `differentiation` skill produces a wedge | "We tell you what to build *first* so you don't waste 6 months" |
| Critic gates with different models | "Built-in second opinion on every decision" |
| `pricing` + `positioning` skills | "We tell you what to charge and how to talk about it" |
| `landing-page` skill | "Marketing site is done — copy, design, deploy" |
| `legal-compliance` skill | "Privacy policy + terms + GDPR — included, not a $2K lawyer call" |
| `dogfood` loop | "We use the product as your customer would, before you ever see it" |
| Four human checkpoints | "You stay in control of the four decisions that matter" |
| Scale tiers (toy/preview/launch/scale) | Three packages: **Validate / Launch / Scale** |
| Buildkite / Vercel / Fly deploy | "We host it. You get a URL." |
| `signal-iterate` weekly | "We watch the analytics and tell you what to ship next" |

**The one-liner pitch:**

> *"Bring an idea, leave with a live product, a price tag, a landing
> page, and a list of who to sell it to — in a week, for less than
> one month of an agency retainer."*

Notice what's not in that line: AI, agents, orchestrator, pipeline,
state machine, critics. Those words **lose** the sale.

---

## 4. Competitive positioning

Non-technical buyers will compare you to:

| Competitor | What they do well | Where you win |
|---|---|---|
| **Bubble / Webflow / Glide** (no-code) | Drag-and-drop, no install | They give a tool; you give a *finished product*. They don't price/position/launch. |
| **Lovable / Bolt / v0 / Replit Agents** | "Type a prompt, get an app" | One-shot prompt → toy app with no market validation, no pricing, no legal, no deploy plan. You ship a *business*. |
| **Fiverr / Upwork freelancer** | Cheap | Quality variance; no marketing/legal; weeks of back-and-forth. You: predictable, one week, full stack. |
| **Boutique dev agency ($30K+)** | Hand-holding, polish | 10× cheaper, 4× faster, includes the strategy work agencies bill separately. |
| **"Build in public" YouTube tutorials** | Free | Still requires the buyer to learn to code. You remove that. |

**Positioning statement (use verbatim in landing page hero):**

> "For domain experts who want to turn their expertise into software —
> not a Bubble app, not a $40K agency build, not another course about
> how to learn to code. We build the actual product, name the price,
> write the landing page, and hand you the URL. In a week."

**Anti-positioning** (what you refuse, which makes the wedge sharp):

- We will not build "the next Uber for X" — too vague, not a wedge.
- We will not build something with no audience already identified.
- We will not let you skip the wedge / pricing / positioning calls.
- We will not customize past the four scale tiers.

---

## 5. Messaging framework (for landing page, ads, sales calls)

### Hero (≤ 12 words, per your own `positioning` critic checklist)

> *"Your idea, shipped as a real product — in one week."*

Subhead:

> *"We build the app, name the price, write the marketing site, and
> hand you a live URL. You stay in control of the four decisions that
> actually matter."*

### Three-message stack (use in this order, every channel)

1. **Speed:** "Idea Monday, live URL Friday."
   - Proof: timestamped recording of a real build.
2. **Completeness:** "Code, pricing, landing page, legal, analytics —
   all included."
   - Proof: side-by-side checklist vs. competitors.
3. **Strategy first:** "We don't start coding until we know what to
   build, who buys it, and what they pay."
   - Proof: a redacted `wedge.md` and `pricing.md` from a real
     build.

### Loss-aversion frame (the strongest for this buyer)

> *"Most first-time founders spend $20K and 8 months building the
> wrong thing. We spend the first day making sure that doesn't
> happen — then we ship the right thing in the rest of the week."*

This works because the *real* fear of a non-technical founder is not
"my app will be slow," it is *"I will spend my savings on the wrong
product."* The orchestrator's wedge + critic + dogfood loops literally
solve that fear. Sell that.

---

## 6. Packaging & pricing

Map the existing scale tiers to plain-English packages. Don't expose
the words "toy / preview / launch / scale" to the buyer.

| Package | Internal tier | Includes | Price (anchor) | When to recommend |
|---|---|---|---|---|
| **Validate** | `toy` + first 3 phases (`ceo`, `differentiation`, `pricing`) | Market analysis, wedge, pricing strategy, positioning headline. No code. PDF + 60-min call. | **$499 one-time** | "I have an idea, not sure if it's real" |
| **Launch** ⭐ | `preview` (full pipeline, no ops) | Everything in Validate **+** working app, landing page, legal pages, deployed preview URL, analytics. | **$2,499 one-time + $99/mo hosting** | Default. 80% of buyers. |
| **Scale** | `launch` or `scale` | Launch package **+** payments live, CI/CD, monitoring, on-call rollback, weekly iteration based on analytics. | **$7,999 setup + $499/mo** | Already has paying customers or audience >10K |
| **Concierge add-on** | (orthogonal) | A human (you / operator) sits on the 4 checkpoints, walks the customer through wedge / design / pricing / GO-NO-GO. | **+$1,500** to any package | Recommended for first-time founders |

**Pricing logic (mirrors your own `pricing` critic checklist):**

- 3 tiers, not 4+ ✅
- No "unlimited" ✅
- Each tier has a clear upgrade trigger:
  - Validate → Launch: "wedge confirmed, ready to build"
  - Launch → Scale: "first 10 paying customers"
- Trial mechanic: **Validate is the trial.** $499 buys the strategy
  doc; if the wedge isn't real, you save them $2K. That doubles as
  qualification: anyone who balks at $499 is not a fit for $2,499.

**Anchor logic:** position next to "agency build = $30–80K." Even
"Scale" looks like a steal. Do not anchor against ChatGPT
($20/mo) — that's the wrong frame.

---

## 7. Sales & demo motion

Non-technical buyers do not buy from documentation. They buy from
seeing it work. The single highest-leverage marketing asset you can
build is a **live build video** (or weekly livestream).

### The "Idea-to-URL in 60 minutes" demo

Format: 45–60 minute recording. Audience submits an idea via form;
you run `/build-product-v2 "<idea>"` on camera. Cut to highlights:

1. (5 min) Read the idea, set expectations.
2. (10 min) `ceo` + `differentiation` output — explain the wedge in
   plain English. **This is the magic moment** — most viewers have
   never seen anyone articulate "what to actually build" in 10 minutes.
3. (10 min) Skim through `product-spec`, `ux-designer` outputs. Show
   the wireframes.
4. (15 min) Time-lapse the implementation fan-out. Don't show the
   code; show the screen-recording of the dogfood phase using the
   running app.
5. (10 min) Reveal pricing, positioning headline, landing page,
   preview URL.
6. (5 min) Hand the buyer the URL on screen.

Distribute as: long-form on YouTube, 60-sec cuts on TikTok/Reels/X,
sliced screenshots on LinkedIn carousel.

### Sales-call flow (30 min)

1. (5 min) Discovery: "what's your idea, who buys it today, what do
   they pay?"
2. (5 min) Show the live build of *their idea* on screen — even just
   the `ceo` phase output. This is the closer; nothing else matters.
3. (10 min) Walk through the package they fit.
4. (10 min) Schedule the wedge call (their first checkpoint).

Conversion expectation: 30–50% close rate from a qualified call once
the live demo is dialed in. The demo *is* the product.

---

## 8. Channel strategy

Rank channels by fit-to-archetype, not by what's trendy.

### Tier 1 (start here — highest conversion, lowest cost)

1. **YouTube long-form** — the live-build format above. SEO compounds
   for years. Targets all five archetypes.
2. **Twitter/X "build in public" thread** — post the `wedge.md`
   and pricing doc from each build, with the customer's permission.
   Indie-hacker-curious + agency archetypes live here.
3. **LinkedIn case studies** — "How [Coach Name] turned their 1:1
   coaching method into a $99/mo SaaS in 5 days." Domain-expert and
   SMB archetypes live here.

### Tier 2 (after Tier 1 produces 3–5 case studies)

4. **Niche-community partnerships** — sponsor / guest-appear on
   podcasts and newsletters that already serve the archetype. One
   targeted podcast > 100K untargeted impressions.
5. **Cohort / workshop** — "Bring your idea, leave with a product, in
   one weekend." $1,500 per seat, 8 seats. Acts as both revenue and
   case-study factory.
6. **TikTok / Reels** — only the punchline cuts from the live builds.
   "I gave AI a fitness coach's idea. Here's what it built in 7
   minutes." Best for non-tech founder archetype.

### Tier 3 (after $50K MRR, when you can afford CAC)

7. **Paid YouTube pre-roll on competitors' videos** — Lovable, Bolt,
   v0, Bubble tutorials.
8. **Google search ads** on long-tail terms: "alternative to hiring a
   developer," "MVP without coding," "[industry] custom software."

### Channels to avoid

- **Producthunt launch** — wrong audience (developers comparing
  tools).
- **Hacker News** — they will hate the pricing and the no-code
  framing. Save it for the technical/agency reseller motion later.
- **Cold email** — non-technical founders don't open dev-tool cold
  emails.

---

## 9. Objection handling

Every objection a non-technical buyer raises in the first 90 days,
and the answer.

| Objection | Answer |
|---|---|
| "I don't trust AI to build real software." | "We don't trust it either — that's why every output is reviewed by a second AI on a different model, then by you at four checkpoints. Here's a real build's review log." |
| "What if it builds the wrong thing?" | "That's exactly why we don't write a line of code for the first 24 hours. You confirm the wedge, the design, and the pricing before we build. You can stop and refund at any of those four points." |
| "Can I edit it later?" | "Yes — the code is yours, hosted on your account. We hand off keys. Most buyers ask us to keep iterating ($499/mo); some take it to a developer. Both work." |
| "Why is it $2,499 when [Lovable] is $20/mo?" | "Lovable gives you a tool. We give you a finished product, plus the pricing strategy, the marketing site, and the legal pages. Compare us to an agency: 10× cheaper, 4× faster." |
| "I don't have an audience yet." | "Then start with Validate ($499). If we can't find a wedge worth building for, you've saved $2K. If we can, you have a strategy doc you can take anywhere." |
| "What if I'm not technical enough to use it?" | "You don't use it — we run it. You answer four 60-minute calls. That's it." |
| "Will it scale?" | "The Launch package handles your first ~100 users. When you hit 10 paying customers, we move you to Scale — same product, hardened infrastructure. You don't rebuild." |
| "What about [feature X]?" | "Anything past the wedge gets tagged `[V2]` and shipped in iteration weeks. Trying to build everything at once is exactly why most MVPs die." |

---

## 10. Risk reversal & social proof

Non-technical buyers fear being scammed. Aggressive risk reversal
beats a 10% price cut.

- **Validate guarantee:** if the wedge doc doesn't surface a
  defensible angle, full refund. (You'll refund <5% of the time;
  the diff/critic loop is good.)
- **Launch guarantee:** preview URL by day 7 or you don't pay the
  build fee. Hosting at-cost.
- **Public build log:** post the `decisions[]` ADR trail and the
  critic verdicts on a public page per build (with customer
  permission). Transparency is the moat.
- **First 10 customers free** in exchange for a video testimonial.
  Each testimonial unlocks $5–10K in downstream revenue.
- **"As-built" gallery:** a public page listing every product shipped,
  with live URLs. Updated weekly. This is the single most credible
  asset you can have.

---

## 11. What the orchestrator should *change* to be sellable

Not features — packaging. Engineering work, ranked by sales impact:

1. **Customer-facing rename** of every artifact: `wedge.md` →
   `Strategy.md`, `pricing.md` → `Pricing Plan.md`,
   `positioning.md` → `Marketing Message.md`. Do this in a
   "customer report" view; keep internal filenames stable.
2. **One-page PDF "Strategy Report"** auto-generated after the
   `pricing` + `positioning` phases. This is the deliverable for
   the Validate package.
3. **Plain-English checkpoint prompts.** Replace `AskUserQuestion`
   prompts like "confirm scale_tier and stack constraints" with
   "How big do you expect this to get? (a) just to test the idea,
   (b) up to 100 paying customers, (c) bigger than that."
4. **A "share with your audience" page** generated post-ship: a
   public URL with the live preview, the pricing, and a CTA to
   buy/signup. Customers will share this; it becomes top-of-funnel.
5. **Case-study auto-generator** — after `signal-iterate` runs for
   2 weeks, produce a shareable "X% conversion, $Y MRR, here's how
   we built it" page. Self-marketing flywheel.
6. **Stripe-on by default** in Launch. Right now `legal-compliance`
   ships consent banners but the buyer still has to wire payments.
   Adding a default Stripe path closes the most common
   "but how do I get paid" follow-up question.

These are 1–3 day eng changes that each materially raise close rate.

---

## 12. 30 / 60 / 90 day GTM plan

**Days 1–30 — Prove the demo.**

- Pick one archetype (recommend: domain-expert solopreneur).
- Build 3 case-study products end-to-end on real ideas you sourced
  from your network. Free, in exchange for video testimonials.
- Publish: 3 long-form YouTube builds, 9 short cuts, 3 LinkedIn
  case studies, 3 X threads with the wedge + pricing artifacts.
- Run 5–10 sales calls / week using the live-demo flow.
- Ship the eng changes in §11.1, §11.2, §11.3.

Target: 5 paying Validate customers ($2.5K), 1 paying Launch
customer ($2.5K). Total: $5K. Goal is signal, not revenue.

**Days 31–60 — Tighten conversion.**

- Identify which of the 3 archetype-specific landing pages converts
  best, kill the others.
- Run a paid YouTube pre-roll experiment ($1K cap) against Lovable
  / Bolt / v0 tutorial videos.
- Launch the cohort/workshop format ($1,500 × 8 seats = $12K).
- Hire one operator to take the human-checkpoint calls so you can
  scale past 5/week.

Target: $20K MRR-equivalent, 10 case studies live, 1 cohort run.

**Days 61–90 — Scale the channel that worked.**

- Double down on the single best channel from the prior 60 days.
- Launch the agency-reseller motion as a parallel revenue line —
  same product, B2B pricing ($1K/mo seat), entirely different
  positioning page ("ship client MVPs in days").
- Open a public "as-built gallery" with all customer products.
- Begin recurring `signal-iterate` revenue ($499/mo per Launch
  customer).

Target: $50K MRR, 25+ shipped products in the gallery, 1 viral
case study (>100K views).

---

## 13. The single most important thing on this page

Stop selling the orchestrator. Sell **a finished business in a week.**

Everything in `.claude/skills/` is the means; *that sentence* is the
product. Every landing page, ad, demo, and sales call should say
some version of that sentence and back it up with a live build the
buyer can watch happen in real time.

The orchestrator already does this. The work is making non-technical
buyers believe it without using a single word from this codebase.
