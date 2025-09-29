resource "helm_release" "nginx" {
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"

  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  skip_crds        = false

  values = [
    file("../../applications/nginx/values.yaml")
  ]
}
