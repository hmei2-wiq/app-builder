# CEO's 20 MINUTES — Visual Meeting Deck

**Generic 20-min intro for an early-stage CEO / founder.**
Screen-share this doc. Each section is one talking beat.

> Before the call: swap in (a) the founder's name, (b) one specific
> reference from their recent public writing, (c) two or three pilot
> options shaped to their actual product/market.

---

## Topic 1 — Three principles, built into the architecture

The orchestrator is opinionated about what early-stage product work
actually rewards. Three constraints, each enforced by the system itself.

```mermaid
flowchart LR
    A["<b>Three principles for<br/>early-stage product work</b>"]:::feedback

    A --> F1["1. Customer / business<br/>before performance"]:::fb
    A --> F2["2. Simplify aggressively<br/>complexity = death"]:::fb
    A --> F3["3. Structure for<br/>non-technical readers"]:::fb

    F1 --> R1["<b>Phase gate</b><br/>ceo → differentiation → pricing<br/>refuses to write code until<br/>customer + WTP defined"]:::resp
    F2 --> R2["<b>Scale tiers</b><br/>toy → preview → launch → scale<br/>each tier <i>skips</i> infra cruft<br/>by state-machine rule"]:::resp
    F3 --> R3["<b>Markdown artifacts</b><br/>wedge.md / pricing.md /<br/>positioning.md — read by<br/>founders, not engineers"]:::resp

    classDef feedback fill:#1f2937,color:#fff,stroke:#fff,stroke-width:2px
    classDef fb fill:#fef3c7,color:#000,stroke:#92400e
    classDef resp fill:#dcfce7,color:#000,stroke:#166534
```

**Narration (30s):** "Three principles, each one a hard constraint in the
system, not a vibe. I'll walk you through one example and then I want
your read on whether it actually delivers what those principles point at."

---

## Topic 2 — What the orchestrator does, in one picture

```mermaid
flowchart TB
    Idea(["Customer idea<br/>one sentence"]):::input

    subgraph S1 ["1. Strategy (no code yet)"]
        direction LR
        CEO["ceo<br/>→ product-analysis.md"] --> Diff["differentiation<br/>→ wedge.md"] --> H1{{HUMAN<br/>checkpoint}}:::human
        H1 --> Stack["tech-stack-selector<br/>→ tech-stack.md"] --> Spec["product-spec<br/>→ 01b-product-spec.md"]
    end

    subgraph S2 ["2. Design"]
        direction LR
        Anal["analyst<br/>→ 02-system-requirements.md"] --> Des["designer<br/>→ architecture.md"] --> UX["ux-designer<br/>→ ux-design.md"] --> H2{{HUMAN<br/>checkpoint}}:::human
    end

    subgraph S3 ["3. Build (parallel)"]
        direction LR
        BE["backend<br/>→ src/ + 04-dev-plan.md"] & FE["frontend<br/>→ src/"] & DB["db-migrator<br/>→ migrations/ + seed"] --> QG["quality-gates<br/>11 layers<br/>(no doc output)"]
    end

    subgraph S4 ["4. Go-to-market"]
        direction LR
        Price["pricing<br/>→ pricing.md"] --> Pos["positioning<br/>→ positioning.md"] --> H3{{HUMAN<br/>checkpoint}}:::human
        H3 --> LP["landing-page<br/>→ landing page code"] --> Legal["legal<br/>→ legal pages + consent banner"] --> Ship["preview-ship<br/>→ deployed URL"] --> H4{{HUMAN<br/>checkpoint<br/>GO / NO-GO}}:::human
    end

    Idea --> S1 --> S2 --> S3 --> S4 --> Live(["Live URL<br/>~5–7 days"]):::output

    classDef input fill:#dbeafe,color:#000,stroke:#1e40af
    classDef output fill:#dcfce7,color:#000,stroke:#166534
    classDef human fill:#fde68a,color:#000,stroke:#b45309,stroke-width:2px
```

**Narration (45s):** "Idea in, deployed product out. Four phases. Each
arrow has a critic skill on a different model than the producer — that's
the slop guard. The yellow boxes are non-skippable human checkpoints.
Nothing auto-ships past a human 'no'."

---

## Topic 3 — Simplicity is a state-machine rule, not a vibe

The single most important diagram for an early-stage CEO — the system
literally refuses to over-build.

