resource "helm_release" "echo" {
  name             = "echo"
  namespace        = "echo"
  create_namespace = true
  chart            = "../../server"
  replace          = true
  values = [
    file("../../applications/echo/values.yaml")
  ]
}
