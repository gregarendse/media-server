locals {
  subnet_private_cdir = cidrsubnet(var.cidr_range, 8, 1)
  subnet_vpn_cdir     = cidrsubnet(var.cidr_range, 8, 7)
  subnet_public_cdir  = cidrsubnet(var.cidr_range, 8, 8)

  subnet_podCIDR     = "10.244.0.0/16"
  subnet_serviceCIDR = "10.96.0.0/12"

  protocol_numbers = {
    ALL    = "all"
    ICMP   = "1"
    TCP    = "6"
    UDP    = "17"
    ICMPv6 = "58"
  }

  public_ports = [
    {
      name     = "http"
      notes    = "HTTP ingress for traffic to the cluster"
      protocol = "TCP"
      ports = {
        listener = 80
        target   = 30080
      }
      health_check = {
        return_code = 200
        path        = "/ping"
        protocol    = "HTTP"
      }
    },
    {
      name     = "https"
      notes    = "HTTPS ingress for traffic to the cluster"
      protocol = "TCP"
      ports = {
        listener = 443
        target   = 30443
      }
      health_check = {
        return_code = 200
        path        = "/ping"
        protocol    = "HTTPS"
      }
    },
    {
      name     = "k0s-api"
      notes    = "controller <-> controller 	k0s controller join API, TLS with token auth"
      protocol = "TCP"
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
      notes    = "worker, CLI => controller 	Authenticated Kube API using Kube TLS client certs, ServiceAccount tokens with RBAC"
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
    }
  ]

  ports = [
    # HTTP Ports
    {
      name     = "http"
      protocol = "HTTP"
      port     = 30080
      notes    = "HTTP ingress for traffic to the cluster"
      public   = true
      health_check = {
        return_code = 200
        path        = "/ping"
      }
    },
    {
      name     = "https"
      protocol = "HTTPS"
      port     = 30443
      notes    = "HTTPS ingress for traffic to the cluster"
      public   = true
      health_check = {
        return_code = 200
        path        = "/ping"
      }
    },

    # Kubernetes Ports
    # Protocol 	Port 	Service 	Direction 	Notes
    {
      # TCP 	2380 	etcd peers 	controller <-> controller 	
      name         = "etcd-peers"
      protocol     = "TCP"
      port         = 2380
      notes        = "controller <-> controller"
      public       = false
      health_check = {}
    },
    {
      # TCP 	6443 	kube-apiserver 	worker, CLI => controller 	Authenticated Kube API using Kube TLS client certs, ServiceAccount tokens with RBAC
      name         = "kube-apiserver"
      protocol     = "TCP" # HTTPS
      port         = 6443
      notes        = "worker, CLI => controller 	Authenticated Kube API using Kube TLS client certs, ServiceAccount tokens with RBAC"
      public       = true
      health_check = {}
    },
    {
      # TCP 	179 	kube-router 	worker <-> worker 	BGP routing sessions between peers
      name         = "kube-router"
      protocol     = "TCP"
      port         = 179
      notes        = "worker <-> worker 	BGP routing sessions between peers"
      public       = false
      health_check = {}
    },
    {
      # UDP 	4789 	Calico 	worker <-> worker 	Calico VXLAN overlay
      name         = "calico"
      protocol     = "UDP"
      port         = 4789
      notes        = "worker <-> worker 	Calico VXLAN overlay"
      public       = false
      health_check = {}
    },
    {
      # TCP 	10250 	kubelet 	controller, worker => host * 	Authenticated kubelet API for the controller node kube-apiserver (and heapster/metrics-server addons) using TLS client certs
      name         = "kubelet"
      protocol     = "TCP"
      port         = 10250
      notes        = "controller, worker => host * 	Authenticated kubelet API for the controller node kube-apiserver (and heapster/metrics-server addons) using TLS client certs"
      public       = false
      health_check = {}
    },
    {
      # TCP 	9443 	k0s-api 	controller <-> controller 	k0s controller join API, TLS with token auth
      name         = "k0s-api"
      protocol     = "TCP" # HTTPS
      port         = 9443
      notes        = "controller <-> controller 	k0s controller join API, TLS with token auth"
      public       = true
      health_check = {}
    },
    {
      # TCP 	8132 	konnectivity 	worker <-> controller 	Konnectivity is used as "reverse" tunnel between kube-apiserver and worker kubelets
      name         = "konnectivity"
      protocol     = "TCP"
      port         = 8132
      notes        = "worker <-> controller 	Konnectivity is used as reverse tunnel between kube-apiserver and worker kubelets"
      public       = true
      health_check = {}
    },
    {
      # TCP 	112 	keepalived 	controller <-> controller 	Only required for control plane load balancing vrrpInstances for ip address 224.0.0.18. 224.0.0.18 is a multicast IP address defined in RFC 3768.
      name         = "keepalive"
      protocol     = "TCP"
      port         = 112
      notes        = "controller <-> controller 	Only required for control plane load balancing vrrpInstances for ip address 224.0.0.18. 224.0.0.18 is a multicast IP address defined in RFC 3768."
      public       = false
      health_check = {}
    },
  ]
}
