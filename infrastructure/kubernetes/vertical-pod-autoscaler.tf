# https://github.com/stevehipwell/helm-charts/tree/main/charts/vertical-pod-autoscaler
# helm upgrade --install vertical-pod-autoscaler oci://ghcr.io/stevehipwell/helm-charts/vertical-pod-autoscaler --version 1.9.2
resource "helm_release" "vertical_pod_autoscaler" {
  name       = "vertical-pod-autoscaler"
  namespace  = "kube-system"
  repository = "oci://ghcr.io/stevehipwell/helm-charts"
  chart      = "vertical-pod-autoscaler"
  version    = "1.9.2"
}
