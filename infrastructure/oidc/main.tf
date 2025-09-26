resource "oci_identity_dynamic_group" "github_actions" {
  compartment_id = var.tenancy_ocid
  name           = "github-actions-oidc-group"
  description    = "Dynamic group for GitHub Actions OIDC"
  # Only allow OIDC tokens from GitHub Actions for the master branch of the specified repo
  matching_rule = "ALL {ANY {instance.compartment.id = '${data.oci_identity_compartment.homelab.id}'}, ANY {token.issuer = 'https://token.actions.githubusercontent.com', token.subject = 'repo:${var.github_org}/${var.github_repo}:ref:refs/heads/master'}}"
}

resource "oci_identity_policy" "github_actions_policy" {
  compartment_id = data.oci_identity_compartment.homelab.id
  name           = "github-actions-oidc-policy"
  description    = "Policy for GitHub Actions OIDC dynamic group"
  # TODO: Restrict permissions to only what is needed for your workflow (principle of least privilege)
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.github_actions.name} to manage all-resources in compartment id ${data.oci_identity_compartment.homelab.id}"
  ]
}

# Note: As of 2025, Oracle Cloud provides a pre-configured OIDC federation for GitHub Actions. You do not need to create a custom federation resource unless you have a special use case.
