# The Build Loop — Market Analysis

**Subject:** Self-analysis of the `build-product-v2` orchestrator + `signal-iterate` recurring loop, positioned as a single product called **The Build Loop**.

**Date:** 2026-05-11

> **The key insight up front:**
> You're entering the fastest-growing software category in history (Lovable: $100M ARR in 8 months) — but the obvious winners are leaving the back half of the product loop completely uncovered. That gap is your market.

---

## 1. The product, stated cleanly

**The Build Loop** is an opinionated orchestrator that takes a founder from one-sentence idea to a deployed product in ~5–7 days, then runs a recurring weekly loop driven by real user signals.

Distinguishing features:
- Strategic gates (wedge, pricing, positioning) before any code is written
- Adversarial critic gates on different models than producers
- 4 non-skippable human checkpoints
- Signal-driven iteration on PostHog / Sentry / support data — not vibes

---

## 2. Buyer personas (in order of accessibility)

| # | Persona | Why they buy | Why they don't (yet) |
|---|---|---|---|
| **P1** | **The tech-literate solo founder** (ex-engineer, ex-PM with coding chops, ex-design-with-code) | Has 3+ product ideas, can drive Claude Code, doesn't want a 5-person eng team for an unvalidated wedge | "Lovable is good enough for me" — they're not yet feeling the post-MVP pain |
| **P2** | **The "shipped an MVP, now what" founder** | Used Lovable / Bolt, got real users, hit the scaling / iteration wall — exactly the population our wedge is sharpened against | Often defaults to "I just need to hire engineers" |
| **P3** | **The fractional CTO / technical advisor** | Runs 3–8 founders' MVPs as a service; needs leverage; tool becomes their engine | Used to bespoke workflows; switching cost feels high |
| **P4** | **MVP agency / studio** ($5–50k MVPs for clients) | Compresses delivery from 8 weeks to 1; differentiates from agencies that vibe-code with Lovable | Margins on tool subscription < margins on contractor hours; needs to reframe pricing |
| **P5** | **Corporate innovation team / labs** | Validates adjacent product ideas without going through full engineering process; runs cheap, frequent experiments | Procurement friction; need security / compliance posture |
| **P6** | **Solo serial SaaS builder** (indie hacker shipping 4–8 products to find a winner) | Compounds the build loop across attempts; the iteration loop is the actual value | Often hobby budgets; willingness-to-pay is real but low ($30–80/mo) |

### Sharpest ICP candidate

**P2 — "I shipped an MVP with Lovable, now I'm stuck."**

Why: vibe-coders *created* this buyer state and don't solve it. They're the densest, most motivated population, and they have direct comparison data ("Lovable did X, what would I get instead?").

---

## 3. Market sizing — grounded

