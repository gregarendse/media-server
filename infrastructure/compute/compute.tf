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
    ignore_changes        = [instance_details[0].launch_details[0].metadata]
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


