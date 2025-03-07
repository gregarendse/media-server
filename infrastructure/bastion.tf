resource "oci_bastion_bastion" "bastion" {
  bastion_type     = "STANDARD"
  compartment_id   = oci_identity_compartment.homelab.id
  target_subnet_id = oci_core_subnet.private.id
  client_cidr_block_allow_list = [
    "${data.http.public_ip.response_body}/32"
  ]

  freeform_tags = merge(var.tags, {})

}

# resource "oci_bastion_session" "session" {
#   bastion_id = oci_bastion_bastion.bastion.id

#   for_each = {
#     for index, i in data.oci_core_instance_pool_instances.instances.instances :  i.id => i
#   }

#   session_ttl_in_seconds = 3600
#   display_name = each.value.display_name

#   key_details {
#     public_key_content = file("~/.ssh/id_rsa_oci.pub")
#   }

#   target_resource_details {
#     session_type                               = "PORT_FORWARDING"
#     target_resource_id                         = each.value.id
#     target_resource_operating_system_user_name = "ubuntu"
#     target_resource_port                       = "22"
#   }

#   depends_on = [data.oci_core_instance_pool_instances.instances]
# }

# output "sessions" {
#   value = [
#     for session in oci_bastion_session.session : session.bastion_user_name
#   ]
# }
