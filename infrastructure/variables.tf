

#   Populated by environment variable TF_VAR_tenancy_ocid
variable "tenancy_ocid" {
  description = "Tenancy OCID"
  type        = string
}
#   Populated by environment variable TF_VAR_user_ocid
variable "user_ocid" {
  description = "User OCID"
  type        = string
}
#   Populated by environment variable TF_VAR_fingerprint
variable "fingerprint" {
  description = "Fingerprint associated with RSA public key configured to profile"
  type        = string

  validation {
    condition     = can(regex("^(:?.{2})+$", var.fingerprint))
    error_message = "Invalid fingerprint format, expected: xx:xx:xx...xx"
  }
}

#   Populated by environment variable TF_VAR_region
variable "private_key_path" {
  description = "Path to private key"
  type        = string
}

#   Populated by environment TF_VAR_private_key_path
variable "region" {
  description = "Region identifier"
  type        = string

  # https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm
}

variable "compartment_name" {
  description = "Name of compartment to house resources"
  type = string
  default = "homelab"
}

variable "cidr_range" {
  description = "VCN CIDR range"
  type = string
  default = "10.100.0.0/16"
}

variable "compute_image_ocid" {
  description = "Compute image source OCID"
  type = string
  # default = "ocid1.image.oc1.uk-london-1.aaaaaaaalmz2f3ryfakc4fd5r4uteua3az3dfvcxr6q77b2nvddzevscjk5q"
  default = "ocid1.image.oc1.uk-london-1.aaaaaaaaah4o6bubxrmqgocs6fdj3bxlnkb4wqqaruffaaodk2eigubu6g4q"
}