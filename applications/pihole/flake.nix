{
  description = "Pi-hole Kubernetes deployment with kubenix";

  inputs = {
    kubenix.url = "github:hall/kubenix";
  };

  outputs = { self, kubenix, ...}: let
      system = "x86_64-linux";
      
      # Import configuration values
      config = import ./config.nix;
      
      # Build Pi-hole manifests using kubenix
      pihole-manifests = (kubenix.evalModules.${system} {
        module = { ... }: {
          imports = [ ./pihole.nix ];
        };
      }).config.kubernetes.result;

in {
      packages.${system} = {
        default = pihole-manifests;
        manifests = pihole-manifests;
      };
    };
}