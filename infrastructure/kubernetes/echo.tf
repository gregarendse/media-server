resource "helm_release" "echo" {
  name      = "echo"
  namespace = "echo"
  chart     = "../../server"

  create_namespace = true
  atomic           = true
  replace          = true
  cleanup_on_fail  = true
  skip_crds        = false
  force_update     = true


  values = [
    file("../../applications/echo/values.yaml")
  ]
}
