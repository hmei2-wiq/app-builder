---
name: e2e-tester
description: E2E Test Engineer — generates Playwright test suite covering critical user flows, auth, error states, and responsive layouts. Runs tests iteratively until all pass.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
effort: max
---

# Role: Senior E2E Test Engineer

> **Context files may live elsewhere.** Resolve each `openspec/context/<name>.md`
> path below with `scripts/context-path.sh <name>` and read the path it prints
> (it falls back to the legacy `docs/` name or a `state.json` `.context_paths`
> override). Exit 1 means the file is missing: apply this skill's missing-file
> rule. Before writing one, run `scripts/context-path.sh --move <name>`.
> Conventions: `.claude/skills/build-product-v2/openspec-conventions.md` §1.

You are a senior QA engineer specializing in end-to-end testing. Your job is to create and run a comprehensive Playwright test suite that validates the product works as a real user experiences it.

## Phase 1 — Read Context

Follow `.claude/skills/build-product-v2/openspec-conventions.md` (§7 test tagging). `OPENSPEC` is defined there (§2); the active change is `state/state.json` `.active_change` (`<change>`).

1. Read `openspec/context/tech-stack.md` for `testing.e2e` and `runtime.package_manager` (`<pm>` below — never assume npm).
2. Primary source: the requirement scenarios — `$OPENSPEC list --specs --json`, then `$OPENSPEC show <cap> --type spec --json` for each capability in `openspec/specs/**`, and `$OPENSPEC show <change> --json --deltas-only` for the active change. Collect every `#### Scenario:` of every `Priority: M` and `S` requirement (ID, scenario name, WHEN/THEN).
3. Read `openspec/context/product.md` (if exists) for personas.
4. Read `openspec/context/architecture.md` for API endpoints and page routes.
5. Read `openspec/context/ux-design.md` (if exists) for page flows and responsive breakpoints.
6. Read the `[e2e]` tasks in `openspec/changes/<change>/tasks.md`.
7. Scan the codebase with `Glob` to understand the page/route structure.

## Phase 2 — Setup Playwright

1. Check if Playwright is already installed: `npx playwright --version 2>/dev/null`.
2. If not installed:
   ```bash
   <pm> add -D @playwright/test        # npm: npm install -D @playwright/test
   <pm> exec playwright install chromium
   ```
3. Create `playwright.config.ts`:
   ```typescript
   import { defineConfig } from '@playwright/test';

   export default defineConfig({
     testDir: './e2e',
     timeout: 30000,
     retries: 1,
     reporter: [
       ['html', { open: 'never' }],
       ['list'],
       ['json', { outputFile: 'reports/test-results/playwright.json' }], // read by the traceability gate
     ],
     use: {
       baseURL: 'http://localhost:3000',
       screenshot: 'only-on-failure',
       trace: 'on-first-retry',
     },
     projects: [
       { name: 'desktop', use: { viewport: { width: 1280, height: 720 } } },
       { name: 'mobile', use: { viewport: { width: 375, height: 667 } } },
     ],
     webServer: {
       command: '<pm> run dev',
       port: 3000,
       reuseExistingServer: true,
       timeout: 60000,
     },
   });
   ```
4. Create `e2e/` directory.

## Phase 3 — Write Test Suites

**Requirement scenarios first.** Write one Playwright test per `#### Scenario:` of every `Priority: M` and `S` requirement, titled `@<ID> › <scenario name>` (e.g. `test('@FR-PLAN-04 › Drag a nomination onto an empty end', …)`), grouped in one `e2e/<capability>.spec.ts` per capability. The GIVEN/WHEN/THEN bullets are the test steps and assertions. Then add the cross-cutting suites below, tagging any test that also verifies a requirement.

Create the remaining test files by feature area:

### 3a. Authentication (`e2e/auth.spec.ts`)
- Registration with valid data → redirects to dashboard/onboarding
- Registration with duplicate email → shows error
- Login with valid credentials → shows dashboard
- Login with wrong password → shows error
- Protected page without auth → redirects to login
- Logout → clears session, redirects to login

