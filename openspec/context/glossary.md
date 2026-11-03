# build-product-v2 — Glossary of Abbreviations

Decoder for the acronyms, shorthand, and codebase-specific jargon used
across the 35 skills in `.claude/skills/`. Each entry gives the
expansion plus the *contextual* meaning in this repo (not the generic
Wikipedia definition).

Sections are alphabetical within each group.

---

## 1. Codebase-specific (read this first)

These are not industry standards — they're invented by this orchestrator.
You will not find them anywhere else.

| Term | Means | Where it shows up |
|---|---|---|
| **WEDGE** | One-sentence product thesis: ICP + axis + mechanism. The north star every downstream skill reads. | `wedge.md`, every skill |
| **DRAFT** / **LOCKED** | Artifact status. DRAFT = still has open issues. LOCKED = passed critic gate, downstream skills allowed to consume it. | All strategic artifacts |
| **HC1 / HC2 / HC3 / HC4** | Human Checkpoints 1–4. Non-skippable user confirmations: wedge/ICP, design target, pricing/positioning, GO/NO-GO. | `build-product-v2/SKILL.md` |
| **toy / preview / launch / scale** | Scale tiers. Each skips a different list of ops phases. Default = `preview`. | `build-product-v2`, `tech-stack-selector` |
| **BLOCKED / SHIP / POLISH / LOOP / RETHINK** | Dogfood verdicts after a real-browser walk of the wedge workflow. Each verdict routes to a different recovery phase. | `dogfood/SKILL.md` |
| **PHASE_RESULT** | Structured block every subagent must return — `phase`, `status`, `artifact_path`, `summary`, etc. The orchestrator merges only this block into state, never the conversational text. | `build-product-v2/SKILL.md` |
| **CRITIC_VERDICT** | Structured block from a critic gate — `verdict: pass\|fail`, `must_fix`, `nice_to_have`, `evidence_quality`. | All `_critic` gates |
| **ADR** | Architectural Decision Record — appended to `state/state.json:decisions[]` and `state/decisions.md` via `state-decide.sh`. | State machine |
| **SRS** | System Requirements Specification — IEEE 830-shaped doc produced by `analyst`. | `analyst/SKILL.md` |
| **FR / NFR** | Functional / Non-Functional Requirement. Tagged `[wedge-critical]`, `[wedge-supporting]`, or `[V2]`. | `analyst`, `backend-developer`, `reviewer` |
| **PRR** | Production Readiness Review — final scale-tier-only gate before launch. Also the name of the skill (`production-readiness`). | `production-readiness/SKILL.md` |

---

## 2. Business / product / market

| Term | Expansion | In this codebase |
|---|---|---|
| **ACV** | Annual Contract Value | First-year contract size for enterprise pricing tiers. |
| **ARR** | Annual Recurring Revenue | SaaS top-line metric tracked post-launch by `analytics`. |
| **B2B / B2C** | Business-to-Business / Business-to-Consumer | Drives auth provider choice, pricing tier shape, compliance scope. |
| **BANT** | Budget · Authority · Need · Timeline | Sales-qualification frame, occasionally referenced in pricing/positioning. |
| **CAC** | Customer Acquisition Cost | Marketing spend ÷ new customers; instrumented by `analytics`. |
| **DTC** | Direct-to-Consumer | Distribution wedge biasing toward freemium/viral. |
| **GTM** | Go-To-Market | The launch half of the pipeline (`pricing` → `positioning` → `landing-page` → `legal-compliance`). |
| **ICP** | Ideal Customer Profile | The 1–2 sentence "who this is for"; central to wedge, pricing, positioning. |
| **LTV** | Lifetime Value | Revenue per customer over their lifetime; analytics target. |
| **MRR** | Monthly Recurring Revenue | Monthly version of ARR. |
| **MVP** | Minimum Viable Product | Smallest feature set that validates the wedge — usually = `preview` tier deploy. |
| **NPS** | Net Promoter Score | Post-launch satisfaction metric. |
| **PMF** | Product–Market Fit | What `dogfood` and `signal-iterate` are looking for. |
| **PRD** | Product Requirements Document | Output of `product-spec`. Covers personas, story map, MVP scope, Gherkin criteria. |
| **RFQ** | Request For Quote | A user-facing event in marketplace/B2B products; analytics event candidate. |
| **ROI** | Return on Investment | Buyer-justification metric in positioning copy. |
| **SaaS** | Software-as-a-Service | The default business model assumption — implies subscription pricing + multi-tenant + uptime. |
| **SAM / SOM / TAM** | Serviceable Addressable Market / Serviceable Obtainable Market / Total Addressable Market | Standard market-sizing pyramid. TAM = global, SAM = reachable, SOM = year-1. |
| **SMB** | Small-to-Medium Business | The most common ICP segment in this repo's sample products. |
| **WTP** | Willingness To Pay | Buyer-research input to `pricing`. |

