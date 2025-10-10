{
  description = "MongoDB backing store for UniFi Controller";

  inputs = {
    kubenix.url = "github:hall/kubenix";
  };

  outputs = { self, kubenix, ... }:
    let
      system = "x86_64-linux";
      mongo-manifests = (kubenix.evalModules.${system} {
        module = { ... }: {
          imports = [ ./mongo.nix ];
        };
      }).config.kubernetes.result;
    in {
      packages.${system} = {
        default = mongo-manifests;
        manifests = mongo-manifests;
      };
    };
}
