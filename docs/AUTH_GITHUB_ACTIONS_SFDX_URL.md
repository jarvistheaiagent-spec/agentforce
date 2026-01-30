# GitHub Actions Auth (SFDX Auth URL)

If your org doesn't allow creating a classic Connected App (required for JWT), use this method.

## Create the secret
On your Mac (Terminal.app):

```bash
cd /Users/jarvis/.openclaw/workspace/agentforce

# Make sure you're logged into the org locally (alias: dev)
sf org display -o dev --verbose --json > /tmp/dev-org.json

# Extract the SFDX auth URL and base64-encode it for GitHub Secrets
node -e "const fs=require('fs'); const j=JSON.parse(fs.readFileSync('/tmp/dev-org.json','utf8')); process.stdout.write(j.result.sfdxAuthUrl);" \
  | base64 \
  | pbcopy

echo "Copied base64 SFDX auth URL to clipboard. Create GitHub secret: SF_SFDX_AUTH_URL_B64"
```

Now create this GitHub repository secret:
- `SF_SFDX_AUTH_URL_B64` = paste from clipboard

> Treat this like a password. Anyone who can read this secret can access the org.

## Workflow
The GitHub Actions workflow will:
- decode the auth url into a file
- run `sf org login sfdx-url`
- validate a deploy

## Rotation
If the workflow starts failing auth, regenerate the auth URL locally and update the GitHub secret.
