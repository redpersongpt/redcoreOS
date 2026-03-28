# CODEX HANDOFF

**Date:** 2026-03-28  
**Workspace:** `/Users/redperson/redcoreECO`

## Current Truth

- `cloud-api` is now the primary SaaS hub.
- `tuning-api` is slimmed to `/v1/updates/catalog`.
- `os-api` is slimmed to `/v1/admin/fleet-groups`, `/v1/license/*`, `/v1/updates/*`.
- OS donations now live in `cloud-api` at `/v1/donations/*`.
- `os-api` no longer mounts donations.
- `tuning-desktop` cloud client now normalizes its base URL to `/v1`.
- `packages/db` was expanded into the shared schema source of truth used by `cloud-api`.

## Verified

- `cd apps/cloud-api && pnpm exec tsc --noEmit`
- `cd apps/cloud-api && pnpm exec tsc`
- `cd apps/tuning-api && pnpm exec tsc`
- `cd apps/os-api && pnpm exec tsc`

## Deployment Reality

- VDS target: `185.48.182.164`
- Direct deploy attempt from this session is blocked by SSH auth:
  - `ssh ubuntu@185.48.182.164` → `Permission denied (publickey,password)`
- Repo-side deploy scripts were updated:
  - [deploy.sh](/Users/redperson/redcoreECO/scripts/deploy.sh)
  - [vds-setup.sh](/Users/redperson/redcoreECO/scripts/vds-setup.sh)

## Important Changes

- Shared schema and package exports:
  - [schema.ts](/Users/redperson/redcoreECO/packages/db/src/schema.ts)
  - [package.json](/Users/redperson/redcoreECO/packages/db/package.json)
- `cloud-api` shared DB bridge:
  - [index.ts](/Users/redperson/redcoreECO/apps/cloud-api/src/db/index.ts)
- OS donations moved to `cloud-api`:
  - [donations.ts](/Users/redperson/redcoreECO/apps/cloud-api/src/routes/donations.ts)
  - [webhooks.ts](/Users/redperson/redcoreECO/apps/cloud-api/src/routes/webhooks.ts)
- Apple no-email fallback:
  - [oauth.ts](/Users/redperson/redcoreECO/apps/cloud-api/src/lib/oauth.ts)
  - [auth.ts](/Users/redperson/redcoreECO/apps/cloud-api/src/routes/auth.ts)
- Account delete now revokes machines:
  - [users.ts](/Users/redperson/redcoreECO/apps/cloud-api/src/routes/users.ts)
- Fleet groups exposed in `cloud-api` admin:
  - [admin.ts](/Users/redperson/redcoreECO/apps/cloud-api/src/routes/admin.ts)
- API package names corrected:
  - [apps/tuning-api/package.json](/Users/redperson/redcoreECO/apps/tuning-api/package.json)
  - [apps/os-api/package.json](/Users/redperson/redcoreECO/apps/os-api/package.json)

## Remaining Gaps

- VDS deploy was not executed because this session has no SSH auth to the server.
- CI workflows and product docs still need a dedicated cleanup pass if you want them fully aligned with the new backend split.
- `CLAUDE.md` was stale before this pass and should not be treated as authoritative until refreshed.
