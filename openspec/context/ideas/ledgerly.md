# Ledgerly

## What the product is for

Ledgerly solves the **review-time bottleneck in Australian bookkeeping firms**. Bookkeepers already use Hubdoc or Dext to OCR receipts into Xero drafts, but then must manually review every line for GST classification — 90–120 minutes per client per quarter. Ledgerly sits on top of the Xero "Awaiting Approval" queue, runs an AU-tax-aware rule engine and LLM classifier on each transaction, and **hides everything ≥85% confidence**. The firm owner only sees the 5–15% of lines where AI is uncertain, resolving them in 8–12 minutes instead of 90. Each resolution updates Xero and records an audit trail citing the specific AU tax rule (GST Act, ITAA97 s.32-5, etc.) — making it TPB-defensible.

## Main customers

- **ICP:** Owner-operator of a 2–8 person registered bookkeeping firm in Sydney/Melbourne charging A$80–A$150/hr
- **Profile:** BAS-agent registration with the Tax Practitioners Board, 15–40 SME clients on Xero. Typically female, 38–55, ICB Australia member
- **B2B SaaS, vertical niche:** AU bookkeeping firms only
- **Buyer:** Single decision-maker (firm owner). Motivation: personal TPB liability exposure during BAS week; existing willingness-to-pay via PI insurance line items
- **Market:** TAM ~12–18k firms globally; SAM (Xero-using AU practices) ~A$43–65M ARR; SOM (Sydney/Melbourne, years 1–3) 100–500 firms — A$1–3M ARR achievable for a focused founder

## Main user cycle

1. **Connect once** — Owner completes Xero OAuth, selects which client organisations to enable (2 minutes, one-time).
2. **Junior processes receipts as usual** — Hubdoc/Dext extracts vendor/amount/date/proposed code, pushes drafts to Xero "Awaiting Approval" tab unchanged.
3. **Ledgerly polls and classifies** — Scheduled pull of unclassified drafts; AU-tax rule engine runs first, LLM if confidence < 85%. Each line gets a 0–100 score and structured reasoning trail.
4. **Open dashboard** — Owner sees: "Client X — 12 of 180 transactions need your judgement. 168 are ready to publish."
5. **Triage exceptions** — Owner clicks each uncertain line, reads the AU-tax reasoning ("62% confident this $340 restaurant bill is staff entertainment vs. client entertainment — vendor pattern: 3 prior staff, 1 prior client"), picks the correct code (buttons: "Staff — FBT" or "Client — GST").
6. **Resolve & auto-learn** — One click updates the Xero draft, logs audit trail, and updates the firm's vendor → rule mapping for future quarters.
7. **Bulk-publish** — Owner clicks "Publish 168 confident lines." Ledgerly batch-approves them in Xero with per-line reasoning memo (confidence % + rule_id + reasoning hash) visible in Xero audit trail.

**Built (V1):** Xero OAuth, Awaiting Approval polling, AU-tax rule engine, LLM classification, exception-queue UI, one-click resolution, bulk-publish, audit log.

**Not built:** Receipt ingestion, OCR, WhatsApp ingest, BAS readiness PDF, junior read-only login, MYOB integration (V1.1+ or V2).
