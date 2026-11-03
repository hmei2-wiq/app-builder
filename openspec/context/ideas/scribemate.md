# ScribeMate

## What the product is for

ScribeMate is an Australian AI clinical scribe for allied health (physiotherapy, chiropractic, psychology) that **stops rejected Medicare claims before submission**. While competitors (Heidi, Lyrebird, Coviu) compete on transcription quality, ScribeMate's single wedge is **preventing revenue loss from silent Medicare claim rejections**. The product captures consult audio on-device (AU-sovereign, AWS Transcribe Medical ap-southeast-2), generates a discipline-specific SOAP note within 30 seconds, suggests the correct MBS item code with a human-readable rule trace, and runs a rejection classifier that flags high-risk claims with actionable fixes before submission. The buyer-facing value prop is "$ recovered this week," not "better notes" — target A$1,500–2,500/month per practitioner.

## Main customers

- **Primary buyer:** Solo and 2–5 practitioner allied health clinic owners (physio, chiro, psych) in Australia who bill Medicare and are bleeding 15–20% of claims to silent rejections
- **Addressable pool:** ~45,000 practitioners across the three professions in private practice; entry segment is high-volume practices losing >A$1,800/month to rejections
- **Primary user:** Treating practitioner (spends 20–35% of day on documentation; needs therapeutic alliance preserved — no typing during consults)
- **Secondary user:** Practice manager / receptionist (claim submission, rejection analytics)
- **Pricing:** B2B SaaS, A$250/month per practitioner; multi-location pricing at V2

## Main user cycle

1. **Load patient context** — Practitioner opens ScribeMate, selects patient; system pulls referral type, eligibility, YTD visit count from Cliniko; displays GREEN/AMBER/RED eligibility indicator.
2. **Capture consent** — System prompts practitioner to read consent script aloud; patient says "yes"; consent logged as immutable record.
3. **Capture audio** — Practitioner starts recording; audio captured on-device, streamed via secure WebSocket to AU-region transcription (AWS ap-southeast-2), stored encrypted in GCP australia-southeast1.
4. **Generate SOAP note** — On consult end, AI synthesises discipline-specific note (physio with outcome measures, chiro with segmental findings, psych with formulation + risk) within 30 seconds; practitioner inline-edits any clinical errors.
5. **Suggest MBS code & check rejection risk** — System runs MBS rule engine (suggested item code + rule trace) and rejection classifier (GREEN/"submit safe" or RED/"fix before submit"); RED verdicts are actionable ("missing referral date — add to Cliniko intake").
6. **Approve & file** — Single tap "Approve" writes SOAP note to Cliniko patient record, queues claim for PRODA submission, resets screen for next consult.
7. **Weekly dashboard & monthly case study** — Practice manager sees weekly dollar-recovered hero figure, top 5 rejection patterns; monthly case-study email shows "recovered A$X this month + here's what changed."

**Status:** V1 MVP deployed to Vercel (preview tier, 5 design-partner clinics). Critical flow (capture → SOAP → MBS suggest → rejection classify → file) functionally complete. Cliniko integration live. Next gates: classifier precision ≥0.80 and ≥3/5 pilots converting to paid by month 3.
