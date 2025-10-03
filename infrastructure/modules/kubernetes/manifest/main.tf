variable "url" {
  type        = string
  description = "The URL of the Kubernetes manifest to apply"

  validation {
    condition     = can(regex("^https?://", var.url))
    error_message = "The URL must start with http:// or https://"
  }
}

resource "null_resource" "manifest" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${var.url}"
  }
}
