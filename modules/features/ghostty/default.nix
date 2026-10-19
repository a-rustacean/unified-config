{ moduleWithSystem, inputs, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          ghostty = self'.packages.ghostty;
        })
      ];

      environment.systemPackages = [
        self'.packages.ghostty
      ];
    }
  );
in
{
  flake = {
    nixosModules.ghostty = module;
    darwinModules.ghostty = module;
  };

  perSystem =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    {
      packages.ghostty = inputs.wrappers.wrappers.ghostty.wrap {
        inherit pkgs;
        settings = {
          # TODO:
          command = "${lib.getExe self'.packages.zsh} -l";
          working-directory = "home";
          language = "en";
          font-family = "JetBrainsMono Nerd Font";
          font-size = 20;
          cursor-style = "block";
          mouse-hide-while-typing = true;
          scroll-to-bottom = [
            "keystroke"
            "output"
          ];
          confirm-close-surface = false;
          theme = "Catppuccin Mocha";
          background-opacity = 0.90;
          background-opacity-cells = true;
          macos-titlebar-style = "hidden";
          background-blur = true;
          window-padding-x = 10;
          window-padding-y = 10;
          window-padding-balance = true;
          window-padding-color = "extend";
          shell-integration = "detect";
          shell-integration-features = [
            "no-cursor"
            "sudo"
          ];
          auto-update = "off";
        };
      };
    };
}
