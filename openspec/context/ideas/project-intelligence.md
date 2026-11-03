# ProjectIntelligence AU

## What the product is for

ProjectIntelligence AU is a **curated, AI-relevance-powered weekly digest of development applications (DAs) for Sydney roofing subcontractors**. The core problem: roofing owner-operators spend 6+ hours per week trawling 15 council DA portals to find re-roof projects to quote on, and the incumbent (Cordell Connect) sends 47 weekly alerts of which only 3 are relevant. PI-AU ingests DA data nightly from NSW Planning Portal + council APIs, embeds descriptions using OpenAI embeddings, reranks with Claude Haiku against a roofing-specific vocabulary, and delivers a curated 5–15-item Sunday 6 pm email + SMS digest for A$199/month. It solves the "relevance needle in a haystack" problem with a vertical-specific AI layer that incumbents structurally cannot match (they must serve 40+ trades equally). Unit economics: A$4 per useful lead vs Cordell's A$44; signup in 60 seconds, no sales call.

## Main customers

- **ICP:** Owner-operators of 4–15-person Sydney roofing subcontractor firms (residential strata + light commercial), revenue A$1.5–8M/yr, who personally quote work or supervise one estimator
- **Geography:** Greater Sydney (Western Sydney, Inner West, Hills, Northern Beaches, Sutherland Shire) — ~1,500–2,000 reachable firms
- **Persona "Estimator Eli":** age 40s, iPhone-first, already pays Cordell A$6,930/yr for worse results; willing to pay A$199–500/seat/month for relevance
- **B2B SaaS for trades**
- **Secondary (V2 roadmap):** small HVAC, electrical, civil-works subs
- **Market:** TAM A$80–150M (AU construction project-intel software); SAM A$30–60M (10–15k tender-driven trade firms); SOM Year 3 A$2.5–6M ARR at 800–2k seats

## Main user cycle

1. **Sign up self-serve** — Email, mobile, card on file, 14-day trial, no sales call; 60-second flow redirects to LGA selection.
2. **Select service area** — Check 1+ of 4 pre-built LGA bundles (Western Sydney, Inner West, Northern Sydney, Southern Sydney); maps to actual work footprint, not whole-of-state.
3. **System ingests nightly** — Vercel Cron fetches NSW Planning Portal + DA Leads / Council DA APIs at 11pm AEST; normalises 500–1,500 new DAs/week per LGA.
4. **AI relevance pipeline runs Sunday 5pm** — 3-stage: (a) SQL rule filter by LGA + roofing vocabulary ("re-roof", "membrane", "Colorbond", "asbestos roof"); (b) pgvector cosine-similarity rank against saved-query embedding; (c) Claude Haiku rerank with one-line "why this matched" for top-30 candidates.
5. **Sunday 6pm digest fires** — Resend email + Twilio SMS to up to 3 confirmed addresses; email shows 5–15 ranked DA cards (address, LGA, value, scope, "why this matched", direct council-portal link); SMS sends top-3 as short summary links.
6. **Eli reads in 5 minutes, gives feedback** — Thumbs up/down on each card; thumbs-up DAs go to "quotes this week" list; feedback ingested by relevance pipeline next week.
7. **Month-4+ precision recap** — Email header shows "Last 4 weeks: you saw N of M real re-roofs, X% precision" — proof-of-value renewal driver.

**Built (May 2026):** Next.js 15 monolith on Vercel, Lucia auth, Postgres + pgvector, nightly ingestion from 3 DA APIs, 3-stage relevance pipeline (rule → embed → LLM rerank), Resend email + Twilio SMS, Stripe billing with GST, web portal for history + account, per-DA thumbs feedback, Sentry + Pino observability, eval harness for ranking precision.

**Not V1:** Custom saved queries, multi-trade filters, HVAC/civil verticals, Melbourne/Brisbane expansion, mobile native app, team RBAC, government tender feed.
