# Google Maps Setup (Service Cloud Agent)

We use a Hierarchy Custom Setting to store the Google Maps API key.

## Configure the key in Salesforce
Setup → **Custom Settings** → **Integration Settings** → **Manage** → **New (Organization Default Value)**

Set:
- **Google Maps API Key** = your API key

## Notes
- Do not commit API keys.
- Consider restricting the key in Google Cloud Console to your org’s egress IPs (or to Places API only) when ready.
