{ moduleWithSystem, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.prismlauncher ];
    }
  );
in
{
  flake = {
    nixosModules.prismlauncher = module;
    darwinModules.prismlauncher = module;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.prismlauncher = pkgs.prismlauncher.override {
        prismlauncher-unwrapped = pkgs.prismlauncher-unwrapped.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ [
            ./no-ownership-check.patch
          ];
        });
      };
    };
}