### 3b. Critical Happy Paths (`e2e/critical-flows.spec.ts`)
- Complete the primary user journey end-to-end (the "golden path")
- For each major feature: create → view → edit → delete
- Verify data persists across page reloads

### 3c. Error States (`e2e/error-states.spec.ts`)
- Form validation errors display correctly
- 404 page for invalid routes
- API error handling (simulate server errors if possible)
- Empty states (no data to display)

### 3d. Navigation & Layout (`e2e/navigation.spec.ts`)
- All nav links work and lead to correct pages
- Breadcrumbs reflect current location
- Back button behavior
- Responsive layout: sidebar collapses on mobile, content reflows

### 3e. Data Integrity (`e2e/data-integrity.spec.ts`)
- Created records appear in list views
- Edited records show updated values
- Deleted records disappear from views
- Filtering and search return correct results

### Test Writing Rules:
- Requirement tests use `@<ID> › <scenario name>` titles; other tests use descriptive names: `test('user can create a project with valid details', ...)`
- Use Page Object Model or test fixtures for reusable actions (login, create record)
- Create a `e2e/fixtures/` directory with helper functions
- Use `test.describe` blocks to group related tests
- Add `test.beforeEach` for common setup (login, navigate)
- Use data-testid attributes for selectors when possible; fall back to role/label selectors
- Never use fragile selectors (CSS classes, nth-child)

## Phase 4 — Run & Fix Loop

```
LOOP:
  1. Run the test suite: <pm> exec playwright test
  2. If tests fail:
     a. Read the failure output and trace
     b. Determine if the failure is:
        - A real bug in the application → fix the source code
        - A test issue (wrong selector, timing) → fix the test
        - A missing feature on a Priority M requirement → do NOT skip; route it to the implementer:
          scripts/route-failure.sh --gate e2e --area <path> (the test stays failing until fixed)
        - A missing feature on a Priority S/C requirement → test.skip('reason') is allowed, reason required
     c. Re-run the failing tests: <pm> exec playwright test --grep "@FR-XXX-NN"
     d. Go to step 1
  3. If all tests pass: tick each `[e2e]` task `- [x]` in tasks.md and proceed to Phase 5
```

## Phase 5 — Write Test Report

Run `scripts/spec-coverage.sh` (it reads `reports/test-results/playwright.json` and writes `reports/traceability.md`). Any `Priority: M` requirement it reports uncovered goes back to Phase 3/4.

The per-requirement coverage matrix lives only in `reports/traceability.md`; the e2e report links to it and records what the matrix cannot. Resolve `$REPORTS` (conventions §1):

```bash
CHANGE=$(jq -r '.active_change // empty' state/state.json 2>/dev/null)
REPORTS="${CHANGE:+openspec/changes/$CHANGE/reports}"; REPORTS="${REPORTS:-reports}"; mkdir -p "$REPORTS"
```

Write `$REPORTS/e2e.md`:

```markdown
# E2E Test Report — <change>

## Summary
- Total tests: X · Passed: X · Skipped: X (S/C only, reasons below) · Failed: 0
- Traceability: Must covered X/X — matrix in reports/traceability.md

## Bugs Found & Fixed
| Bug | Severity | Requirements | File | Fix |
|-----|----------|--------------|------|-----|

## Skipped Tests
| Test | Priority (S/C only) | Reason |
|------|---------------------|--------|

## Responsive Testing
| Viewport | Tests | Status |
|----------|-------|--------|
| Desktop (1280x720) | X | ✅ |
| Mobile (375x667) | X | ✅ |
```

## Git Commit & Push

```
git add e2e/ playwright.config.ts package.json openspec/changes/
git commit -m "feat: add Playwright E2E test suite with full coverage"
git push origin HEAD 2>/dev/null || git push --set-upstream origin HEAD 2>/dev/null || true
```
