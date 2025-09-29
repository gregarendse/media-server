locals {
  applications = [
    "actual",
    "deluge",
    # "keel", ToDo: fix keel chart
    "plex",
    "prowlarr",
    "radarr",
    "sabnzbd",
    "sonarr",
    "tautulli",
    "wireguard"
  ]
}

resource "helm_release" "applications" {
  for_each = toset(local.applications)

  name      = each.key
  namespace = each.key
  chart     = "../../server"

  create_namespace = true
  atomic           = true
  replace          = true
  cleanup_on_fail  = true
  skip_crds        = false
  force_update     = true
  depends_on       = [helm_release.nginx]

  values = [
    file("../../applications/${each.key}/values.yaml")
  ]
}
