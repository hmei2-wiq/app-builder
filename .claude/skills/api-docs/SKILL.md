---
name: api-docs
description: API Documentation Generator — scans API routes, extracts endpoints/types/validators, generates the OpenAPI 3.1 spec (openapi.yaml, with x-requirements per operation) as the single API reference, optionally adds Swagger UI route
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
effort: high
---

# Role: API Documentation Engineer

> **Context files may live elsewhere.** Resolve each `openspec/context/<name>.md`
> path below with `scripts/context-path.sh <name>` and read the path it prints
> (it falls back to the legacy `docs/` name or a `state.json` `.context_paths`
> override). Exit 1 means the file is missing: apply this skill's missing-file
> rule. Before writing one, run `scripts/context-path.sh --move <name>`.
> Conventions: `.claude/skills/build-product-v2/openspec-conventions.md` §1.

You are a senior API documentation engineer. Your job is to generate comprehensive, accurate API documentation from the actual codebase — not from specs, but from what is actually implemented.

## Phase 0 — Stack Contract (read first)

**Read `openspec/context/tech-stack.md` before anything else.** It pins:

- `backend.framework` — drives where to look for routes (`/app/api/**/route.ts` for Next.js, etc.)
- `backend.validators` — drives schema extraction (Zod, Valibot, etc.)

If the contract is missing, stop and emit:
> ERROR: run `tech-stack-selector` first.

## Phase 1 — Discover API Surface

1. Use `Glob` to find all API route files matching the framework named in `contract.backend.framework`:
   - next-api-routes → `**/app/api/**/route.ts` or `**/pages/api/**/*.ts`
   - express → files with `router.get/post/put/delete`
   - hono / fastify → handler files matching that framework's idiom
2. Read each route file completely.
3. Extract for each endpoint:
   - HTTP method (GET, POST, PUT, DELETE, PATCH)
   - Route path (with path parameters)
   - Request body schema (from Zod validators, TypeScript types, or inline validation)
   - Response body shape (from return statements)
   - Authentication requirements (from middleware checks)
   - Status codes returned
   - Query parameters accepted
   - Headers required

## Phase 2 — Cross-Reference

1. Read the requirements — map each `FR-` ID to its implementing endpoint(s). Sources: `openspec/specs/**` (current truth) plus the deltas in the active change (`state/state.json` `.active_change` → `openspec/changes/<change>/specs/**`). Use `$OPENSPEC list --specs --json` and `$OPENSPEC show <capability> --type spec --json` (CLI setup and ID format: `.claude/skills/build-product-v2/openspec-conventions.md` §2–3).
2. Read `openspec/context/architecture.md` §4 API Surface — check for endpoint groups specified but not implemented, or implemented but not specified.
3. Find all Zod schemas or validator files — these define the canonical request/response types.
4. Find all middleware files — these define auth, rate limiting, and other cross-cutting concerns.

## Phase 3 — Generate OpenAPI Specification

Create `openapi.yaml` (or `openapi.json`) in the project root following OpenAPI 3.1:

```yaml
openapi: 3.1.0
info:
  title: <Project Name> API
  version: 1.0.0
  description: <from market analysis>
servers:
  - url: http://localhost:3000/api
    description: Development
  - url: https://<production-url>/api
    description: Production

paths:
  /auth/register:
    post:
      summary: Register a new user
      tags: [Authentication]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/RegisterRequest'
      responses:
        '201':
          description: User created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/AuthResponse'
        '400':
          description: Validation error
        '409':
          description: Email already exists

components:
  schemas:
    # Derived from Zod schemas and TypeScript types
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

### Rules for OpenAPI generation:
- Every endpoint discovered in Phase 1 MUST appear in the spec.
- Schemas MUST match the actual Zod validators / TypeScript types — do not invent fields.
- Include example values for request/response bodies.
- Group endpoints by tag (Authentication, Projects, Tasks, etc.).
- Document error responses with their actual status codes and shapes.

## Phase 4 — Requirement Coverage

`openapi.yaml` is the only API reference — there is no separate
markdown copy (conventions §1). Put the prose a reader needs (base URL,
auth scheme, error model) in `info.description` and
`components.securitySchemes`.

- On each operation, list the requirements it fulfils:
  `x-requirements: [FR-NOM-01, FR-NOM-05]` (IDs from `openspec/specs/**` + active change deltas).
- Endpoints with no requirement (orphans): add an `OQ-NN` entry under `## Open Questions` in the active change's `design.md` ("endpoint X has no requirement — add as ADDED/MODIFIED delta, or remove?"). If no change is active, return them in your summary as candidate deltas for `iterate`. Never edit `openspec/specs/` (conventions §4, §8).
- Requirements with no endpoint (potential gaps): same treatment.
- Check the endpoint groups in `openspec/context/architecture.md` §4 still match; if not, report the drift (the designer owns that file).

## Phase 5 — Swagger UI (Optional)

If the project uses Next.js, create an API docs page:

1. Install `swagger-ui-react` or use a CDN-based approach.
2. Create a route that serves the OpenAPI spec as JSON: `/api/docs/spec`
3. Create a page that renders Swagger UI: `/api-docs` or `/docs/api`

If the framework doesn't support easy UI embedding, skip this step and note it in `info.description`.

## Phase 6 — Validate

1. Validate the OpenAPI spec:
   ```bash
   npx @redocly/cli lint openapi.yaml
   ```
   If the validator isn't available, use:
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('openapi.yaml'))"
   ```
2. Verify every route file has a corresponding entry in the spec.
3. Check that the spec compiles without errors.

## Git Commit & Push

```
git add openapi.yaml openspec/changes/
git commit -m "feat: add OpenAPI specification"
git push origin HEAD 2>/dev/null || git push --set-upstream origin HEAD 2>/dev/null || true
```
