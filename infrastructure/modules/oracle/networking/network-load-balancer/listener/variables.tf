variable "load_balancer_id" {
  description = "The OCID of the load balancer"
  type        = string
}

variable "name" {
  description = "The name of the listener"
  type        = string
}

variable "protocol" {
  description = "The protocol of the listener"
  type        = string
}

variable "ports" {
  description = "Port configuration"
  type = object({
    listener = number
    target   = number
  })
}

variable "health_check" {
  description = "Health check configuration"
  type = object({
    protocol    = string
    return_code = number
    path        = string
  })
}

variable "target_ids" {
  description = "The OCIDs of the backend sets"
  type = list(string)
  default = []
}

variable "target_ips" {
  description = "The IP addresses of the backend sets"
  type = list(string)
  default = []
}

variable "instances" {
  description = "The OCIDs of the instances"
  type = list(object({
    id           = string
    display_name = string
  }))
}