# Ends Tool Product Requirements

Source: [Ends Tool Product Requirements](https://woolworths-agile.atlassian.net/wiki/spaces/WIQ/pages/34998812920/Ends+Tool+Product+Requirements)

<!-- Export notes: Page content preserved as Markdown. Original local VS Code section links have been converted to document-relative anchors. ADR-0001 links point to the Confluence decision page linked in the source. Empty table rows have been omitted. Requirements without IDs remain without IDs. -->

This is a living document to help us agree on the requirements for the ends tool.

| | |
| --- | --- |
| **Status** | Draft for review |
| **Owner** | Zilinka Jiang |
| **Contributors** | Gavin Steacy (engineering), Claire (security, observability, alerting, code coverage), Will (data), Nikhil (data) |
| **Last updated** | 2026-10-19 |
| **Prototype** | Branch `updating-demo-20260929`, `promo_end_to_end/frontend/src/ends/` and the backend routes it calls |
| **Glossary** | `CONTEXT.md` — terms in **bold** below are defined there |
| **Decisions** | [ADR-0001: Ends is a separate app with its own data](https://woolworths-agile.atlassian.net/wiki/spaces/WIQ/pages/34999009450) |

## 1. Purpose

Build a production **Ends** tool that lets category teams nominate promotions for ends, lets the PCV ends team build the weekly **ends plan**, lets CDs approve it, and sends it to stores.

### 1.1 Goals

1. One place for category teams to nominate promotions for ends before the weekly deadline, and ends team to show which end they landed on.
2. One shared plan that the ends team can build together, at the same time, with metrics and governance checks handled for them
3. A mechanism to enable approvals by each CD for their area
4. A store-ready PDF of the approved plan, with revisions when late changes happen. These are sent to the store by email.⚠️(TBD how it’s sent, and what happens when a supplier helps to build an end)
5. To users, Ends and Brochure feel like one tool (contingent on Brochure UX refactor to Qbit in Q2/Q3)

### 1.2 How to read the requirements

- **IDs** are stable; reference them in Jira tickets.
- **Priority** uses MoSCoW: **M** must (MVP), **S** should (MVP if time allows), **C** could (later), **W** won't
  - MVP being defined as what will be delivered by end of December, for testing in January & rollout in February
- **Verification** says how we will know the requirement is met.
- ⚠️ **Confirm** marks a requirement built on an assumption that must be checked; see [section 9](#9-open-issues).

## 2. Scope

### 2.1 In scope (MVP)

- Ingesting promotions from **PMR** for Ends.
- The **ends noms tab**: nominating promotions for ends.
- The **ends planner**: building the national ends plan for a week.
- **Constraints** and **guardrails** on the plan.
- **CD approval** by area, with comments and rejection.⚠️ (process tbd)
- Store **PDF** of the approved plan, including revisions.
- **AI store visuals** of ends (for the ends team, CDs and the One Customer team).
- Sign-in, roles, shared saving, audit log, notifications.
- Look and feel consistent with Brochure.⚠️ (either consistent with Brochure or rest of the wiq tools)

### 2.2 Out of scope

| Item | Status |
| --- | --- |
| AI assistant (ends agent chat) | Version 2 |
| Store clusters (one plan per cluster) | Later; the MVP must not make this hard to add (see [FR-PLAN-10](#43-ends-planner)) |
| Copy an ends plan to another state/cluster | Not applicable now; ask users whether it is needed ⚠️ |
| Promo slotting, deal sheet, price governance screens | Separate existing tool; not rebuilt |
| Online activation | Out of scope |
| Brochure | Separate app (`projects/brochure`) with its own data ([ADR-0001](https://woolworths-agile.atlassian.net/wiki/spaces/WIQ/pages/34999009450)) |
| Sharing nominations between Ends and Brochure | Won't: they are separate by design. Later the two may reflect each other through PMR or an integration |
| A "CMs view" that nominates for any activation in one place | Later |
| Live PMR feed | Later; MVP reloads at least daily |
| Store write-back (done, photos, compliance) | Out of scope |

## 3. Users and roles

### 3.1 Roles

| Role | Who | What they do in the tool |
| --- | --- | --- |
| **Category/commercial team** (CM, ACM, CA) | Manage a category. CM, ACM and CA have the same permissions | Nominate their category's promotions; view the planner; comment |
| **MM - merchandising manager** | Manages a group of categories | View their categories; nominate on behalf of their category teams; comment |
| **CD - commercial director** | Leads an area (e.g. Grocery, Fresh); 3-4 in the business | View their area; approve or reject their area's ends for a week; comment |
| **Ends team** (PCV) | Builds the ends plan; about 20 editors at once | Edit the plan; accept late nominations; generate store visuals; send the PDF |
| **One Customer team** | Plans events and strategy (e.g. Valentine's Day, footy final) | View all; comment; view store visuals |
| **PCV/MCV admin** | Owns rules and settings | Maintain constraints, guardrails, deadlines and the list of ends |
| **Store team** | Store managers and staff | Receive the PDF and builds the ends. No sign-in |

### 3.2 Permissions

| | **View noms** | Nominate | Edit ends plan | Comment | Approve | View | Admin |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Category team | Can view all | Own categories | – | ✓ | – | Planner (read-only), team’s nominations | – |
| MM | Can view all | Own categories | – | ✓ | – | Own categories | – |
| CD | Can view all | – | – | ✓ | Own area | Own area | – |
| Ends team | Can view all | Accepts late nominations | ✓ | ✓ | – | All | - |
| One Customer team | Can view all | – | – | ✓ | – | All | – |
| PCV admin | Can view all | – | – | ✓ | – | All | ✓ |
| Store team | | – | – | – | – | PDF only | – |

> **For Gavin:** confirm where roles can come from (recommended: Woolworths/Google groups per role, managed through an existing access process) and how category → CM and category → MM → CD ownership is sourced (recommended: from data, keyed by email not name, with an admin screen to correct it). See [OI-G2](#92-for-gavin-engineering).

## 4. Functional requirements

### 4.0 Weekly workflow

```text
PMR load ──► Category teams nominate ──────────────┐
  (daily)         │  (deadline, same every week)   │ in parallel ⚠️
                  ▼                                ▼
            Ends team builds the national ends plan
                  │
                  ▼
     Constraints enforced · Guardrails shown
                  │
                  ▼
     Each CD approves (or rejects) their area
                  │
                  ▼
        PDF sent to stores ──► late change? ──► re-approve ──► "Revised" PDF
```

⚠️ **Confirm with users:** the order of steps, and that nominating and plan building happen in parallel because there is much debate about what goes on an end. ([OI-U1](#91-to-confirm-with-users))

### 4.1 Promotion ingestion (PMR)

| ID | Requirement | Pri | Verification | **NS review** |
| --- | --- | --- | --- | --- |
| FR-ING-01 | The tool loads promotions for Ends from PMR (via its BigQuery source) once a day at scheduled time | M | Scheduled load runs daily; load time and row count logged | Agree |
| FR-ING-02 | Users can see when promotion data was last loaded. | M | "Data as at" timestamp visible on noms tab and planner | Agree |
| FR-ING-03 | If a promotion that has been nominated or placed changes or is cancelled in PMR, the tool **flags** it on the nomination and on the affected end. It never removes it silently. We also keep a log of changes. ⚠️ | S | Test: change and cancel a placed promotion in source; flag appears, placement kept | Change from must to should |
| FR-ING-04 | If a flagged change affects an approved area, that area is marked as needing re-approval. ⚠️ | S | Test: approved area returns to "needs re-approval" after source change | Changed from must to should |
| FR-ING-05 | The design allows a more live PMR feed later without changing how nominations and plans are stored. | C | Design review | Changed from should to could |
| FR-ING-06 | If a load fails, the tool keeps working on the last good data and shows that data is stale. | M | Test: failed load leaves previous data and shows warning; alert raised | Agree |

### 4.2 Ends noms tab

Prototype reference: `ends/Nominations/`, `ends/EndsNominationsPage.tsx`.

| ID | Requirement | Pri | Verification | **NS review** |
| --- | --- | --- | --- | --- |
| FR-NOM-01 | Category teams see the promotions for their categories for a selected week. MMs and CDs see all their categories. PCV team sees whole of business | C | Role-based test per role | Change from must to couldTbc if this is feasibleIn BPT cat teams see all lines. |
| FR-NOM-02 | A category team member can nominate or withdraw a promotion for ends for a week.We can see who’s made the last change | M | Test | Agree |
| FR-NOM-03 | When nominating, the user may add a **preferred End Type** (e.g. freezer), a priority and a comment. They do not choose a specific end. | S | Test | Change from must to should given MVP is freezer onlyAgree - check with stakeholders |
| FR-NOM-04 | Each week has a nomination deadline. The deadline rule is the same every week and set by PCV. | M | Admin sets rule; deadline shown on noms tab | Agree |
| FR-NOM-05 | After the deadline, nominations are locked for category teams. | M | Test: nominate after deadline is refused with a clear message | Agree |
| FR-NOM-06 | The ends team can add, change or remove a nomination after the deadline (a **late change**, e.g. a product recall). A reason is required and recorded. | M | Test: late change without reason is refused; with reason is logged | Agree |
| FR-NOM-07 | Nominations show the classification and metrics from the source data (e.g. classification, PSU, DOS, display-incremental sales and GP), read-only. ⚠️ (need to confirm full list of metrics and if it is read only) | M | Columns present and match source | Agree |
| FR-NOM-08 | Users can filter, sort and search nominations (e.g. by category, classification, status, nominated or not).Search: free text for product / assortment, dropdowns for category, MM. Buttons for classification and nomination status) | M | Test | Agree |
| FR-NOM-09 | Users can see whether each nomination has been placed on an end, and where.This will be a write-back to the nominations tab via an extra column - not editable by users | M | Test | Agree |
| FR-NOM-10 | The noms tab handles 100 category team users submitting in the hour before the deadline (see [NFR-PERF-04](#51-performance)). | M | Load test | Agree |
| FR-NOM-11 | Ends nominations are separate from Brochure nominations and are never shared ([ADR-0001](https://woolworths-agile.atlassian.net/wiki/spaces/WIQ/pages/34999009450)). | M | Design review | Agree |

### 4.3 Ends planner

Prototype reference: `ends/EndsPlanPage.tsx`, `ends/EndsPlanner/`, `ends/planStore.ts`, `ends/plan.ts`.

| ID | Requirement | Pri | Verification |
| --- | --- | --- | --- |
| FR-PLAN-01 | There is one **ends plan** per week. In the MVP the plan's store scope is **National**. | M | Test |
| FR-PLAN-02 | The plan covers a standard list of ends, each with an **End Type** (standard front/back, special purpose such as beauty, special equipment such as freezer). PCV maintains the list. | M | Admin can add, retire and edit ends and End Types |
| FR-PLAN-03 | Ends have a **priority order**, so stores with fewer ends set up the first N ends. | M | Priority visible in planner and PDF |
| FR-PLAN-04 | The ends team can place nominated promotions on ends, move them between ends and shelves, and remove them (e.g. drag and drop). | M | Test |
| FR-PLAN-05 | The ends team can **auto-populate** empty ends from the nominations pool, by a chosen metric and classification filter. Auto populate respects strategic guiding principles where possible. | S | Test: auto-populate fills only empty spots and respects constraints |
| FR-PLAN-06 | Each end is assigned to one CD area for the week. A default comes from the list of ends; the ends team can change it. ⚠️ | M | Test |
| FR-PLAN-07 | The planner shows, per week, the status of each CD area: not started, in progress, awaiting approval, approved, rejected, needs re-approval. | C⚠️ | Test |
| FR-PLAN-08 | Category teams, MMs, CDs and the One Customer team can view the planner read-only and comment on an end or a placement. | C⚠️ | Role-based test |
| FR-PLAN-09 | Users can switch weeks. The current week plus 12 weeks ahead can be edited; weeks that have started are read-only. ⚠️ | M | Test |
| FR-PLAN-10 | **Store clusters:** the data model and API treat "store scope" as part of what identifies a plan (Week + store scope), with National as the only scope in the MVP. Adding clusters later must not need a data migration of existing plans or a rewrite of the planner. | M | Design review by Gavin |
| FR-PLAN-11 | Last year's plan for the same week is available as a planning reference. ⚠️ (to be confirmed if required) | C | Test |
| FR-PLAN-12 | The ends team can export the plan as CSV.⚠️ (to be confirmed if required) | C | Test |
| | The ends team can add, delete shelves. And can merge and split shelves either vertically or horizontally | M | |
| | Ends team can specify number of facings of a product and have the DOS update | S⚠️ | |

### 4.4 Constraints and guardrails

Prototype reference: `ends/EndsGuardrailPanel.tsx`.

A **constraint** is a physical limit; a plan that breaks one cannot be set up in store. A **guardrail** is advisory; the CD decides.

| ID | Requirement | Pri | Verification |
| --- | --- | --- | --- |
| FR-RULE-01 | The planner does not allow a placement/facings update that breaks a constraint, and says why. (e.g. is space aware) | M | Test |
| FR-RULE-02 | MVP constraints: maximum shelf rows per end (currently 6) and maximum height (currently 43 notches). | M | Test each |
| FR-RULE-03 | MVP guardrails: empty ends (warning); classification mix (information); promotion coverage against slotted promotions (warning) | M | Test each |
| FR-RULE-04 | Guardrail results are shown to the ends team while planning and to the CD when approving. | M | Test |
| FR-RULE-05 | A failed guardrail does not block approval. The CD sees it and decides; if they approve with a failed guardrail, they give a reason, which is recorded. | M | Test |
| FR-RULE-06 | PCV owns the rules. A PCV admin can change limits and switch rules on or off without a release. | M | Admin test |
| FR-RULE-07 | New kinds of rule can be added with a release, without changing existing rules or plans. New rules will be found over time. | M | Design review |

### 4.5 Approval

| ID | Requirement | Pri | Verification |
| --- | --- | --- | --- |
| FR-APR-01 | The ends team submits the plan for approval. Each CD then approves or rejects **their area** for the week. | M | Test |
| FR-APR-02 | Only CDs can approve, and only for their own area. | M | Role-based test |
| FR-APR-03 | Rejecting requires a comment and returns the area to the ends team. | M | Test |
| FR-APR-04 | The PDF can be sent to stores only when every CD area for the week is approved. | M | Test |
| FR-APR-05 | Editing an approved area reopens it for approval. ⚠️ | M | Test |
| FR-APR-06 | **Urgent change:** the ends team can send an urgent change (e.g. a recall) to stores before re-approval, with a reason. The CD approves it afterwards. ⚠️ | M | Test: urgent send records reason; area shows "approval pending after send" |
| FR-APR-07 | Every approval, rejection, waived guardrail and urgent change is recorded: who, when, what, and why. | M | Audit log test |

### 4.6 Store PDF

Prototype reference: `ends/Exports/`.

| ID | Requirement | Pri | Verification |
| --- | --- | --- | --- |
| FR-PDF-01 | The tool produces a store-ready PDF of the approved ends plan: each end in priority order, with its End Type, products, shelf layout and promotion details. | M | PDF review with users |
| FR-PDF-02 | The PDF is sent to the store team from the tool. **How** (an email list, or loading into a system that sends to all store managers) is not yet decided. | M | ⚠️ [OI-U6](#91-to-confirm-with-users) |
| FR-PDF-03 | Sending a change after the first send produces a new version marked "Revised" with a version number, with the changed ends highlighted. ⚠️ | M | Test |
| FR-PDF-04 | Every sent version is kept and can be downloaded again. | S⚠️ | Test |
| FR-PDF-05 | AI store visuals are **not** included in the store PDF. | M | PDF review |
| | The tool produces a visual summary of each end with key metrics for ends team | M | |
| | The tool produces a visual summary of each end without key metircs for store teams | M | |
| | The store PDFs and sales plans are sent to the relevant downstream systems (e.g. Replenish Central for store forecasts, Planogram2Go for execution)Do we still need to send to Blue Yonder Space Planning? | M | |

### 4.7 AI store visuals ⚠️

Prototype reference: backend `routes/storeVisual.ts`, `ends/Visuals/`.

| ID | Requirement | Pri | Verification |
| --- | --- | --- | --- |
| FR-VIS-01 | The ends team, CDs and the One Customer team can view an AI-generated image of how an end could look. | M | Role-based test |
| FR-VIS-02 | Images are generated when someone asks, not automatically for every end. | M | Test |
| FR-VIS-03 | Every image is clearly labelled "AI-generated, indicative only". | M | UI review |
| FR-VIS-04 | Images are stored with the plan version they were generated from, so they are not regenerated unnecessarily, and are marked out of date when the end changes. | S | Test |
| FR-VIS-05 | Image generation is rate-limited and its cost is monitored. | M | Rate limit test; cost visible on dashboard |
| FR-VIS-06 | Store visuals are not shown to the store team. | M | Test |

### 4.8 Working together (shared saving)

| ID | Requirement | Pri | Verification |
| --- | --- | --- | --- |
| FR-COL-01 | All work is saved on the server, not in the browser. Users never lose work by reloading or switching devices. | M | Test: edit, reload on another browser, change is there |
| FR-COL-02 | Changes save automatically in the background, without blocking typing or clicking. | M | Test |
| FR-COL-03 | Up to 20 ends team members can edit the same week's plan, including the same end and ‘cell’ (e.g. shelf), at the same time. | M | Load and concurrency test |
| FR-COL-04 | Edits to **different** spots on the same end (different shelves or products) merge without loss. | M | Concurrency test |
| FR-COL-05 | If two people change the **same** spot, the second person is told and shown the other person's change; nothing is silently overwritten. | M | Concurrency test |
| FR-COL-06 | Other users' changes appear within 2 seconds, without a page reload. | M | Test |
| FR-COL-07 | Users can see who last changed an end and when. | S | Test |
| FR-COL-08 | Live cursors and instant co-editing, as in Google Sheets, are **not** required. | W | – |
| | Undo/redo works like Gsheets, but with limited history. E.g. 20 actions, say | S | |

> Brochure's shared saving (last save wins per page, changes picked up every ~20 s) does not meet FR-COL-04 to FR-COL-06 and will not be copied. See [ADR-0001](https://woolworths-agile.atlassian.net/wiki/spaces/WIQ/pages/34999009450).

### 4.9 Notifications and to-dos⚠️ (TBC with PCV)

| ID | Requirement | Pri | Verification |
| --- | --- | --- | --- |
| FR-NTF-01 | Each user sees an in-app list of what needs their action (e.g. nominations due, areas awaiting approval, rejected areas, comments on their items). _(Assumption)_⚠️ (TBC) | S | Test |
| FR-NTF-02 | Email reminders before the nomination deadline, and email to the CD when their area is awaiting approval. _(Assumption)_⚠️(TBC) | S | Test |
| FR-NTF-03 | No shared notifications across Ends and Brochure.⚠️ | W | – |

### 4.10 Audit and history⚠️ (TBC with PCV)

| ID | Requirement | Pri | Verification |
| --- | --- | --- | --- |
| FR-AUD-01 | The tool records who changed what and when for nominations, placements, approvals, waived guardrails, late changes, urgent changes, sends and admin settings. _(Assumption)_ | M | Audit log test |
| FR-AUD-02 | The ends team and PCV admins can view the change history of a week's plan. | S | Test |
| FR-AUD-03 | Plans, nominations and the audit log are kept for at least 2 years. ⚠️ (TBC) | M | Retention policy configured |

### 4.11 One tool with Brochure

| ID | Requirement | Pri | Verification |
| --- | --- | --- | --- |
| FR-ONE-01 | Users sign in with Woolworths single sign-on. Moving between Ends and Brochure needs no second sign-in. | M | Test |
| FR-ONE-02 | Ends uses the same design system as Brochure. ⚠️ Or at least plan to migrate Brochure to same system if not | M | UI review |
| FR-ONE-03 | A shared top navigation lets users switch between Brochure and Ends. | M | Test |
| FR-ONE-04 | The Week picker and Week format (Wednesday start date) are the same in both apps. Or at least when you are on one week in one tool, the same week opens in the other tool. | M | UI review |

### 4.12 Administration ⚠️ (tbc with PCV)

| ID | Requirement | Pri | Verification |
| --- | --- | --- | --- |
| FR-ADM-01 | PCV admins maintain the list of ends, End Types, priority order and default CD area for each end. | M | Test |
| FR-ADM-02 | PCV admins maintain the nomination deadline rule. | M | Test |
| FR-ADM-03 | PCV admins maintain constraint and guardrail settings (FR-RULE-06). | M | Test |
| FR-ADM-04 | PCV admins can correct category → CM and category → MM → CD ownership. ⚠️ Gavin | S | Test |

## 5. Non-functional requirements

### 5.1 Performance

Measured on the corporate network, at peak load (NFR-PERF-04), at the 95th percentile (p95) unless stated.

| ID | Requirement | Pri | Verification |
| --- | --- | --- | --- |
| NFR-PERF-01 | **Typing and interactions** (typing in a cell, clicking, dragging) respond on screen in under 100 ms, like a spreadsheet. Saving happens in the background. | M | Browser performance test |
| NFR-PERF-02 | **Switching weeks** shows the new week ready to use in under 5 s (p95), and under 2 s at the median. | M | Load test |
| NFR-PERF-03 | Other users' changes appear within 2 s (FR-COL-06). | M | Load test |
| NFR-PERF-04 | **Peak load:** 100 category team users submitting nominations in the hour before the deadline, plus 20 ends team users editing the same week's plan, plus CDs and viewers, all at once. | M | Load test at this profile |
| NFR-PERF-05 | Generating the store PDFs takes under 30 s. _(Assumption)_ _(even when we move to a cluster level, e.g. up to 100 pdfs, say)_ | S | Test |

### 5.2 Availability

| ID | Requirement | Pri | Verification |
| --- | --- | --- | --- |
| NFR-AVL-01 | 99.5% availability during business hours (07:00–19:00 Sydney time, Monday–Friday), measured monthly. | M | Uptime monitoring report |
| NFR-AVL-02 | Planned maintenance happens outside business hours, up to 1 hour a week, and does not count against NFR-AVL-01. | M | Change calendar |
| NFR-AVL-03 | No planned downtime in the 48 hours before a nomination deadline or approval deadline. | M | Change calendar |
| NFR-AVL-04 | No saved work is lost in an outage. | M | Backup and restore test |

### 5.3 Security — _Claire to complete_

> **TODO (Claire):** suggested starting points.

- Sign-in through Woolworths single sign-on; no local accounts.
- Role-based access enforced on the server for every request (section 3.2), not only hidden in the UI.
- Category teams can only change their own categories' nominations; CDs can only approve their own area.
- Audit log (FR-AUD-01) is tamper-resistant.
- Data classification of promotion and sales data; encryption in transit and at rest.
- Secrets in a secret manager; none in code or config.
- Store PDF distribution list protected; PDFs contain no data beyond what stores need.
- AI store visuals: what data is sent to the image model, and whether that is approved.
- Dependency and vulnerability scanning in CI.

### 5.4 Observability — _Claire to complete_

> **TODO (Claire):** suggested starting points.

- Structured logs with user, request and week identifiers.
- Metrics for NFR-PERF-01 to NFR-PERF-03 (real user timings), error rates and PMR load results.
- Tracing across frontend, backend and BigQuery.
- Dashboard of AI image generation volume and cost (FR-VIS-05).

### 5.5 Alerting — _Claire to complete_

> **TODO (Claire):** suggested starting points.

- Alert when availability or performance falls below target in business hours.
- Alert when the daily PMR load fails or data is older than 24 hours (FR-ING-06).
- Alert on raised error rates, especially in the 48 hours before a deadline.
- Alert when AI image cost passes a set budget.
- Who is on call, and response times.

### 5.6 Code quality and coverage — _Claire to complete_

> **TODO (Claire):** suggested starting points.

- At least 80% coverage of business logic (constraints, guardrails, approval states, merging of concurrent edits, permissions).
- Automated tests for every role in section 3.2.
- Concurrency tests for FR-COL-03 to FR-COL-05.
- Load tests for NFR-PERF-04 run before each release that touches the planner or noms tab.

## 6. Data

| Data | Source | Owner | Notes |
| --- | --- | --- | --- |
| Promotions | PMR, via BigQuery | PMR / Will ⚠️ | Loaded at least daily |
| Classifications and metrics (PSU, DOS, incrementals) | Same source as nominations in the prototype | Will ⚠️ | Read-only in the tool |
| Category, CM, MM, CD ownership | To be decided | Gavin ⚠️ | Key by email, not name |
| Ends list, End Types, priorities, default CD areas | Ends tool admin | PCV | |
| Nominations, ends plans, approvals, comments, audit | Ends tool database | Ends tool | Separate from Brochure ([ADR-0001](https://woolworths-agile.atlassian.net/wiki/spaces/WIQ/pages/34999009450)) |
| Store PDFs and store visuals | Ends tool storage | Ends tool | Kept with plan version |

The prototype reads `gcp-wow-wiq-038-dev.nominations_tool_prod.future_nominations_input_v` for ends. Gavin and Will to confirm the production source.

## 7. Assumptions

These defaults were chosen without user input and should be challenged in review.

1. An audit log is needed (FR-AUD-01).
2. An in-app to-do list and email reminders are wanted (FR-NTF-01, FR-NTF-02).
3. CSV export of the plan is useful to the ends team (FR-PLAN-12).
4. Business hours are 07:00–19:00 Sydney time, Monday–Friday (NFR-AVL-01).
5. The store PDF should be generated within 30 s (NFR-PERF-05).
6. ACMs and CAs are a kind of category team member with CM permissions, not separate roles.

## 8. Design for later

The MVP must not make these hard to add:

- **Store clusters:** one ends plan per cluster instead of national (FR-PLAN-10). How stores are clustered is not decided.
- **AI assistant** (version 2): the prototype's ends agent.
- **Live PMR feed** (FR-ING-05).
- **Ends and Brochure reflecting each other**, and a single "CMs view" for nominating to any activation.
- **New guardrails** as they are discovered (FR-RULE-07).

## 9. Open issues

### 9.1 To confirm with users

| ID | Question | Related |
| --- | --- | --- |
| OI-U1 | Is the weekly workflow right, and do nominating and plan building really happen in parallel? | 4.0 |
| OI-U2 | When PMR changes a nominated or placed promotion, is flagging (not removing) right, and should approved areas need re-approval? | FR-ING-03, FR-ING-04 |
| OI-U3 | Changes after approval: reopen for approval; urgent changes sent first and approved after; "Revised" PDF with changes highlighted. | FR-APR-05, FR-APR-06, FR-PDF-03 |
| OI-U4 | Is it right that category teams only nominate (with a preferred End Type) and do not pick a specific end? | FR-NOM-03 |
| OI-U5 | How many weeks ahead can be edited, when do weeks become read-only, and how long is history kept? (Placeholder: current + 12 weeks; read-only once started; 2 years.) | FR-PLAN-09, FR-AUD-03 |
| OI-U6 | How does the PDF reach stores: an email list, or loading into a system that sends it to all store managers? (e.g. Plannogram2Go/Blue Yonder) | FR-PDF-02 |
| OI-U7 | Is copying an ends plan to another state/cluster needed for MVP? | 2.2 |
| OI-U8 | Is each end assigned to one CD area per week, with a fixed default? E.g. Front 3v5 food v non-food. Back 4v4. Allowed to flex with agreement | FR-PLAN-06 |

### 9.2 For Gavin (engineering)

| ID | Question | Related |
| --- | --- | --- |
| OI-G1 | Record the reasons for building Ends as a separate app. | [ADR-0001](https://woolworths-agile.atlassian.net/wiki/spaces/WIQ/pages/34999009450) |
| OI-G2 | Where do roles, and category → CM → MM → CD ownership, come from? Is the recommended approach feasible? | 3.2, FR-ADM-04 |
| OI-G3 | Is "Woolworths single sign-on" the same as the Google IAP sign-in Brochure uses, or a separate identity provider? | FR-ONE-01 |
| OI-G4 | Confirm the design for store clusters (FR-PLAN-10) and for merging concurrent edits (FR-COL-04, FR-COL-05). | 4.3, 4.8 |

### 9.3 For Will (data)

| ID | Question | Related |
| --- | --- | --- |
| OI-W1 | Are classifications and metrics in the MVP, and who owns and maintains the data that produces them? | FR-NOM-07 |
| OI-W2 | What is the production source for ends promotions and nominations input? | 6 |

### 9.4 For Claire

| ID | Question | Related |
| --- | --- | --- |
| OI-C1 | Complete security, observability, alerting and code coverage requirements. | 5.3–5.6 |

### 10 References

[https://docs.google.com/presentation/d/1dVFzUY42f8vpEKparuoz1GKmyzu7KrccNTTjXI_rQZg/edit?slide=id.g24235dd4b18_0_1079#slide=id.g24235dd4b18_0_1079](https://docs.google.com/presentation/d/1dVFzUY42f8vpEKparuoz1GKmyzu7KrccNTTjXI_rQZg/edit?slide=id.g24235dd4b18_0_1079#slide=id.g24235dd4b18_0_1079)


-----------------------------------


# Ends Accelerator

## Table of Contents

- [Context](#context)
- [Requirements](#requirements)
  - [Engineering Requirements](#engineering-requirements)
- [System Design](#system-design)
  - [Options Considered](#options-considered)
    - [UI](#ui)
    - [Backend](#backend)
- [Data Design](#data-design)
- [Other](#other)
  - [Observability & Monitoring](#observability--monitoring)
  - [Interfaces & APIs](#interfaces--apis)
- [Decision Register](#decision-register)
- [Questions](#questions)

# Context

The goal of this project is to design a system that makes “ends” production ready, while allowing future use cases to be added to the same code base without significant rewrite.

To achieve this, we are building a long-lived application rather than a point tool. The design treats the work as a software product from the outset, grounded in modern software engineering practices and design principles, rather than as an exploratory prototype. The emphasis is on engineering software that is maintainable and easy to operate over time.

**Design principles**

- **Production ready:** the system is built to run reliably in production, not just to demonstrate feasibility.
- **Extensible by design:** new use cases can be added to the same platform without significant rewrite.
- **Application, not a point tool:** the architecture supports growth beyond the initial scope.
- **Maintainable and operable:** the codebase and runtime are straightforward for future engineers to understand, change, and support.
- **Modern engineering practices:** the design follows current industry standards for software structure, testing, and delivery.

# Requirements

Function Requirements: [https://woolworths-agile.atlassian.net/wiki/spaces/WIQ/pages/34998812920](https://woolworths-agile.atlassian.net/wiki/spaces/WIQ/pages/34998812920)

Key Non-Functional Requirements

- Estimated 100-200 users. Likely to see usage in batches of 20-50
- Concurrency is a requirement
- Availability of 99.5%
- Page load performance:
  - First load < 5s
  - interactions < 0.5s
  - page load on week change < 1s

## Engineering Requirements

Beyond the non-functional requirements, there are some minimal engineering standards expected to be met to be deployed to production. This includes:

- Code coverage > 85%
- All Critical/High Orca vulnerabilities are resolved with exceptions approved by engineering and central engineering/security
- All critical/high code vulnerabilities (Snyk) are resolved with exceptions approved by engineering and central engineering/security
- Logging, tracing and monitoring is defined and implemented
- \<TBC\> : new data requirements. Confirm name & link
- Support plans defined and documented

See [https://docs.google.com/spreadsheets/d/1X7grThVnqYJc0_FAe8p697oLeuN1ZItXCnx_Fy_S1xs/edit?gid=333831499#gid=333831499](https://docs.google.com/spreadsheets/d/1X7grThVnqYJc0_FAe8p697oLeuN1ZItXCnx_Fy_S1xs/edit?gid=333831499#gid=333831499) for the full list of requirements. Note in some cases we will be aiming for a higher standard (e.g. code coverage) to reflect that this will be a base to build future use cases and as a result needs to be a stable and reliable platform.

# System Design

Miro Link: [https://miro.com/app/board/uXjVEcDD0oA=/?share_link_id=486848847484](https://miro.com/app/board/uXjVEcDD0oA=/?share_link_id=486848847484)

Password: ends1234

## Options Considered

### UI

First decision was where should the UI live. Given the goal to move towards less individual tools we considered options to add it into existing code bases.

| **#** | **Option** | **Notes** | **Decision** |
| --- | --- | --- | --- |
| 1 | Add to NGS UI | • Slower to build<br>• Older react version, older tolling<br>• predates coda<br>• NGS not set up for this | No |
| 2 | Add to Brochure UI | • “designed” by claude, so not a great base to build on<br>• one 6.5K line react component… going to be hard to clean up to get to a maintainable point | No |
| 3 | New UI | • Start from scratch with out any of the baggage from previous tools | Yes |

For a new UI, we have a few decisions to make for the approach:

| **#** | **Option** | **Notes** |
| --- | --- | --- |
| 1 | Monolithic UI | • One UI talking to lots of backend APIs<br>• Concern: prevent breaking another use case when making changes |
| 2 | Separate UI per use case | • full page load to move between use cases<br>• Q: how to ensure consistency across UIs |
| 3 | Micro front ends with shared shell | • most complicated<br>• used by checkout |

Decision is that we will start with #1. When a second use case comes in we will revisit and decide which path to take. It’s hard to design for option #2 or #3 at this stage.

### Backend

For the backend we discussed what could potentially be pulled into a separate, re-useable service to enable future use cases to be added easily without duplicating code or needing large amounts of refactoring.

We identified a few potential candidates:

- Users - e.g. retrieving name, email, roles
  - Note: We need to investigate a better way of accessing role information. The current method in brochure and catnav (storing the users and roles in code) is not an acceptable solution
  - Accessing via Google APIs may be possible, but we need to be aware of the performance limitations and look at caching
- Sending emails
- print/pdf export
- potentially others over time…

We also discussed what services could be identified within ends itself that may be useful to live in it’s own service. We identified:

- Promotions
- Nominations

This list may be added to or removed from over time as we learn more about the functionality and dive deeper into the implementation.

# Data Design

TODO

# Other

## Observability & Monitoring

e.g. define metrics, alerts, etc that will be defined

## Interfaces & APIs

define the key interfaces as we define them. esp the ones we expect future use cases to make use of

# Decision Register

| **Date** | **Decision** | **Who?** | **Comments** |
| --- | --- | --- | --- |
| 2026-10-8 | New UI, not adding to an existing tool | [Claire Taylor](https://woolworths-agile.atlassian.net/people/712020:60e5a788-755c-4c9a-a5a0-8eae2fa5fcd9), [Gavin Steacy](https://woolworths-agile.atlassian.net/people/712020:bf61b976-8afa-4e7c-aa03-f429dd66ab02), [Haiyuan Mei](https://woolworths-agile.atlassian.net/people/712020:3a3ba6b0-bd83-459c-91a9-f33b38568cc0) | See [UI](https://woolworths-agile.atlassian.net/wiki/spaces/WIQ/pages/edit-v2/35003924527#UI) |
| 2026-10-8 | Monolithic UI | [Claire Taylor](https://woolworths-agile.atlassian.net/people/712020:60e5a788-755c-4c9a-a5a0-8eae2fa5fcd9), [Gavin Steacy](https://woolworths-agile.atlassian.net/people/712020:bf61b976-8afa-4e7c-aa03-f429dd66ab02), [Haiyuan Mei](https://woolworths-agile.atlassian.net/people/712020:3a3ba6b0-bd83-459c-91a9-f33b38568cc0) | See [UI](https://woolworths-agile.atlassian.net/wiki/spaces/WIQ/pages/edit-v2/35003924527#UI) Note: this decision is for the ends project. For future use cases this will be revisited |
| 2026-10-8 | Tech stack:<br>• UI: React<br>• Backend: Python | [Claire Taylor](https://woolworths-agile.atlassian.net/people/712020:60e5a788-755c-4c9a-a5a0-8eae2fa5fcd9), [Gavin Steacy](https://woolworths-agile.atlassian.net/people/712020:bf61b976-8afa-4e7c-aa03-f429dd66ab02), [Haiyuan Mei](https://woolworths-agile.atlassian.net/people/712020:3a3ba6b0-bd83-459c-91a9-f33b38568cc0) | Align with existing tech stack used across B+M |
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |

# Questions

| **Date** | **Question** | **Owner** | **Notes/Answer** | **Status** |
| --- | --- | --- | --- | --- |
| 2026-10-9 | Can coda support multiple alloyDBs? | [Gavin Steacy](https://woolworths-agile.atlassian.net/people/712020:bf61b976-8afa-4e7c-aa03-f429dd66ab02) | | Open |
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |








# Ends data model Draft

Source: [Confluence page](https://woolworths-agile.atlassian.net/wiki/spaces/WIQ/pages/35015426441/Ends+data+model+Draft)

## Table of Contents

- [Background](#background)
- [Section 1 — BigQuery Data Sources](#section-1--bigquery-data-sources)
  - [What data is being used](#what-data-is-being-used)
  - [Design decisions needed](#design-decisions-needed)
  - [Weight data gap](#weight-data-gap)
- [Section 2 — AlloyDB Entities](#section-2--alloydb-entities)
  - [2.1 Promotion](#21-promotion)
  - [2.2 Placement](#22-placement)
  - [2.3 Week](#23-week)
  - [2.4 EndSlot](#24-endslot)
  - [2.5 Approval (discussed but not modelled yet)](#25-approval-discussed-but-not-modelled-yet)
  - [2.6 Plan](#26-plan)
  - [2.7 Nomination](#27-nomination)
- [Section 3 — Constraint Rules (Not Yet Modelled)](#section-3--constraint-rules-not-yet-modelled)
- [Section 4 — Open Items for Next Session](#section-4--open-items-for-next-session)
  - [Must resolve before schema can be finalised](#must-resolve-before-schema-can-be-finalised)
  - [Questions to ask the data engineer (Sarvesh)](#questions-to-ask-the-data-engineer-sarvesh)
- [Section 5 — Design Principles to Keep in Mind](#section-5--design-principles-to-keep-in-mind)

## Background

The Ends project is in early design stage. There is currently **zero AlloyDB schema** — prior work was POC-only and used local storage for single-user sessions. This document captures what was discussed in the first data model design meeting and identifies what still needs to be resolved.

## Section 1 — BigQuery Data Sources

### What data is being used

The primary input table is `bq_future_nominations_input_v` (likely a view, not a table — needs confirmation). This contains all nomination data for Ends and is refreshed either daily or weekly.

**Primary keys:** Promotion Week Start Date, Lead Article Number, Price Family.

**Key fields surfaced:** Product category, CD area, various metrics.

**Open item:** This appears to be a view that wiq owns and transforms — it is **not** a direct read from an upstream source table. The upstream tables that feed this view are currently unknown.

### Design decisions needed

- Confirm whether `bq_future_nominations_input_v` is a view or a materialised table
- Identify and document the upstream source tables it reads from
- Determine what transformations are applied (there are joins involved — these need to be documented in the design)
- Confirm cross-project read permissions — currently BPT copies tables into its own GCP project because cross-project reads are not set up. Ends will need to decide whether to do the same or establish cross-project access via a service account
- Transformations for display purposes (enrichment, joins for the app) are expected and acceptable — the principle to avoid is patching data quality issues locally rather than fixing them upstream

### Weight data gap

Products have a `class` field with a subtype called `stock_weight` that flags heavy items. The rule implemented is: if a product is classified as `stock_weight` and is not on the bottom shelf, it is a violation.

There is **no actual weight value** stored for products. Total shelf weight capacity cannot be enforced as a result. This is acceptable for now because the business likely uses gut feel for this — shelf configurations also vary by store age and renovation status, making a universal weight rule impractical.

## Section 2 — AlloyDB Entities

Section 2 — AlloyDB Entities. Tables are named after the agreed entities.

### 2.1 Promotion

Products (price family or promotion) available to place, synced from BigQuery.

```text
id               UUID         PRIMARY KEY
product_id       STRING       NOT NULL UNIQUE  -- BQ identifier; price family or promotion ID (TBC)
name             STRING
brand            STRING       NULLABLE         -- needed for rules such as "no same brand on adjacent ends"
category         STRING       NULLABLE
is_active        BOOLEAN      DEFAULT TRUE     -- set FALSE if removed from BigQuery
synced_at        TIMESTAMPTZ
```

Proposed approach to the "promotion deleted in BigQuery after placement" issue: keep a local synced row and soft-deactivate it, so existing placements keep a valid reference and the product still shows against the plan.

### 2.2 `Placement`

Core operational table. One promotion in one end slot within a plan.

```text
id               UUID     PRIMARY KEY
plan_id          UUID     FK -> Plan.id
end_slot_id      UUID     FK -> EndSlot.id
promotion_id     UUID     FK -> Promotion.id

UNIQUE (plan_id, end_slot_id)   -- no double-booking within a plan
```

**Scale:** ~200 placements per week (freezer category = ~6 per week; total across all categories ~200). Design target is 200 shelves per week, ~50 weeks per year.

**Retention:** No retention policy exists today — planners currently rely on printed exports to review past plans. The meeting agreed a minimum of 1 year is needed (planners want to look back at what was done the previous Christmas). Agreement was to set 5 years as the initial policy — easier to extend than to argue for deletion later. At current scale this is not a large dataset.

**Relationship:** Many placements belong to one week. Each placement references one end and one shelf slot. Sub-slot is optional and only relevant when a shelf is split into multiple positions.

**Open items:**

- Confirm whether `product_id` should be price family or a promotion ID
- Confirm the exact composite primary key
- What happens when a promotion is deleted from BigQuery after it has already been placed? Currently in BPT the placement persists in AlloyDB but the product disappears from the nomination sidebar. This is an unresolved consistency issue — needs a decision on whether placed promotions are "snapshotted" at placement time or remain live-linked to BQ

### 2.3 `Week`

**What it is:** Represents a planning week and the approval status of the ends plan for that week.

**Attributes discussed:**

```text
id                   UUID        PRIMARY KEY
week_start_date      DATE        NOT NULL UNIQUE
week_end_date        DATE        NOT NULL
status               ENUM        -- e.g. 'planning' | 'approved' | 'locked'
```

**Relationship:** One week has many placements and many ends ends. The approval concept is attached at this level — when a plan is approved for a week, that state needs to be captured here or in a related approval table.

**Open items:**

- Should approval live on `Week` directly or be a separate `Approval` table?
- If a plan is approved and then a last-minute change comes in, does the team need to re-submit for approval or can the previous approval carry over? Not resolved in the meeting.
- Who approves? Not defined yet.
- Does approval lock the plan (making it read-only until explicitly unlocked)? Discussed but not concluded — consensus was leaning toward requiring re-approval after any change.

### 2.4 `EndSlot`

**What it is:** The detail record for a single physical end (gondola end cap). Captures the configuration and metadata of the end itself, independent of what product is placed on it.

**Attributes discussed:**

```text
id               UUID     PRIMARY KEY
week_id          UUID     FK -> Week.id
end_key          STRING   NOT NULL   -- Physical identifier for the end location in store
end_type         STRING              -- Category or type of end
header_label     STRING              -- e.g. 'Half Price', 'Special', 'Member Price'
header_type      ENUM                -- Promotional header type
store_count      INT                 -- Number of stores this end applies to
shelf_number     INT      NOT NULL   -- 1 = top shelf
sub_position     INT      DEFAULT 1  -- 1 = left, 2 = right, etc. 1 when the shelf is not split
depth_cm         DECIMAL  NULLABLE   -- Constraint input
width_cm         DECIMAL  NULLABLE   -- Constraint input
weight_class     STRING   NULLABLE   -- e.g. 'standard' | 'heavy_restricted'

UNIQUE (week_id, end_key, shelf_number, sub_position)
```

**Relationship:** One end belongs to one week.

**Open items:**

- Layout is determined by end_type. MVP to a limited number of end types.
- Until templates are defined, the interim approach is one shelf = one product (no splits), to keep complexity manageable
- Depth and weight data is not available in the current data sources — depth attribute should be included in the schema but cannot be enforced yet

### 2.5 `Approval` _(discussed but not modelled yet)_

**What it is:** A record that a plan for a given week has been approved by an authorised person.

**Attributes discussed:**

```text
id                  UUID         PRIMARY KEY
plan_id             UUID         FK -> Plan.id
plan_version        INT          NOT NULL   -- version that was approved
approved_by         STRING       -- SSO user identity
approved_at         TIMESTAMPTZ
plan_snapshot_hash  STRING       -- Hash of plan state at approval time
is_valid            BOOLEAN      -- FALSE once the plan changes after sign-off
```

**Open items:**

- Not yet included in the current data model — raised at the end of the meeting and confirmed as necessary
- Does approval invalidate automatically if the plan changes, or does someone need to explicitly revoke it?
- Does approval lock the plan from further edits without going through an unlock step?
- Who is authorised to approve? Not defined.

### 2.6 Plan

A proposed arrangement for a week.

```text
id               UUID         PRIMARY KEY
week_id          UUID         FK -> Week.id
name             STRING
version          INT          NOT NULL DEFAULT 1   -- incremented on every change; Approval binds to this
status           ENUM         -- 'draft' | 'approved' | 'superseded'
created_by       STRING       -- SSO user identity

created_at       TIMESTAMPTZ
```

Rule: only one approved plan per week. Enforce with a partial unique index on (week_id) where status = 'approved'.

### 2.7 Nomination

Category team intent. Kept separate from where the planner actually places things. Attributes are proposed; this table was not detailed in the session.

```text
id               UUID         PRIMARY KEY
week_id          UUID         FK -> Week.id
promotion_id     UUID         FK -> Promotion.id
category         STRING
nominated_by     STRING       -- SSO user identity
notes            STRING       NULLABLE
created_at       TIMESTAMPTZ
```

## Section 3 — Constraint Rules (Not Yet Modelled)

The following constraints were discussed but have **no data model representation yet**:

| Constraint | Current implementation | Gap |
| --- | --- | --- |
| Heavy item must be on bottom shelf | Inferred from `class = stock_weight` field — if not on bottom shelf, flag as violation | Works for now; no actual weight values available |
| Total shelf weight capacity | Not implemented — no weight data exists in source | Cannot be enforced until weight data is sourced |
| Shelf depth / product fit | Depth column exists in some form but not surfaced in current model | Needs to be linked to shelf slot |
| Sub-slot count per shelf | Currently unconstrained — anything goes | Needs predefined templates to bound the permutations |
| Layout template restrictions | No templates defined; fully freeform at present | Needs discovery with sales planning team |
| Promotion change after placement | No validation — if a promotion changes in BQ after placement, the placed version persists silently | Needs a decision on whether placed records are snapshots or live-linked |

## Section 4 — Open Items for Next Session

### Must resolve before schema can be finalised

| # | Question | Owner |
| --- | --- | --- |
| 1 | Is `bq_future_nominations_input_v` a view or a materialised table? What upstream tables does it read from? | Engineering — check with data engineer |
| 2 | What transformations are applied in the BQ layer before data reaches the app? Document these in the design. | Engineering |
| 3 | Does Ends copy BQ tables into its own GCP project (like BPT) or establish cross-project reads via a service account? | Engineering + infra |
| 4 | Do planners already follow standard end layouts in practice? Is there a finite set of templates? | Discovery with sales planning team |
| 5 | Should `ends_shelf_slot` and `ends_sub_slot` be separate tables, or encoded differently? | Gav to confirm |
| 6 | What are the rules for whether a promotion can be placed in a given shelf slot / sub-slot? | Discovery with sales planning team |
| 7 | What happens when a promotion is deleted or changed in BQ after it has already been placed? Snapshot or live-link? | Design decision — Gav |
| 8 | Should approval live on `Week` or a separate `Approval` table? | Gav |
| 9 | Does approval lock the plan? Does a post-approval change require re-approval? | Business stakeholder + Gav |
| 10 | Who is authorised to approve a plan? Is it role-based or person-specific? | Business stakeholder |
| 11 | Confirm data retention policy — 5 years agreed as starting point, to be validated with governance | Business / governance |

### Questions to ask the data engineer (Sarvesh)

- What are the upstream source tables that feed `bq_future_nominations_input_v`?
- Is this a view or a materialised table, and how often does it refresh?
- What joins and transformations are applied?
- Which GCP project owns the upstream tables, and what permissions are needed to read them?
- Is there any weight data available in the source tables beyond the `stock_weight` class flag?
- What is the refresh cadence — daily or weekly?

## Section 5 — Design Principles to Keep in Mind

- **wiq does not own upstream data** — the BQ nomination view appears to be wiq-owned and transformed. The upstream source tables and their owners need to be identified and documented (consistent with wiq Data Operating Principles).
- **Predefined templates over freeform** — the meeting reached a clear preference for bounding layout permutations via predefined templates rather than allowing infinite combinations. This reduces edge cases, improves testability, and produces higher quality output.
- **Approval must be auditable** — any approval record must reference a real, verifiable user identity. Placeholder values are not acceptable.
- **Start simple, iterate** — interim position is one shelf = one product until layout templates are defined with stakeholders.
- **Data retention needs an explicit policy** — agreed starting point is 5 years. Set this upfront to avoid a harder conversation later.







