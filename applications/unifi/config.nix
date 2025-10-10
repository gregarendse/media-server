# UniFi Controller kubenix configuration
# Customize values here to match your environment

{
  cluster = {
    domain = "arendse.nom.za";
  };

  unifi = {
    namespace = "unifi";
    image = "linuxserver/unifi-controller:latest";
    replicas = 1;
    timezone = "UTC";
    puid = "1000";
    pgid = "1000";

    persistence = {
      enabled = true;
      size = "10Gi";
      storageClassName = "oci";
    };

    resources = {
      requests = {
        cpu = "200m";
        memory = "1Gi";
      };
      limits = {
        cpu = "1000m";
        memory = "2Gi";
      };
    };
  };

  network = {
    serviceType = "ClusterIP";

    loadBalancer = {
      enabled = true;
      annotations = {
        "metallb.universe.tf/address-pool" = "unifi";
        "metallb.universe.tf/allow-shared-ip" = "unifi";
      };
    };

    ingress = {
      enabled = true;
      class = "nginx";
      host = "unifi.arendse.nom.za";
      tls = {
        enabled = true;
        secretName = "unifi-tls";
        issuer = "letsencrypt-prod";
      };
    };
  };
}
