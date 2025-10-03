variable "shape" {
  type = string
  # default = "VM.Standard.E2.1.Micro"
  default = "VM.Standard.A1.Flex"
}

variable "instance_count" {
  type    = number
  default = 2
}

data "oci_core_images" "images" {
  compartment_id           = data.oci_identity_compartment.root.id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04 Minimal"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
  shape                    = var.shape
}


resource "oci_core_instance_configuration" "ubuntu" {
  compartment_id = oci_identity_compartment.homelab.id
  display_name   = "ubuntu"
  freeform_tags  = merge(var.tags, {})

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id = oci_identity_compartment.homelab.id
      shape          = var.shape

      shape_config {
        ocpus         = 4 / var.instance_count
        memory_in_gbs = 24 / var.instance_count
      }

      create_vnic_details {
        subnet_id        = oci_core_subnet.private.id
        assign_public_ip = false
      }

      source_details {
        source_type             = "image"
        image_id                = data.oci_core_images.images.images[0].id
        boot_volume_size_in_gbs = 50
      }

      agent_config {
        plugins_config {
          desired_state = "ENABLED"
          name          = "Bastion"
        }
      }

      metadata = {
        ssh_authorized_keys = file("~/.ssh/id_rsa_oci.pub")
        user_data = base64encode(
          templatefile("user-data/cloud-init.yaml", {
            hostname = "ubuntu"
          })
        )
      }
    }

  }
}

resource "oci_core_instance_pool" "ubuntu" {
  compartment_id = oci_identity_compartment.homelab.id
  display_name   = "ubuntu"
  size           = var.instance_count
  freeform_tags  = merge(var.tags, {})

  instance_configuration_id = oci_core_instance_configuration.ubuntu.id

  placement_configurations {
    availability_domain = data.oci_identity_availability_domains.availability_domains.availability_domains[0].name

    primary_vnic_subnets {
      subnet_id = oci_core_subnet.private.id
    }
  }

  placement_configurations {
    availability_domain = data.oci_identity_availability_domains.availability_domains.availability_domains[1].name

    primary_vnic_subnets {
      subnet_id = oci_core_subnet.private.id
    }
  }

  placement_configurations {
    availability_domain = data.oci_identity_availability_domains.availability_domains.availability_domains[2].name

    primary_vnic_subnets {
      subnet_id = oci_core_subnet.private.id
    }
  }
}

# resource "oci_core_instance" "ubuntu_instance" {
#     count = var.instance_count

#     # Required
#     availability_domain = data.oci_identity_availability_domains.availability_domains.availability_domains[count.index].name
#     compartment_id = data.oci_identity_compartment.homelab.id

#     shape = var.shape
#     shape_config {
#       ocpus = 4 / var.instance_count
#       memory_in_gbs = 24 / var.instance_count
#     }

#     source_details {
#         source_type = "image"
#         # source_id = "ocid1.image.oc1.uk-london-1.aaaaaaaavehem6scohtwwfpxj576isnczlujphlbnk5ynzmhra2irryqwt4q"
#         # source_id = "ocid1.image.oc1.uk-london-1.aaaaaaaalmz2f3ryfakc4fd5r4uteua3az3dfvcxr6q77b2nvddzevscjk5q"
#         source_id = data.oci_core_images.images.images[0].id

#         boot_volume_size_in_gbs = 200 / var.instance_count
#     }

#     # Optional
#     display_name = "homelab"
#     create_vnic_details {
#         assign_public_ip = true
#         subnet_id = data.oci_core_subnet.private.id
#     }
#     metadata = {
#         ssh_authorized_keys = file("~/.ssh/id_rsa_oci.pub")
#         # user_data = data.cloudinit_config.cloudinit.rendered
#     } 
#     preserve_boot_volume = false

#     freeform_tags = {
#       "project" = "homelab"
#     }
# }

output "pool" {
  value = oci_core_instance_pool.ubuntu
}
