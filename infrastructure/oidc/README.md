# OCI GitHub Actions OIDC Terraform Project

This Terraform project configures Oracle Cloud Infrastructure (OCI) to allow GitHub Actions workflows to authenticate using OIDC (OpenID Connect) securely, following best practices.

## What this project does
- Creates a Dynamic Group in OCI that matches OIDC tokens from your GitHub repository's `master` branch only.
- Grants permissions to this Dynamic Group via a policy (edit the policy for least privilege).

## Prerequisites
- OCI tenancy and compartment IDs
- Admin permissions to create dynamic groups and policies
- Your GitHub organization and repository name

## Usage
1. **Edit `variables.tf`** with your tenancy, compartment, GitHub org, and repo.
2. Run `terraform init && terraform apply` in this directory.
3. The output will show the Dynamic Group and Policy IDs.

## Configuring the OIDC Client Application (Manual Step)

**As of 2025, the OCI Terraform provider does not support creating IAM Domain OAuth2 Client Applications (OIDC clients). You must create the OIDC client application manually:**



**Step-by-step for Confidential Application setup (OAuth configuration):**

When creating the Confidential Application for GitHub Actions OIDC, use the following settings:

- **Client configuration:**
  - Select **Configure this application as a client now**

- **Allowed grant types:**
  - Check **Client credentials**
  - Uncheck all others (unless you have a specific use case)

- **Allow non-HTTPS URLs:**
  - Leave **unchecked** (do not allow non-HTTPS URLs)

- **Redirect URL:**
  - Set to: `https://token.actions.githubusercontent.com`

- **Post-logout redirect URL, Logout URL:**
  - Leave blank

- **Client type:**
  - Select **Confidential**

- **Allowed operations:**
  - Leave **Introspect** and **On behalf of** unchecked (unless you have a specific advanced use case)

- **ID token encryption algorithm:**
  - Leave as default

- **Bypass consent:**
  - Optional, can be left off (default)

- **Client IP address:**
  - Leave as **Anywhere** (default)

- **Token issuance policy:**
  - Leave as default

- **Authorized resources:**
  - Select **All** (default)

- **Add resources / Add app roles:**
  - Leave blank unless you have a specific need

---

1. Go to **Identity & Security → Domains → (your domain) → Applications** (sometimes called **App Registrations** or **Integrated Applications**) in the OCI Console. The label may change; look for where you can register or manage OAuth2/OIDC clients.
2. Click **Add Application** and select **Confidential Application** (this is required for GitHub Actions OIDC integration).
3. **On the creation form, fill out only:**
   - **Name:** `github-actions-oidc-client` (or any descriptive name)
   - **Description:** `OIDC client for GitHub Actions workflow authentication`
   - All other fields (icon, URLs, display, user access, tags) can be left blank or at their default values.
4. **After creation**, go to the application's settings and configure:
   - **Grant type:** `Client Credentials`
   - **Redirect URI:** `https://token.actions.githubusercontent.com`
   - **Allowed scopes:**
     - `urn:opc:idm:__myscopes__/openid`
     - `urn:opc:idm:__myscopes__/offline_access`
5. Save and copy the generated `client_id` and `client_secret`.
6. Store the value `<client_id>:<client_secret>` as a GitHub Secret (e.g., `OIDC_CLIENT_IDENTIFIER_ACCT1`) for use in your workflow.

---

## Configuring GitHub Actions
1. In your GitHub repository, go to **Settings > Security > OIDC** and add your OCI tenancy as a trusted identity provider (if not already present).
2. In your workflow, use the following permissions block:

```yaml
permissions:
  id-token: write
  contents: read
```

3. Use the [Oracle Cloud CLI Action](https://github.com/oracle-actions/configure-oci-credentials) or similar to authenticate with OIDC in your workflow. Example:

```yaml
- name: Configure OCI credentials
  uses: oracle-actions/configure-oci-credentials@v1.2.2
  with:
    auth-type: "OIDC"
    tenancy-ocid: ${{ secrets.OCI_TENANCY_OCID }}
    region: ${{ secrets.OCI_REGION }}
    # No need to provide user OCID, fingerprint, or private key for OIDC
```

4. Your workflow will now be able to access OCI resources as permitted by the policy, but only when running from the `master` branch.

## Best Practices
- **Principle of Least Privilege:** Edit the policy to only allow the minimum permissions needed for your workflow.
- **Branch Restriction:** The dynamic group only matches OIDC tokens from the `master` branch.
- **Compartment Scope:** Scope the policy to the smallest compartment possible.
- **Review Oracle Documentation:** See [Oracle's OIDC docs](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm) and [the referenced blog post](https://blogs.oracle.com/ateam/post/github-actions-oci-a-guide-to-secure-oidc-token-exchange) for more details.

---

_This project was generated with security and maintainability in mind. Please review and adapt to your organization's needs._
