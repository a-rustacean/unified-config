{ moduleWithSystem, inputs, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.hyprlock ];
    }
  );
in
{
  flake.nixosModules.hyprlock = module;

  perSystem =
    {
      pkgs,
      lib,
      inputs',
      ...
    }:
    let
      palette =
        (builtins.fromJSON (builtins.readFile "${inputs'.catppuccin.packages.palette}/palette.json"))
        .mocha.colors;

      hex = color: builtins.substring 1 6 color;
    in
    {
      packages.hyprlock =
        if pkgs.stdenv.hostPlatform.isLinux then
          inputs.wrappers.wrappers.hyprlock.wrap {
            inherit pkgs;
            settings = {
              general = {
                hide_cursor = true;
                ignore_empty_input = false;
                grace = 300;
              };

              animations = {
                enabled = true;
                fade_in = {
                  duration = 300;
                  bezier = "easeOutQuint";
                };
                fade_out = {
                  duration = 300;
                  bezier = "easeOutQuint";
                };
              };

              background = [
                {
                  path = "${../hyprpaper/wallpaper.jpg}";
                  blur_passes = 4;
                  blur_size = 8;
                  contrast = 0.8;
                  brightness = 0.5;
                }
              ];

              label = [
                {
                  text = "cmd[update:1000] date '+%I:%M %p'";
                  font_size = 96;
                  font_family = "JetBrainsMono Nerd Font";
                  color = "rgb(${hex palette.text.hex})";
                  position = "0, 120";
                  monitor = "";
                  halign = "center";
                  valign = "center";
                }
                {
                  text = "cmd[update:3600] date '+%A, %B %d'";
                  font_size = 24;
                  font_family = "JetBrainsMono Nerd Font";
                  color = "rgb(${hex palette.subtext0.hex})";
                  position = "0, 40";
                  monitor = "";
                  halign = "center";
                  valign = "center";
                }
              ];

              input-field = [
                {
                  size = "320, 54";
                  position = "0, -70";
                  monitor = "";
                  dots_center = true;
                  fade_on_empty = false;
                  placeholder_text = "Password...";
                  outline_thickness = 2;
                  dots_size = 0.2;
                  dots_spacing = 0.3;
                  font_color = "rgb(${hex palette.text.hex})";
                  inner_color = "rgb(${hex palette.surface0.hex})";
                  outer_color = "rgb(${hex palette.lavender.hex})";
                  fail_color = "rgb(${hex palette.red.hex})";
                  fail_text = "<i>Incorrect...</i>";
                  capslock_color = "rgb(${hex palette.yellow.hex})";
                  check_color = "rgb(${hex palette.green.hex})";
                  shadow_passes = 2;
                  rounding = 12;
                }
              ];
            };
          }
        else
          pkgs.runCommand "hyprlock-unsupported"
            {
              meta = {
                platforms = lib.platforms.linux;
                badPlatforms = lib.platforms.darwin;
              };
            }
            ''
              echo "hyprlock is not supported on ${pkgs.stdenv.hostPlatform.system}" >&2
              exit 1
            '';
    };
}
