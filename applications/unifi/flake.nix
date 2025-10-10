{
  description = "UniFi Controller Kubernetes deployment with kubenix";

  inputs = {
    kubenix.url = "github:hall/kubenix";
  };

  outputs = { self, kubenix, ... }:
    let
      system = "x86_64-linux";
      unifi-manifests = (kubenix.evalModules.${system} {
        module = { ... }: {
          imports = [ ./unifi.nix ];
        };
      }).config.kubernetes.result;
    in {
      packages.${system} = {
        default = unifi-manifests;
        manifests = unifi-manifests;
      };
    };
}