```mermaid
flowchart TB
    Start{"What's<br/>the goal?"}:::q

    Start -->|"Throwaway prototype"| Toy["<b>toy</b><br/>SKIPS:<br/>jobs · env · cicd · infra<br/>observability · PRR · deploy"]:::toy
    Start -->|"Public demo<br/>≤100 users"| Prev["<b>preview</b> (default)<br/>SKIPS:<br/>jobs · env · cicd · infra<br/>observability · PRR<br/>(deploys to Vercel/Fly)"]:::prev
    Start -->|"Paying customers<br/>single region"| Lau["<b>launch</b><br/>SKIPS:<br/>infra · observability · PRR"]:::lau
    Start -->|"Multi-region<br/>enterprise"| Sca["<b>scale</b><br/>SKIPS: nothing<br/>full pipeline"]:::sca

    Toy --> Out["No Terraform for an MVP.<br/>The system literally refuses<br/>to build what you don't need yet."]:::out
    Prev --> Out
    Lau --> Out
    Sca --> Out

    classDef q fill:#1f2937,color:#fff,stroke:#fff,stroke-width:2px
    classDef toy fill:#fee2e2,color:#000,stroke:#991b1b
    classDef prev fill:#fef3c7,color:#000,stroke:#92400e
    classDef lau fill:#dbeafe,color:#000,stroke:#1e40af
    classDef sca fill:#dcfce7,color:#000,stroke:#166534
    classDef out fill:#f3f4f6,color:#000,stroke:#374151
```

**Narration (30s):** "Most engineers default to launch-tier infra for a
toy. The orchestrator won't let me. The default is *preview* — the
cheapest thing that still proves customer demand. That's an architectural
constraint, not a discipline I have to remember."

---

## Topic 4 — Seven products already shipped through it

Proof it's not a slide deck.

```mermaid
flowchart TB
    Orch(["build-product-v2<br/>orchestrator"]):::orch

    Orch --> P1["<b>QuotingAgent</b><br/>AU tradies<br/>quote in 60s"]:::au
    Orch --> P2["<b>Realty Intelligence</b><br/>AU mortgage brokers<br/>doc collection"]:::au
    Orch --> P3["<b>ProjectIntelligence AU</b><br/>Sydney roofers<br/>DA digest"]:::au
    Orch --> P4["<b>Ledgerly</b><br/>AU bookkeepers<br/>GST review queue"]:::au
    Orch --> P5["<b>ScribeMate</b><br/>AU allied health<br/>Medicare claims"]:::au
    Orch --> P6["<b>BuildPM</b><br/>AU renovations<br/>AI project manager"]:::au
    Orch --> P7["<b>SkillForge</b><br/>corporate L&D<br/>in-IDE learning"]:::other

    classDef orch fill:#1f2937,color:#fff,stroke:#fff,stroke-width:2px
    classDef au fill:#dcfce7,color:#000,stroke:#166534
    classDef other fill:#dbeafe,color:#000,stroke:#1e40af
```

**Narration (20s):** "Each one has the full artifact stack: wedge,
pricing, positioning, landing page, deployed app. Pick whichever is
closest to your domain — I'll walk through that one's artifacts in
90 seconds."

> **Pre-call task:** pre-load the artifact tabs for the ONE product
> closest to the founder's market. Don't ask them to choose live —
> momentum matters.

---

## Topic 5 — The offer, made concrete

Don't leave the 5-day pilot abstract. Make them pick.

```mermaid
flowchart LR
    Offer(["<b>5-day no-cost build</b><br/>You pick. I deliver.<br/>The deliverable is yours."]):::offer

    Offer --> O1["<b>Internal ops tool</b><br/>An internal AI workflow your<br/>team has wanted but hasn't<br/>found time to build"]:::opt
    Offer --> O2["<b>Adjacent product line</b><br/>An ICP / vertical you've<br/>debated internally — same engine,<br/>new market, validated in a week"]:::opt
    Offer --> O3["<b>Strategic artifact only</b><br/>Wedge + pricing + positioning +<br/>landing page for a pivot or<br/>new line — no code"]:::opt

    O1 --> Out(["Whichever you pick, you get<br/>the full artifact stack +<br/>a working preview URL"]):::out
    O2 --> Out
    O3 --> Out

    classDef offer fill:#1f2937,color:#fff,stroke:#fff,stroke-width:2px
    classDef opt fill:#dbeafe,color:#000,stroke:#1e40af
    classDef out fill:#dcfce7,color:#000,stroke:#166534
```

**Narration (45s):** "Three shapes. Pick the one that's most useful to
you internally. No sales pitch attached — the deliverable is yours
either way. If none of these fit, tell me which problem in your business
would, and I'll come back with a v2."

> **Pre-call task:** sharpen these three options against the founder's
> actual product / roadmap. Generic options land generic.

---

