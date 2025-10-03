resource "helm_release" "traefik" {
  name      = "traefik"
  namespace = "traefik"
  chart     = "oci://ghcr.io/traefik/helm/traefik"

  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  skip_crds        = false

  set = [{
    name  = "service.type"
    value = "NodePort"
    }, {
    name  = "ports.web.nodePort"
    value = "30080"
    }, {
    name  = "ports.websecure.nodePort"
    value = "30443"
  }]

}
