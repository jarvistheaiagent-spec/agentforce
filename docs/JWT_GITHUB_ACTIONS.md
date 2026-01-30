# JWT Auth for GitHub Actions (Salesforce)

This repo is configured to use JWT auth in GitHub Actions.

## Required GitHub Secrets
Add these in **GitHub → Settings → Secrets and variables → Actions → New repository secret**:

- `SF_CLIENT_ID` — Consumer Key of the Connected App / External Client App.
- `SF_USERNAME` — Salesforce username (e.g. `jarvistheaiagent.dfc56ab2e2e4@agentforce.com`).
- `SF_INSTANCE_URL` — Org instance URL (e.g. `https://orgfarm-930e3e7509-dev-ed.develop.my.salesforce.com`).
- `SF_JWT_KEY` — The **private key** used to sign the JWT.

> Store the private key as a secret; never commit it.

## Verifying
Once secrets are set, push to `main` and check the workflow run logs.

## Notes
- The workflow currently uses `sf project deploy validate` with `NoTestRun` until tests exist.
- When we add Apex, we should switch to `RunLocalTests` or a targeted test suite.