---

## 3. Engineering / web / API

| Term | Expansion | In this codebase |
|---|---|---|
| **API** | Application Programming Interface | RESTful HTTP endpoints documented by `api-docs` (OpenAPI 3.1). |
| **CRUD** | Create / Read / Update / Delete | Default endpoint shape per entity in the SRS. |
| **CSR / SSR / SPA** | Client-Side Rendering / Server-Side Rendering / Single Page Application | Next.js App Router defaults to SSR for SEO + CSR for interactions. |
| **JSON** | JavaScript Object Notation | Default request/response format. |
| **JWT** | JSON Web Token | Stateless auth token; used directly or wrapped by Lucia/Clerk in `auth-engineer`. |
| **OAuth** | Open Authorization | Third-party login (Google, GitHub) — wired by `auth-engineer`. |
| **ORM** | Object-Relational Mapping | Usually Prisma; sometimes typed SQL. Pinned in `tech-stack.md`. |
| **RBAC** | Role-Based Access Control | Auth + permissions enforced at API + DB-row level. |
| **REST** | Representational State Transfer | Default API style. |
| **SDK** | Software Development Kit | Vendor library (Anthropic, Stripe, Resend, Clerk…) pinned in tech stack. |
| **SQL** | Structured Query Language | Underneath the ORM; written directly for migrations and complex queries. |

---

## 4. Security

| Term | Expansion | In this codebase |
|---|---|---|
| **CORS** | Cross-Origin Resource Sharing | HTTP headers controlling cross-domain calls; per-env config. |
| **CSP** | Content Security Policy | Header restricting script sources; XSS mitigation. |
| **CSRF** | Cross-Site Request Forgery | Mitigated via SameSite cookies + origin checks. |
| **CVE** | Common Vulnerabilities and Exposures | Public vuln IDs scanned by `security-auditor`. |
| **HSTS** | HTTP Strict Transport Security | Forces HTTPS browser-side; PRR requirement. |
| **HTTPS** | HTTP Secure | TLS 1.2+ mandatory in production. |
| **IDOR** | Insecure Direct Object Reference | Guessable IDs leaking other users' data; ownership check at backend. |
| **OWASP** | Open Web Application Security Project | Top-10 list driving `security-auditor` checklist. |
| **PII** | Personally Identifiable Information | Encrypted at rest, redacted from logs; legal-compliance flag. |
| **RCE** | Remote Code Execution | Highest-severity class; prevented via no-eval, no-shell-injection, safe deserialization. |
| **SSL** | Secure Sockets Layer | Predecessor to TLS; both terms used loosely. |
| **SSRF** | Server-Side Request Forgery | Backend tricked into internal calls; private-IP denylist. |
| **TLS** | Transport Layer Security | Protocol enforcing HTTPS. |
| **TOCTOU** | Time-Of-Check, Time-Of-Use | Race condition between verification and use; payment/approval flows. |
| **XSS** | Cross-Site Scripting | Untrusted user input rendered as HTML/JS; output encoding required. |

---

## 5. Testing & quality

