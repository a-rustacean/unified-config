{ moduleWithSystem, inputs, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.fastfetch ];
    }
  );
in
{
  flake = {
    nixosModules.fastfetch = module;
    darwinModules.fastfetch = module;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.fastfetch = inputs.wrappers.wrappers.fastfetch.wrap {
        inherit pkgs;
        settings = {
          modules = [
            "title"
            "separator"
            "os"
            "host"
            "kernel"
            "uptime"
            "packages"
            "shell"
            "terminal"
            "cpu"
            "gpu"
            "memory"
            "disk"
            "localip"
            "separator"
            "colors"
          ];
          display = {
            separator = " → ";
            color = "#cba6f7";
            key.color = "#94e2d5";
          };
        };
      };
    };
}
