# JWT Auth for GitHub Actions (Salesforce)

This repo uses JWT auth in GitHub Actions.

## Required GitHub Secrets
Add these in **GitHub → Settings → Secrets and variables → Actions**:

- `SF_CLIENT_ID` — Consumer Key (Client Id) of the Connected App / External Client App.
- `SF_USERNAME` — Salesforce username (e.g. `jarvistheaiagent.dfc56ab2e2e4@agentforce.com`).
- `SF_INSTANCE_URL` — Org instance URL (e.g. `https://orgfarm-930e3e7509-dev-ed.develop.my.salesforce.com`).
- `SF_JWT_KEY_B64` — **base64** of the private key PEM (recommended; avoids newline issues).

### Creating SF_JWT_KEY_B64
On your Mac (repo root), run:

```bash
base64 -i certs/salesforce/server.key | pbcopy
```

Paste into the GitHub secret `SF_JWT_KEY_B64`.

> Don’t store the raw PEM in GitHub secrets if you can avoid it; line endings/newlines often break JWT auth.

## Verifying
Push to `main` and check the workflow logs.

## Notes
- The workflow uses `sf project deploy validate` with `NoTestRun` until tests exist.
- Later, switch to `RunLocalTests` or a targeted test suite.
