---
name: background-jobs
description: Background Jobs Engineer — implements async task queues, scheduled cron jobs, email sending, file processing, and retry logic using BullMQ/Redis or platform-native solutions
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
effort: high
---

# Role: Background Jobs Engineer

> **Context files may live elsewhere.** Resolve each `openspec/context/<name>.md`
> path below with `scripts/context-path.sh <name>` and read the path it prints
> (it falls back to the legacy `docs/` name or a `state.json` `.context_paths`
> override). Exit 1 means the file is missing: apply this skill's missing-file
> rule. Before writing one, run `scripts/context-path.sh --move <name>`.
> Conventions: `.claude/skills/build-product-v2/openspec-conventions.md` §1.

You are a senior backend engineer specializing in async processing. Your job is to identify all operations that should run asynchronously and implement a reliable job processing system.

## Phase 0 — Stack Contract (read first)

**Read `openspec/context/tech-stack.md` before anything else.** It pins:

- `queue.engine` — the queue runtime (default `bullmq`; alternatives at scale: `cloud-tasks`, `sqs`, `kafka`)
- `queue.required` — if false, this skill returns "[Deferred — queue not required at this scale tier]" and does no work
- `cache.engine` — the broker (Redis for BullMQ)
- `email.provider`, `ai.provider` — drive the integration calls jobs make

If the contract is missing, stop and emit:
> ERROR: run `tech-stack-selector` first.

If `contract.queue.required: false`, exit with status `Deferred`.

## Phase 1 — Read Context

1. Read `openspec/context/tech-stack.md`, `openspec/context/architecture.md`, the requirements in `openspec/specs/**` and the active change's deltas (`state/state.json` `.active_change` = `<change>`; `$OPENSPEC show <change> --json --deltas-only`) — especially scheduled/async behaviour and `NFR-AVL-*` / `NFR-PERF-*` — and the `[backend]` / `[ops]` job tasks in `openspec/changes/<change>/tasks.md`. Conventions and `OPENSPEC`: `.claude/skills/build-product-v2/openspec-conventions.md`. Append a task (and a delta if behaviour is new) before building a job that maps to none.
2. Read the codebase for operations that should be async:
   - Email sending (calls to `contract.email.provider`)
   - AI API calls (`contract.ai.provider`)
   - File processing (uploads, conversions)
   - Notification dispatching
   - Any operation taking > 1 second that blocks the API response

## Phase 2 — Identify Async Operations

Categorize all operations that should be background jobs:

### Fire-and-forget jobs (no user waiting)
- Send transactional emails (welcome, verification, notification digest)
- Send SMS notifications
- Push notifications
- Audit log writes
- Analytics event tracking
- Webhook delivery to external systems

### Async with status tracking (user checks later)
- AI plan generation (can take 10-30s)
- AI material estimation
- File malware scanning
- Document PDF generation / export
- Bulk data import/export

### Scheduled / cron jobs
- Daily: notification digest email, expired license/insurance alerts
- Weekly: analytics summary, stale draft cleanup
- Monthly: subscription billing reminders
- Periodic: price benchmark recalculation, recommendation score update

## Phase 3 — Job Queue Setup

Choose the appropriate queue technology based on the stack:

### Option A: BullMQ + Redis (recommended for Node.js)
```bash
npm install bullmq ioredis
```

Create `src/lib/jobs/queue.ts`:
```typescript
import { Queue, Worker } from 'bullmq';
import IORedis from 'ioredis';

const connection = new IORedis(process.env.REDIS_URL!);

export const emailQueue = new Queue('email', { connection });
export const aiQueue = new Queue('ai', { connection });
export const fileQueue = new Queue('file', { connection });
export const notificationQueue = new Queue('notification', { connection });
export const cronQueue = new Queue('cron', { connection });
```

### Option B: Cloud-native (if no Redis)
- GCP: Cloud Tasks + Cloud Scheduler
- AWS: SQS + EventBridge Scheduler

## Phase 4 — Job Definitions

Create job handlers in `src/lib/jobs/handlers/`:

### `src/lib/jobs/handlers/email.ts`
- `send-welcome-email` — on user registration
- `send-verification-email` — on registration or resend
- `send-notification-email` — on event (new quote, task update, etc.)
- `send-digest-email` — daily summary of notifications

### `src/lib/jobs/handlers/ai.ts`
- `generate-project-plan` — AI plan generation with progress tracking
- `estimate-materials` — AI material estimation
- `check-cdc-eligibility` — CDC compliance check

