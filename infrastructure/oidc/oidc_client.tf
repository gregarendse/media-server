

# OIDC Client Application for GitHub Actions
#
# NOTE: As of 2025, the OCI Terraform provider does not support creating IAM Domain OAuth2 Client Applications (OIDC clients).
# You must create the OIDC client application manually in the OCI Console:
#
# 1. Go to Identity & Security → Domains → (your domain) → Client Applications.
# 2. Click "Add Client Application".
# 3. Set the name (e.g., github-actions-oidc-client), description, and redirect URI: https://token.actions.githubusercontent.com
# 4. Set grant type to "Client Credentials".
# 5. Set allowed scopes to:
#      urn:opc:idm:__myscopes__/openid
#      urn:opc:idm:__myscopes__/offline_access
# 6. Save and copy the generated client_id and client_secret.
# 7. Store the value <client_id>:<client_secret> as a GitHub Secret for use in your workflow.