| Term | Expansion | In this codebase |
|---|---|---|
| **a11y** | Accessibility (a + 11 letters + y) | WCAG 2.1 AA target; tested in `dogfood` + dedicated quality gate. |
| **ARIA** | Accessible Rich Internet Applications | HTML attributes for assistive tech. |
| **BDD** | Behavior-Driven Development | Gherkin-style criteria from `product-spec`. |
| **E2E** | End-to-End | Playwright suite from `e2e-tester`. Layer 8 of quality-gates. |
| **i18n / l10n** | Internationalization / Localization | i18n = build to support multiple locales; l10n = actually translate. Usually deferred to V2. |
| **KPI** | Key Performance Indicator | Business metrics (CAC, LTV, NPS, churn) instrumented by `analytics`. |
| **MSW** | Mock Service Worker | Library for mocking API calls in frontend tests. |
| **QA** | Quality Assurance | Generic testing discipline; the `dogfood` skill is the wedge-specific QA layer. |
| **SLI** | Service Level Indicator | Measurement (uptime, latency). |
| **SLO** | Service Level Objective | Target on the SLI (e.g., 99.9% uptime). |
| **SRE** | Site Reliability Engineering | Discipline; `production-readiness` skill operates in this mode. |
| **TDD** | Test-Driven Development | Implied by `backend-developer`'s test-first approach. |
| **WCAG** | Web Content Accessibility Guidelines | Specifically WCAG 2.1 AA target. |

---

## 6. Infra · deploy · ops

| Term | Expansion | In this codebase |
|---|---|---|
| **ALB** | Application Load Balancer | AWS L7 LB; routes traffic in ECS deployments. |
| **AWS** | Amazon Web Services | Cloud option; pinned in `tech-stack.md`. |
| **AZ** | Availability Zone | Cloud region subdivision; multi-AZ for `scale` tier. |
| **CDN** | Content Delivery Network | Edge caching for static assets; opt-in at `scale`. |
| **CI/CD** | Continuous Integration / Continuous Deployment | Buildkite default (per CLAUDE.md cost note); generated by `cicd` skill. |
| **DNS** | Domain Name System | Domain routing; configured in `production-readiness`. |
| **DR** | Disaster Recovery | Backup/restore strategy; PRR-required. |
| **ECS** | Elastic Container Service | AWS container orchestrator. |
| **GCP** | Google Cloud Platform | Cloud option (Cloud Run / Cloud SQL). |
| **IaC** | Infrastructure as Code | Terraform scripts generated by `deployer` for launch+ tiers. |
| **K8s** | Kubernetes | Not the default — Buildkite + Cloud Run / ECS preferred. |
| **MTTR** | Mean Time To Recovery | How fast the team restores after an outage; PRR target. |
| **NAT** | Network Address Translation | Outbound NAT gateway for VPC-internal services. |
| **PITR** | Point-In-Time Recovery | DB restore-to-timestamp; required at `launch`+. |
| **RDS** | Relational Database Service | AWS managed Postgres/MySQL. |
| **RPO** | Recovery Point Objective | Max acceptable data loss in a disaster (e.g., RPO < 15min). |
| **RTO** | Recovery Time Objective | Max acceptable downtime in a disaster (e.g., RTO < 1hr). |
| **SLA** | Service Level Agreement | Contractual uptime/perf commitment to customers; sets SLOs. |
| **VPC** | Virtual Private Cloud | Cloud network isolation; configured in Terraform. |

---

## 7. Data / AI

| Term | Expansion | In this codebase |
|---|---|---|
| **DAG** | Directed Acyclic Graph | Job dependency graph in `background-jobs`. |
| **DL** | Deep Learning | Rare here — most AI is delegated to Claude/GPT/Gemini APIs. |
| **ELT** | Extract → Load → Transform | Modern data-pipeline pattern (load raw, transform in warehouse). |
| **ETL** | Extract → Transform → Load | Older pattern; transforms pre-load. |
| **LLM** | Large Language Model | Claude / GPT / Gemini; used when wedge is `ai_heavy=true`. |
| **ML** | Machine Learning | Generic; mostly outsourced to API vendors. |
| **MMR** | Maximal Marginal Relevance | RAG retrieval-diversity heuristic; reduces redundant chunks. |
| **NLP** | Natural Language Processing | Subfield label; mostly LLM-based here. |
| **OLAP** | Online Analytical Processing | Warehouse / column-store reads (BigQuery, Redshift). Separate from OLTP at `scale`. |
| **OLTP** | Online Transaction Processing | The operational DB (Postgres) handling user requests. |
| **RAG** | Retrieval-Augmented Generation | Embed → retrieve → prompt pipeline; built by `ai-features`. |

---

## 8. Compliance · legal · privacy

