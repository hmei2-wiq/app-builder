# Realty Intelligence

## What the product is for

Realty Intelligence is an Australian document collection and workflow platform for **small independent mortgage brokers (1–5 person shops)** that eliminates the 5–10 hours per loan currently spent chasing, organising, and re-submitting borrower documents. Brokers sign up, brand a borrower-facing portal in under 10 minutes, and send a single SMS/email link. Borrowers upload 10–15 documents from their phone (payslips, tax returns, bank statements, ID) without logging in. The system auto-classifies each file using AI (manual tagging as fallback), flags expired or incomplete documents, and exports a lender-ready ZIP with clean naming and an audit log. All data stays in Sydney (australia-southeast-1), giving brokers a Privacy Act compliant audit trail they can hand to their PI insurer.

## Main customers

- **ICP:** Sydney SMB independent mortgage brokers, 1–5 person shops, settling 5–15 loans/month
- **Buyer:** Owner-operator age 30–50 on non-BrokerEngine aggregators (AFG SMART, Connective Mercury, LMG ZINC, Salestrekker)
- **Pain:** Currently lose hours to manual chasing via email + WhatsApp + Dropbox; no Privacy Act audit trail
- **Pricing:** A$500/mo (Solo) to A$1,000/mo (Team)
- **12-month target:** 25–80 paying brokers in Sydney/Melbourne (referrals + industry events)
- **Market:** TAM ~6,900 SMB shops × A$9,000/yr = A$62M serviceable market

## Main user cycle

1. **Broker signs up** (≤90s) — Email, password, ABN validation. AU-resident DPA auto-downloads.
2. **Broker brands workspace** (≤2 min) — Logo, business name, brand colour. Live preview of borrower portal.
3. **Broker creates deal** (≤2 min) — Enter borrower name, email/SMS, deal name. Generate unique shareable link.
4. **Borrower opens link on phone** (no login) — Mobile-friendly portal loads in <2 seconds, branded, shows required documents.
5. **Borrower uploads 10–15 files** (phone photos, PDFs) — Direct to Sydney storage; TLS 1.3; on-device quality checks (blur/glare flagged before submit).
6. **System auto-classifies & flags issues** — AI labels each file (payslip, tax return, page numbers, expiry status); manual tagging available for <90% confidence.
7. **Broker dashboard shows completeness** — Per-deal grid displays missing items, expired docs, and "bank-readiness score" (e.g., "payslip 67 days old — Westpac will reject"). One-click chase reminders or lender-ready ZIP export with audit log.
