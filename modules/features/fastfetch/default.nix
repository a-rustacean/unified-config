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
    { pkgs, inputs', ... }:
    let
      palette =
        (builtins.fromJSON (builtins.readFile "${inputs'.catppuccin.packages.palette}/palette.json"))
        .mocha.colors;
    in
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
            color = palette.mauve.hex;
            key.color = palette.teal.hex;
          };
        };
      };
    };
}
