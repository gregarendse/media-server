
#   Populated by environment variable TF_VAR_tenancy_ocid
variable "tenancy_ocid" {
  description = "Tenancy OCID"
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^ocid1.tenancy.oc1..*$", var.tenancy_ocid))
    error_message = "Invalid OCID format, expected: ocid1.tenancy.oc1..*"
  }
}
#   Populated by environment variable TF_VAR_user_ocid
variable "user_ocid" {
  description = "User OCID"
  type        = string

  validation {
    condition     = can(regex("^ocid1.user.oc1..*$", var.user_ocid))
    error_message = "Invalid OCID format, expected: ocid1.user.oc1..*"
  }
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

#   Populated by environment TF_VAR_private_key_path
variable "private_key_path" {
  description = "Path to private key"
  type        = string
  default     = "~/.oci/oci_api_key.pem"

  validation {
    condition     = can(file(var.private_key_path))
    error_message = "Private key file not found"
  }
}

#   Populated by environment variable TF_VAR_region
variable "region" {
  description = "Region identifier"
  type        = string
  # https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.region))
    error_message = "Invalid region format, expected: xx-xxxx-#, e.g. uk-london-1"
  }
}

variable "compartment_name" {
  description = "Name of compartment to house resources"
  type        = string
  default     = "homelab"
}

variable "github_org" {
  description = "GitHub organization"
  type        = string
  default     = "gregarendse"
}

variable "github_repo" {
  description = "GitHub repository"
  type        = string
  default     = "media-server"
}