## Topic 6 — The four questions you actually want answered

Lead with the bluntest first while there's still time to dig in.

```mermaid
flowchart TB
    Q1["<b>1. Gimmick check</b><br/>What part of the email or demo<br/>felt over-promised? Unvarnished —<br/>same register a senior engineer<br/>would use with another."]:::q1

    Q2["<b>2. The buyer test</b><br/>If you were the buyer for this,<br/>what's the smallest thing that<br/>would make you pay vs not pay?"]:::q2

    Q3["<b>3. Complexity leak</b><br/>What in these artifacts would your<br/>non-technical co-founder NOT<br/>understand or care about?"]:::q3

    Q4["<b>4. Listening question</b><br/>In your business right now,<br/>what's the bottleneck on shipping<br/>AI-native product work?<br/>Tooling / judgment / distribution / buy-in?"]:::q4

    Q1 --> Q2 --> Q3 --> Q4

    classDef q1 fill:#fee2e2,color:#000,stroke:#991b1b,stroke-width:2px
    classDef q2 fill:#fef3c7,color:#000,stroke:#92400e
    classDef q3 fill:#dbeafe,color:#000,stroke:#1e40af
    classDef q4 fill:#dcfce7,color:#000,stroke:#166534,stroke-width:2px
```

**Order matters.** Bluntest first — there's still time to dig into the
answer. Question 4 is the one with the most asymmetric value (intelligence
about the founder's actual constraint right now).

---

## Topic 7 — Time budget (don't overrun any block)

```mermaid
gantt
    title 20-minute meeting plan
    dateFormat  mm
    axisFormat %M

    section Land
    Permission to drive            :a1, 00, 1m

    section Show
    Topic 1 — three principles     :a2, after a1, 1m
    Topic 2 — pipeline picture     :a3, after a2, 2m
    Topic 3 — scale tiers          :a4, after a3, 1m
    Topic 4 — seven products       :a5, after a4, 1m

    section Offer
    Topic 5 — pick a pilot         :a6, after a5, 5m

    section Feedback
    Topic 6 — four questions       :a7, after a6, 6m

    section Close
    One decision + one open door   :a8, after a7, 3m
```

If anything overruns, **cut Topic 4** (the seven-products slide). The
offer and the feedback questions are non-negotiable.

---

## Topic 8 — Decision tree for how the call ends

```mermaid
flowchart TB
    End{"How does the<br/>20 min end?"}:::q

    End -->|"They pick a pilot"| W1["<b>WIN</b><br/>Confirm brief + delivery date<br/>in writing TODAY before<br/>the post-call edge fades"]:::win

    End -->|"They give sharp critique<br/>but no pilot"| W2["<b>WIN</b><br/>Capture verbatim. Send a<br/>thank-you with the one<br/>thing you'll change."]:::win

    End -->|"Polite but vague"| F["<b>SOFT FAIL</b><br/>Ask: 'Open to a 20-min<br/>follow-up in 4 weeks once<br/>I've shipped two more?'<br/>Keep the thread alive."]:::soft

    End -->|"Either way"| Always["Open standing offer:<br/>'sanity-check on a roadmap call,<br/>no expectation of reciprocity.'<br/>Costs nothing, signals posture."]:::always

    classDef q fill:#1f2937,color:#fff,stroke:#fff,stroke-width:2px
    classDef win fill:#dcfce7,color:#000,stroke:#166534,stroke-width:2px
    classDef soft fill:#fef3c7,color:#000,stroke:#92400e
    classDef always fill:#f3f4f6,color:#000,stroke:#374151
```

---

## One-line reminders

| Do | Don't |
|---|---|
| Ask permission to drive the 20 min in the first 60 seconds | Re-narrate context the founder already has |
| Show the artifact stack (markdown), not the code | Screen-share the IDE for non-technical founders |
| Reference one specific phrase from their recent writing | Generic "your AI post" — sounds skimmed |
| Send the follow-up one-pager within 30 min of hangup | Wait until tomorrow — momentum dies |
| Hold founder-to-founder posture, not applicant | Bring up any prior rejection or rejection-shaped history |

---

## Final check before you join the call

- [ ] This doc open in tab 1, ready to screen-share
- [ ] Best-fit product's artifact stack open in tabs 2–5
- [ ] Founder's most recent public post open in tab 6 — note the **exact phrase** you'll quote
- [ ] Their company site open in tab 7 — for the pilot-pitch sharpening
- [ ] Three pilot options sharpened against their actual product / roadmap
- [ ] Mic / camera / share tested
- [ ] Follow-up one-pager template open in a draft email, ready to fill and send
