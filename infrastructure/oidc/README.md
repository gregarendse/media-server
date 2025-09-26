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
