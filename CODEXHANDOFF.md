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

## 2026-03-29 Update

- Product truth corrected:
  - `redcore Tuning` is **free + $12.99 one-time license key**, not a recurring subscription product.
  - `redcore OS` remains fully free.
- `web` checkout truth was restored to one-time license purchase:
  - [apps/web/src/app/api/checkout/route.ts](/Users/redperson/redcoreECO/apps/web/src/app/api/checkout/route.ts) is back to `mode: "payment"` for Tuning.
  - [apps/web/src/app/api/webhook/route.ts](/Users/redperson/redcoreECO/apps/web/src/app/api/webhook/route.ts) again issues Tuning license keys and is idempotent on duplicate Stripe deliveries.
- `tuning-desktop` license truth was materially improved:
  - [apps/tuning-desktop/src/renderer/pages/subscription/SubscriptionPage.tsx](/Users/redperson/redcoreECO/apps/tuning-desktop/src/renderer/pages/subscription/SubscriptionPage.tsx) was rewritten from recurring billing UI into a real license page.
  - [apps/tuning-desktop/src/main/index.ts](/Users/redperson/redcoreECO/apps/tuning-desktop/src/main/index.ts) now persists a local license key and exposes real `activate/deactivate/refresh` IPC.
  - [apps/tuning-desktop/src/preload/index.ts](/Users/redperson/redcoreECO/apps/tuning-desktop/src/preload/index.ts) now exposes those license operations to the renderer.
  - [apps/tuning-desktop/src/renderer/pages/onboarding/OnboardingPage.tsx](/Users/redperson/redcoreECO/apps/tuning-desktop/src/renderer/pages/onboarding/OnboardingPage.tsx) now actually activates the entered license key instead of pretending to.
- `cloud-api` entitlement truth was partially shifted toward licenses:
  - [apps/cloud-api/src/routes/auth.ts](/Users/redperson/redcoreECO/apps/cloud-api/src/routes/auth.ts) now treats an active Tuning license as authoritative premium entitlement.
  - [apps/cloud-api/src/routes/users.ts](/Users/redperson/redcoreECO/apps/cloud-api/src/routes/users.ts) now returns Tuning entitlement from active license first, then legacy subscription fallback.
  - [apps/cloud-api/src/routes/license.ts](/Users/redperson/redcoreECO/apps/cloud-api/src/routes/license.ts) was expanded toward real `licenseKey + deviceFingerprint` validation/activation while preserving the older token path.
- `web` Google auth hardening landed:
  - [apps/web/src/lib/auth.ts](/Users/redperson/redcoreECO/apps/web/src/lib/auth.ts) only registers the Google provider when real credentials are configured.
  - [apps/web/src/app/login/page.tsx](/Users/redperson/redcoreECO/apps/web/src/app/login/page.tsx) and [apps/web/src/app/register/page.tsx](/Users/redperson/redcoreECO/apps/web/src/app/register/page.tsx) now hide the Google button if the provider is unavailable.
- Verified in this session:
  - `pnpm --dir apps/cloud-api exec tsc --noEmit`
  - `pnpm --dir apps/tuning-desktop test`
  - `pnpm --dir apps/tuning-desktop build`
  - `pnpm --dir apps/web exec tsc --noEmit`
  - `pnpm --dir apps/web build`
- Live VDS reality at handoff time:
  - `redcore-web` was rebuilt and PM2-restarted manually on the server.
  - `https://redcoreos.net/api/auth/providers` shows `google`, but `pm2 env 10` still did **not** show `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` when checked.
  - Therefore Google OAuth `invalid_client` was **not yet conclusively closed** at handoff time; the remaining likely root cause is live VDS env propagation or Google Cloud Console OAuth client configuration.
- Important live command for the next session:
  - `pm2 restart redcore-web --update-env`
  - then verify:
    - `pm2 env 10 | grep "GOOGLE_CLIENT_ID\|GOOGLE_CLIENT_SECRET\|AUTH_URL\|NEXTAUTH_URL"`
    - browser login via `https://redcoreos.net/login`
  - Google Console redirect URI must be:
    - `https://redcoreos.net/api/auth/callback/google`

## 2026-03-30 Update

- Server-side reality reported by the latest VDS session:
  - production envs were fixed on the server
  - PM2 services were restarted
  - nginx reverse proxy hosts were completed for the main domains
  - HTTPS is live for `redcoreos.net` and the related subdomains
  - health checks reported `redcore-web` and all three APIs as `200`
- Domain / TLS status reported at handoff time:
  - `redcoreos.net`
  - `www.redcoreos.net`
  - `api.redcoreos.net`
  - `tuning-api.redcoreos.net`
  - `os-api.redcoreos.net`
  - `api.redcore-tuning.com` was still called out as the remaining domain that needed DNS/cert/vhost completion depending on propagation and server config
- Google OAuth status remains the main live uncertainty:
  - earlier checks here showed `google` provider present at `/api/auth/providers`
  - `pm2 env 10` originally showed `AUTH_URL` / `NEXTAUTH_URL` but not `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET`
  - the remaining live verification step is still to confirm `pm2 restart redcore-web --update-env` actually propagated the Google env vars and that browser login no longer raises `invalid_client`
- Tuning truth remains one-time license based:
  - `redcore Tuning` is free + `12.99` one-time license key
  - `redcore OS` is free
  - the website checkout/webhook, desktop license flow, and cloud entitlement logic were updated toward that model
- Files changed in this phase include the following truth-alignment surfaces:
  - `apps/web/src/app/api/checkout/route.ts`
  - `apps/web/src/app/api/webhook/route.ts`
  - `apps/web/src/lib/auth.ts`
  - `apps/tuning-desktop/src/main/index.ts`
  - `apps/tuning-desktop/src/preload/index.ts`
  - `apps/tuning-desktop/src/renderer/pages/subscription/SubscriptionPage.tsx`
  - `apps/tuning-desktop/src/renderer/pages/onboarding/OnboardingPage.tsx`
  - `apps/cloud-api/src/routes/license.ts`
  - `apps/cloud-api/src/routes/auth.ts`
  - `apps/cloud-api/src/routes/users.ts`
  - `apps/cloud-api/src/db/index.ts`
  - `CODEXHANDOFF.md`
- Current repo state at this handoff:
  - there are still local modified files and untracked artifacts in the worktree
  - `scripts/vds-install-hermes-and-fix-web.sh` exists locally as a helper but may not yet be present on the VDS
  - the server `git remote` previously contained embedded credentials and should be treated as a rotation / cleanup item

