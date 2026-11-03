# BuildPM

## What the product is for

BuildPM is an **AI-native construction project management platform for Australian property owners** that automates the project manager's role. It combines AI-driven project planning, decomposition, and material estimation with a marketplace connecting property owners to verified, licensed tradespeople. The core problem: residential and small commercial renovations (A$10K–A$2M) routinely incur A$15K–A$50K in professional PM fees, run 10–25% over budget, and delay 20–40%. Property owners can't afford dedicated PMs and struggle to find licensed, trustworthy contractors. BuildPM replaces manual planning with AI that breaks projects into phases and tasks, estimates materials with Australian pricing, identifies required trades and licences, and routes well-scoped work to suppliers who can bid competitively. The platform holds escrow payments and verifies supplier licences to reduce risk on both sides.

## Main customers

**Property Owners (Primary):**
- Homeowners 30–65 undertaking renovations / repairs / extensions
- Property investors managing portfolios
- Small commercial owners
- Budget-conscious, digitally literate, value transparency
- Launch geography: Sydney, Melbourne, Brisbane (75% of AU construction activity)

**Suppliers / Tradespeople (Secondary, two-sided marketplace):**
- Licensed electricians, plumbers, builders, carpenters, painters, tilers, specialist contractors
- Tired of paying hipages lead fees (A$25–A$70+ per lead) or low-quality leads
- Want recurring work, lower admin burden, faster payment

**Market size:** ~A$2.75B in annual PM costs (5% of A$55B residential renovation market). Year-5 target: 0.5% SAM = A$100M ARR via platform fees on accepted quotes + optional supplier subscriptions.

## Main user cycle

1. **Register & verify** — Property owner signs up, verifies email, sets profile with property details and budget constraints.
2. **Describe project** — Owner enters project type (repair / renovation / extension / CDC), property address, and plain-English description ("kitchen renovation, 15 sqm, new cabinets, tiling, electrical upgrade").
3. **AI generates plan** — Platform produces structured plan with 3+ phases, 5+ tasks, estimated duration per task, dependencies, and required trades within 30 seconds.
4. **Review & edit** — Owner adjusts phase/task names, quantities, sequence. AI generates material estimates (quantities + unit costs) and total project cost.
5. **Publish to marketplace** — Owner publishes project or individual tasks with budget and timeline. Suppliers see tasks matching their trade category and licences.
6. **Receive & compare quotes** — Licensed suppliers submit itemised quotes (labour, materials, GST, duration, availability). Owner compares 2–3 quotes side-by-side with supplier ratings, verified licence badges, and review history.
7. **Assign & execute** — Owner accepts a quote, triggering task assignment. Supplier marks tasks complete with status updates; owner releases payments on milestone completion.

**Built:** Full stack (Next.js 16, React 19, Prisma + PostgreSQL, Redis for job queues, Tailwind). Implemented: auth, project CRUD, AI plan generation, task marketplace with quoting, supplier licence verification, document upload, notifications, in-app messaging, admin dashboard.

**Not yet shipping:** AI-powered supplier recommendations, Stripe payments, state licensing API integrations, CDC document AI review.
