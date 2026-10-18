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
    { pkgs, ... }:
    let
      catppuccin = pkgs.catppuccin.override {
        variant = "mocha";
        themeList = [ "btop" ];
      };
    in
    {
      packages.btop = inputs.wrappers.wrappers.btop.wrap {
        inherit pkgs;
        settings = {
          color_theme = "catppuccin_mocha";
          theme_background = true;
        };
        themes.catppuccin_mocha = "${catppuccin}/btop/catppuccin_mocha.theme";
      };
    };
}
