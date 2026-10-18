{ moduleWithSystem, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.fetch ];
    }
  );
in
{
  flake = {
    nixosModules.fetch = module;
    darwinModules.fetch = module;
  };

  perSystem =
    { inputs', ... }:
    {
      packages.fetch = inputs'.fetch.packages.default;
    };
}