| Layer | Size | Source / reasoning |
|---|---|---|
| **TAM** — Global generative AI in SDLC | **$82.5B (2026) → $174.7B (2030)**, 20.6% CAGR | Fortune Business Insights / Research and Markets |
| **SAM** — AI app builders / "vibe-coding" platforms | **$12.8B (2026)**, up from $5.1B (2024) | Tech Insider |
| **Adjacent** — Global micro-SaaS market (Build Loop's downstream output) | **$15.7B (2024) → $59.6B (2030)**, ~30% CAGR | Micro-SaaS market research |
| **SOM** — Realistic 5-year capture | **~$30–80M ARR** | If you capture 0.25–0.6% of SAM, conservative on early stage |

### Competitor traction — the most important signal

| Tool | ARR | Time to ARR | Valuation |
|---|---|---|---|
| **Lovable** | $100M | 8 months | $6.6B |
| **Replit (post-Agent)** | $150M | ~12 months from $2.8M | — |
| **Bolt.new** | $40M | 4.5 months | — |

**Read:** *Buyers are saying yes faster than at any point in software history.* Distribution and packaging are bigger constraints than demand.

---

## 4. Competitive landscape

| Tier | Player | What they do well | The gap you exploit |
|---|---|---|---|
| **Direct (vibe-coders)** | **Lovable** | Cleanest React output; massive distribution | No wedge / pricing / positioning; one-shot mentality |
| | **Bolt.new** | Most framework-flexible; fastest "see it" | No iteration loop; security-vulnerable output |
| | **v0** | Best UI fidelity; Vercel-native | UI-only; not a product, just screens |
| | **Replit Agent** | Most autonomous; 30+ integrations | Strategy-blind; no positioning / pricing |
| **Adjacent (coding assistants)** | Cursor, Claude Code, Cline, Aider | Best-in-class for code | Not product builders; require user to drive entire process |
| **Adjacent (SDKs / agent frameworks)** | LangChain, AutoGen, CrewAI, Claude Agent SDK | Maximum customisation | Engineer-only audience; no opinions, no artifacts |
| **Indirect** | MVP agencies, hire-contractors, T3 / Vercel templates | "Real" production-ready code | Slow; expensive; can't compound on signals |

### The structural blind spot — what no competitor has

| Feature | Lovable | Bolt | v0 | Replit | **Build Loop** |
|---|---|---|---|---|---|
| Strategy artifacts (wedge, pricing, positioning) | ❌ | ❌ | ❌ | ❌ | **✅** |
| Critic gates on different model than producer | ❌ | ❌ | ❌ | ❌ | **✅** |
| Quality gates (typecheck, mutation, contract, e2e, a11y, lighthouse, visual) | partial | partial | ❌ | partial | **✅ 11 layers** |
| Signal-driven weekly iteration loop | ❌ | ❌ | ❌ | partial | **✅** |
| Mandatory human checkpoints baked in | ❌ | ❌ | ❌ | ❌ | **✅ 4 of them** |
| Legal / compliance phase (privacy, ToS, GDPR) | ❌ | ❌ | ❌ | partial | **✅** |
| Scale tiers (toy / preview / launch / scale gating) | ❌ | ❌ | ❌ | ❌ | **✅** |

---

## 5. The wedge — data-grounded

Three numbers carry the whole argument:

1. **62% of AI-generated code has security flaws** (Cloud Security Alliance)
2. **2,000+ vulnerabilities + 400 exposed secrets** across 5,600 publicly scanned vibe-coded apps
3. **70% of micro-SaaS earns < $1,000/month; only 1–2% exceed $50,000/month** — and **72% of successful indie hackers cite distribution, not product, as the #1 driver**

The first two say: *vibe-coded code isn't production-ready.*
The third says: *and most indie founders ship a product nobody knows about.*

**Build Loop's wedge:**
> *Vibe-coders compress 'idea → code'. Build Loop compresses 'idea → product loop' — including the wedge, the pricing, the landing page, the iteration discipline. That's the part that fails today.*

**One-liner-able:**
> **Lovable ships an MVP. The Build Loop ships a product loop.**

---

## 6. GTM realism

**Pricing anchor:** Lovable charges ~$25–250/mo. Build Loop sits above that — likely **$99–499/mo individual, $1,500–5,000/mo team** — because the artifact stack (wedge, pricing, positioning, weekly iteration) is substantially more than a code generator.

### Distribution paths, ranked by likely 12-month yield

| Channel | Why it works | First action |
|---|---|---|
| **"Shipped with Lovable, now what" content** | Names P2 directly; SEO + community gold | 3 case-study posts: vibe-coded MVP → migrated to Build Loop |
| **Twitter / Indie Hackers / Reddit r/SaaS** | Where P1 / P6 live; founders sell to founders | Build in public; weekly "iteration #N" thread on a real product |
| **Founder podcasts (Lenny, Indie Hackers, MFM-adjacent)** | High-intent listeners; long shelf life | Pitch one ep on "the product loop founders skip" |
| **Direct DM to MVP agencies (P4)** | High ACV; obvious leverage story | List top 50 AU / UK / US AI-MVP shops, send one tailored note each |
| **AI / product newsletter sponsorships** (Latent Space, Software Lead Weekly, Lenny's) | Reach P1 / P2 / P5 at scale | Ad creative = the Lovable comparison table above |
| **Corporate innovation teams (P5)** — slowest, highest ACV | Long sales cycle but $$$ | Defer until proof points exist; not 2026 |

---

## 7. Kill-switch candidates (pre-declared, per your own discipline)

- **Demand kill:** if you can't get 20 founders to pay $99/mo within 3 months of soft launch, the positioning is wrong or P2 doesn't see the gap.
- **Build kill:** if a top-3 incumbent (Lovable, Replit, Bolt) ships a competing wedge feature (strategy artifacts + iteration loop) within 6 months. Plausible — Lovable has the cash. Watch carefully.
- **Defensibility kill:** if the wedge can be matched by a 1-week feature add from a vibe-coder, it's not a wedge.

> **The artifact stack (wedge → pricing → positioning → iteration) is the moat; the critic-gate architecture is harder to copy than it looks.**

---

## 8. The honest open questions

1. **Is P2 willing to pay 4–10× Lovable's price for a loop instead of an MVP?** Real demand-side bet. Worth a 5-buyer paid pilot to validate.
2. **How fast does the buyer realise they need the loop?** If "after 6 months of vibe-coding pain" — long sales cycle. If "from the start" — bigger market.
3. **Distribution: do you have the audience to seed P1 / P2 organically?** If no, this is a content-and-community marathon, not a sprint.
4. **Will Anthropic / OpenAI / Cursor ship something Build Loop-shaped natively?** Plausible 12–18 month threat. The mitigation: depth on iteration loop + opinions about strategy artifacts is hard to commoditise — these are product decisions, not LLM capabilities.

---

## 9. Bottom line for CEO conversations

When a founder asks "who's this for?" — the right answer is short and pointed:

> *"Founders who shipped a Lovable MVP and got stuck on what to ship next. The vibe-coders solved 'idea-to-code.' Nobody's solved 'idea-to-product-loop.' That's what I'm doing."*

Then back it with these three numbers:
1. **62% of AI-generated code has security flaws**
2. **70% of micro-SaaS makes under $1k/mo**
3. **Distribution beats product 72% of the time**

Those three numbers carry the room.

---

## Sources

- Best AI App Builders 2026 — getmocha.com/blog/best-ai-app-builder-2026
- Lovable $100M ARR / $6.6B valuation — lovable.dev/guides/best-ai-app-builders
- AI App Builder comparison — pasqualepillitteri.it/en/news/591
- AI Code Tools Market — marketsandmarkets.com/Market-Reports/ai-code-tools-market-239940941.html
- GenAI in SDLC Market — fortunebusinessinsights.com/generative-ai-in-software-development-lifecycle-market-109041
- AI Coding Statistics — getpanto.ai/blog/ai-coding-assistant-statistics
- Software Development Statistics 2026 — keyholesoftware.com/software-development-statistics-2026
- Vibe Coding Failures — getautonoma.com/blog/vibe-coding-failures
- Vibe Coding Production Issues — scand.com/company/blog/what-is-vibe-coding-production-issues
- Vibe Coding Trap (security) — ruinunes.com/vibe-coding-trap-ai-built-mvp
- Vibe Coding Hangover — sethserver.com/startups/vibe-coding-hangover-what-happens-after-the-mvp-ships.html
- 2026 SaaS Market Report — indiehackers.com/post/2026-saas-market-report-key-insights-95423fc66b
- Top Vibe Coding Platforms 2026 — dronahq.com/top-vibe-coding-platforms
- Micro-SaaS Market Data — lovable.dev/guides/micro-saas-ideas-for-solopreneurs-2026
