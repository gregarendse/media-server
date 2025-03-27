locals {
  subnet_private_cdir = cidrsubnet(var.cidr_range, 8, 1)
  subnet_vpn_cdir     = cidrsubnet(var.cidr_range, 8, 7)
  subnet_public_cdir  = cidrsubnet(var.cidr_range, 8, 8)

  # Pod network CIDR to use in the cluster. Defaults to 10.244.0.0/16.
  subnet_podCIDR = "10.244.0.0/16"
  # Network CIDR to use for cluster VIP services. Defaults to 10.96.0.0/12.
  subnet_serviceCIDR = "10.200.0.0/16"

  protocol_numbers = {
    ALL    = "all"
    ICMP   = "1"
    TCP    = "6"
    UDP    = "17"
    ICMPv6 = "58"
  }

  ports = [
    # {
    #   name     = "http"
    #   notes    = "HTTP ingress for traffic to the cluster"
    #   protocol = "TCP"
    #   ports = {
    #     listener = 80
    #     target   = 30080
    #   }
    #   health_check = {
    #     return_code = 200
    #     path        = "/ping"
    #     protocol    = "HTTP"
    #   }
    # },
    # {
    #   name     = "https"
    #   notes    = "HTTPS ingress for traffic to the cluster"
    #   protocol = "TCP"
    #   ports = {
    #     listener = 443
    #     target   = 30443
    #   }
    #   health_check = {
    #     return_code = 200
    #     path        = "/ping"
    #     protocol    = "HTTPS"
    #   }
    # },
    {
      name     = "k0s-api"
      notes    = "controller <-> controller     k0s controller join API, TLS with token auth"
      protocol = "TCP"
      public   = true
      ports = {
        listener = 9443
        target   = 9443
      }
      health_check = {
        protocol    = "HTTPS"
        path        = "/healthz"
        return_code = 404
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
      # TCP     8132     konnectivity     worker <-> controller     Konnectivity is used as "reverse" tunnel between kube-apiserver and worker kubelets
      name     = "konnectivity"
      protocol = "TCP"
      ports = {
        listener = 8132
        target   = 8132
      }
      notes  = "worker <-> controller     Konnectivity is used as reverse tunnel between kube-apiserver and worker kubelets"
      public = true
      health_check = {
        protocol = "TCP"
      }
    },
  ]
}
