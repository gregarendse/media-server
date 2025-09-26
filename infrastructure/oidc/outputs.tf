output "dynamic_group_id" {
  value = oci_identity_dynamic_group.github_actions.id
}

output "policy_id" {
  value = oci_identity_policy.github_actions_policy.id
}
