{ moduleWithSystem, inputs, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.btop ];
    }
  );
in
{
  flake = {
    nixosModules.btop = module;
    darwinModules.btop = module;
  };

  perSystem =
    { pkgs, inputs', ... }:
    {
      packages.btop = inputs.wrappers.wrappers.btop.wrap {
        inherit pkgs;
        settings = {
          color_theme = "catppuccin_mocha";
          theme_background = true;
        };
        themes.catppuccin_mocha = builtins.readFile "${inputs'.catppuccin.packages.btop}/catppuccin_mocha.theme";
      };
    };
}
