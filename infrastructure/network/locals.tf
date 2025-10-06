locals {
  subnet_private_cdir = cidrsubnet(var.cidr_range, 8, 1)
  subnet_vpn_cdir     = cidrsubnet(var.cidr_range, 8, 7)
  subnet_public_cdir  = cidrsubnet(var.cidr_range, 8, 8)

  protocol_numbers = {
    ALL    = "all"
    ICMP   = "1"
    TCP    = "6"
    UDP    = "17"
    ICMPv6 = "58"
  }

  ports = [
    {
      name     = "http"
      notes    = "HTTP ingress for traffic to the cluster"
      protocol = "TCP"
      public   = true
      ports = {
        listener = 80
        target   = 30080
      }
      health_check = {
        return_code = 404
        path        = "/ping"
        protocol    = "HTTP"
      }
    },
    {
      name     = "https"
      notes    = "HTTPS ingress for traffic to the cluster"
      protocol = "TCP"
      public   = true
      ports = {
        listener = 443
        target   = 30443
      }
      health_check = {
        return_code = 404
        path        = "/ping"
        protocol    = "HTTPS"
      }
    },
    {
      name     = "kube-apiserver"
      notes    = "worker, CLI => controller     Authenticated Kube API using Kube TLS client certs, ServiceAccount tokens with RBAC"
      protocol = "TCP"
      ports = {
        listener = 6443
        target   = 6443
      }
      public = true
      health_check = {
        protocol    = "HTTPS"
        path        = "/healthz"
        return_code = 401
      }
    },
    {
      name     = "dns"
      notes    = "Pi-hole DNS"
      protocol = "UDP"
      public   = true
      ports = {
        listener = 53
        target   = 30053
      }
      health_check = {
        protocol = "DNS"
      }
    },
    # Not currently used
    # {
    #   name     = "dhcp-udp"
    #   notes    = "DHCP for Pi-hole and other DHCP services"
    #   protocol = "UDP"
    #   public   = false
    #   ports = {
    #     listener = 67
    #     target   = 30067
    #   }
    # },
    # Not currently used
    # {
    #   name     = "ntp-udp"
    #   notes    = "NTP for Pi-hole and other NTP services"
    #   protocol = "UDP"
    #   public   = false
    #   ports = {
    #     listener = 123
    #     target   = 300123
    #   }
    # }
  ]
}