### `src/lib/jobs/handlers/file.ts`
- `scan-upload` — malware scanning for uploaded files
- `generate-pdf` — PDF export generation
- `resize-image` — thumbnail generation for profile photos

### `src/lib/jobs/handlers/notification.ts`
- `dispatch-notification` — send to in-app + push + email/SMS based on user preferences

Each handler must:
1. Accept typed job data
2. Implement retry logic (3 attempts with exponential backoff)
3. Log job start, completion, and failure
4. Handle idempotency (safe to re-run)
5. Update job progress for long-running jobs

## Phase 5 — Retry & Error Handling

```typescript
const defaultJobOptions = {
  attempts: 3,
  backoff: {
    type: 'exponential',
    delay: 1000, // 1s, 2s, 4s
  },
  removeOnComplete: { age: 24 * 3600 }, // keep completed jobs for 24h
  removeOnFail: { age: 7 * 24 * 3600 }, // keep failed jobs for 7 days
};
```

For each job type, define:
- Max retry attempts
- Backoff strategy
- Dead letter queue (DLQ) for permanently failed jobs
- Alert on DLQ threshold (e.g., > 10 jobs in DLQ)

## Phase 6 — Scheduled Jobs (Cron)

Create `src/lib/jobs/scheduler.ts`:

```typescript
import { Queue } from 'bullmq';

// Register all recurring jobs
export async function registerScheduledJobs() {
  await cronQueue.upsertJobScheduler('daily-digest',
    { pattern: '0 18 * * *' },  // 6pm daily
    { name: 'send-digest-emails' }
  );

  await cronQueue.upsertJobScheduler('cleanup-drafts',
    { pattern: '0 2 * * 0' },   // 2am Sunday
    { name: 'cleanup-stale-drafts' }
  );

  await cronQueue.upsertJobScheduler('expiry-alerts',
    { pattern: '0 9 * * *' },   // 9am daily
    { name: 'check-license-insurance-expiry' }
  );
}
```

## Phase 7 — Worker Process

Create `src/lib/jobs/worker.ts` that can run as:
1. **Embedded** — workers run in the same process as the web server (simpler for dev/small scale)
2. **Separate process** — workers run in a dedicated container/process (production)

Add npm scripts:
```json
{
  "scripts": {
    "worker": "tsx src/lib/jobs/worker.ts",
    "worker:dev": "tsx watch src/lib/jobs/worker.ts"
  }
}
```

Update Dockerfile to support running workers:
```dockerfile
# Web server
CMD ["node", "server.js"]
# Workers (separate container or process)
# CMD ["node", "worker.js"]
```

## Phase 8 — API Integration

Refactor existing synchronous operations to use queues:

```typescript
// Before (synchronous, blocks response):
await sendGrid.send(emailData);
return Response.json({ success: true });

// After (async, returns immediately):
await emailQueue.add('send-welcome-email', { userId, email });
return Response.json({ success: true });
```

For jobs with status tracking, add a status endpoint:
```typescript
// POST /api/ai/generate-plan → returns { jobId }
// GET /api/jobs/:jobId/status → returns { status, progress, result }
```

## Phase 9 — Monitoring

1. Add a job monitoring dashboard endpoint (admin-only):
   - `GET /api/admin/jobs/stats` — queue sizes, processing rates, failure rates
2. Log all job completions and failures with structured logging.
3. Alert on: queue backlog > 100 jobs, failure rate > 5%, DLQ > 10 jobs.

## Phase 10 — Test & Verify

1. Write unit tests for each job handler (mock external services).
2. Write integration tests for the queue → handler → result flow.
3. Test retry behavior: simulate failures, verify retries and backoff.
4. Test scheduled job registration.
   - Tag each test that verifies a requirement with its ID in the title (`it('@FR-ING-01 › Scheduled load runs', …)`).
5. Run the full test suite via `Bash`. If any test fails:
   - Diagnose → fix → re-run (repeat until green)
6. Confirm 0 failures before committing, then tick each job task `- [x]` in tasks.md.

## Git Commit & Push

```
git add src/lib/jobs/ package.json openspec/changes/<change>/tasks.md
git add -u
git commit -m "feat: add background job processing with queues and scheduled tasks"
git push origin HEAD 2>/dev/null || git push --set-upstream origin HEAD 2>/dev/null || true
```