| Term | Expansion | In this codebase |
|---|---|---|
| **APP / APPs** | Australian Privacy Principles | AU privacy law; cited in privacy policy when AU users present. |
| **AUP** | Acceptable Use Policy | Restrictions on platform misuse (spam, fraud, harassment). |
| **CCPA** | California Consumer Privacy Act | US state privacy law; "Do Not Sell" notice + opt-out. |
| **DPA** | Data Processing Agreement | Controller↔processor contract; lists each subprocessor (Stripe, Resend…). |
| **DPO** | Data Protection Officer | Required role under GDPR for large-scale processing. |
| **GDPR** | General Data Protection Regulation | EU privacy law; legal-compliance hard-fails at `launch+` if `regulated=true` or `eu_global_billing=true` and GDPR docs missing. |
| **HIPAA** | Health Insurance Portability and Accountability Act | US healthcare privacy; only applies if patient data is handled. |
| **ISO27001** | Information Security Management System standard | Global security baseline; required for some enterprise/govt buyers. |
| **PCI-DSS** | Payment Card Industry Data Security Standard | Required only if handling raw cards (Stripe absorbs this for most apps). |
| **SOC2** | Service Organization Control 2 | US compliance framework for customer data handling; B2B/enterprise gate. |
| **ToS** | Terms of Service | Generated by `legal-compliance`. |

---

## 9. Australia-specific (most sample products are AU-targeted)

| Term | Expansion | In this codebase |
|---|---|---|
| **ABN** | Australian Business Number | AU business identifier; collected on B2B signup forms. |
| **ACMA** | Australian Communications and Media Authority | Telecom/SMS/broadcast regulator. |
| **AHPRA** | Australian Health Practitioner Regulation Agency | Healthcare regulator (relevant to `ScribeMate`). |
| **ASIC** | Australian Securities and Investments Commission | Financial regulator (relevant to fintech / payments / advice). |
| **ATO** | Australian Taxation Office | Tax regulator; cited in privacy/legal docs. |
| **BAS** | Business Activity Statement | Quarterly AU tax return (relevant to `Ledgerly`). |
| **GST** | Goods and Services Tax | AU sales tax (10%); collected/remitted if AU revenue exists. |
| **MBS** | Medicare Benefits Schedule | AU healthcare item-code list (relevant to `ScribeMate` — wedge revolves around correct MBS coding). |
| **NSW** | New South Wales | AU state; appears in geo-targeting and address validation. |
| **TPB** | Tax Practitioner Board | AU regulator of registered BAS/tax agents (relevant to `Ledgerly` ICP). |

---

## 10. UI / UX / Design

| Term | Expansion | In this codebase |
|---|---|---|
| **CTA** | Call To Action | Headline button on landing page; primary CTA must match the trial mechanic from `pricing.md`. |
| **UI** | User Interface | The visual layer (colours, spacing, components). |
| **UX** | User Experience | The interaction layer (workflows, flows, friction). |

---

## 11. Quick lookup — verdicts and statuses

When you see a one-word verdict in a SKILL.md, it almost certainly comes from one of these four enums:

| Enum | Possible values | Source |
|---|---|---|
| **Artifact status** | `DRAFT` · `LOCKED` | All strategic artifacts |
| **Critic verdict** | `pass` · `fail` | All `_critic` gates |
| **Phase status** | `done` · `failed` · `draft` | `state.phase_status[*]` |
| **Dogfood verdict** | `BLOCKED` · `SHIP` · `POLISH` · `LOOP` · `RETHINK` | `dogfood/SKILL.md` |

If you see a CAPS word that's not in this table, treat it as a regular acronym and search this glossary.

---

## 12. Disambiguations

A few terms collide; this is what they mean here.

| Term | Other meanings | Meaning HERE |
|---|---|---|
| **CSP** | Constraint Satisfaction Problem | **Content Security Policy** (security header) |
| **APP** | Mobile application | **Australian Privacy Principles** (when in legal-compliance context) |
| **SAM** | Sales/marketing personas | **Serviceable Addressable Market** |
| **SRE** | Software Reliability Eng — same field | Used as discipline label, not a job role |
| **PRR** | Pull Request Review | **Production Readiness Review** (the final scale-tier gate AND the skill `production-readiness`) |
| **DR** | Doctor / Drive / etc. | **Disaster Recovery** |
| **DRY** principle | Don't Repeat Yourself | Not used as a status — only as a coding principle if mentioned |
