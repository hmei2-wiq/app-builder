# QuotingAgent

## What the product is for

QuotingAgent collapses the residential trade quoting cycle from 24–72 hours of elapsed time and 2–4 hours of owner work down to **5 minutes elapsed and under 60 seconds of owner work**. Tradies snap 4–10 site photos, the AI generates a Bunnings-priced, NSW-licence-stamped itemised quote in under 60 seconds, the owner reviews and one-taps send via SMS, and accepted quotes auto-push into the existing FSM (ServiceM8 / Tradify) — eliminating double entry. The wedge is **quote speed**, the metric the market itself names as the #1 win-rate factor.

## Main customers

- **ICP:** Owner-operator or owner-plus-spouse of a 2–5 person residential trade crew in Greater Western Sydney (Parramatta, Blacktown, Penrith corridor)
- **Profile:** A$300K–A$2M annual revenue, current NSW contractor licence, quoting 5–25 jobs per week at 30–50% conversion
- **Already paying:** A$50–A$300/month for ServiceM8 or Tradify
- **Primary trades V1:** Roofers, painters (highest photo-readability and quote-pain). Electricians, plumbers, landscapers in months 3–9
- **Pricing:** A$99/month flat per crew (B2B, beats per-user FSM pricing at 3+ staff)
- **Market scale:** ~475K AU small-trade businesses; SAM ≈ A$56M ARR; 24-month SOM target ≈ A$711K ARR (540 paying Western Sydney crews)

## Main user cycle

1. **Lead lands** — Phone call, SMS, or DA notification arrives in the "Ready to Quote" tray.
2. **Capture photos** — Owner taps the lead, snaps 4–10 site photos with one button (EXIF + GPS auto-attached).
3. **Add context (optional)** — Owner types or voice-notes one sentence ("re-roof, colorbond, single-storey, gutters") — AI can infer from photos alone.
4. **AI generates draft (≤60s)** — Backend combines photos, context, saved labour rates, live Bunnings/Reece pricing, and NSW licence data into an itemised quote with materials, labour, GST, licence watermark, and statutory warranty wording. Each line carries a confidence score.
5. **Review & one-tap edit** — Below-threshold lines flagged amber. Owner taps any line to edit; totals recalculate instantly. One tap to approve when all lines are confident (≥80%).
6. **Send by SMS with read receipt** — Quote PDF link goes via Twilio AU long-code SMS (email fallback). App logs delivery and open events.
7. **Customer accepts** — Homeowner taps "Accept" or "Decline" on phone. Acceptance is timestamped and pushed back as a "won" notification; if FSM is connected, a job is auto-created.

**Optional follow-up loop:** Auto-nudge SMS at D+3 and D+7 if no customer action; rate-card learning from invoiced amounts on completed jobs (V2).
