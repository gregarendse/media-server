resource "oci_core_instance_configuration" "ubuntu" {
  compartment_id = data.oci_identity_compartment.homelab.id
  display_name   = "ubuntu"
  freeform_tags  = merge(var.tags, {})

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id = data.oci_identity_compartment.homelab.id
      shape          = var.shape

      shape_config {
        ocpus         = 4 / var.instance_count
        memory_in_gbs = 24 / var.instance_count
      }

      create_vnic_details {
        subnet_id        = data.oci_core_subnet.private.id
        assign_public_ip = false
      }

      source_details {
        source_type             = "image"
        image_id                = data.oci_core_images.images.images[0].id
        boot_volume_size_in_gbs = 200 / var.instance_count
      }

      metadata = {
        ssh_authorized_keys = file(var.public_key_path)
        user_data           = data.cloudinit_config.cloudinit.rendered
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_core_instance_pool" "ubuntu" {
  compartment_id                  = data.oci_identity_compartment.homelab.id
  display_name                    = "ubuntu"
  instance_display_name_formatter = "ubuntu-$${launchCount}"
  size                            = var.instance_count
  freeform_tags                   = merge(var.tags, {})

  instance_configuration_id = oci_core_instance_configuration.ubuntu.id

  dynamic "placement_configurations" {
    for_each = data.oci_identity_availability_domains.availability_domains.availability_domains[*].name
    content {
      availability_domain = placement_configurations.value

      primary_vnic_subnets {
        subnet_id = data.oci_core_subnet.private.id
      }
    }
  }
}

data "oci_core_instances" "instances" {
  compartment_id = data.oci_identity_compartment.homelab.id
  state          = "RUNNING"
}

data "terraform_remote_state" "network" {
  backend = "s3" # or whatever backend you use
  config = {
    bucket = "gregarendse-terraform"
    key    = "network/state.json"

    # Using Backblaze B2 - these validations do not apply
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

locals {
  backend_listeners = [for b_k, b_v in data.terraform_remote_state.network.outputs.backend_set : {
    name = b_v.name
    port = data.terraform_remote_state.network.outputs.listener[b_k].port
  }]

  instances = flatten([
    for instance in data.oci_core_instances.instances.instances : [
      for backend_listener in local.backend_listeners : {
        id            = instance.id
        instance_name = instance.display_name
        port          = backend_listener.port
        name          = backend_listener.name
      }
    ]
  ])

}

resource "oci_network_load_balancer_backend" "backend" {
  for_each = { for i in local.instances : "${i.instance_name}-${i.name}" => i }

  network_load_balancer_id = data.terraform_remote_state.network.outputs.nlb.id
  backend_set_name         = each.value.name

  target_id = each.value.id
  port      = each.value.port

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}
