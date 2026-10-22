{ moduleWithSystem, inputs, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.hypridle ];
    }
  );
in
{
  flake.nixosModules.hypridle = module;

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.hypridle =
        if pkgs.stdenv.hostPlatform.isLinux then
          inputs.wrappers.lib.wrapPackage (
            { ... }:
            {
              inherit pkgs;
              package = pkgs.hypridle;
              flags."--config" = pkgs.writeText "hypridle.conf" ''
                general {
                  after_sleep_cmd = hyprctl dispatch dpms on
                  ignore_dbus_inhibit = false
                  lock_cmd = ${lib.getExe self'.packages.hyprlock}
                }

                listener {
                  timeout = 900
                  on-timeout = ${lib.getExe self'.packages.hyprlock}
                }

                listener {
                  timeout = 1200
                  on-timeout = hyprctl dispatch dpms off
                  on-resume = hyprctl dispatch dpms on
                }
              '';
            }
          )
        else
          pkgs.runCommand "hypridle-unsupported"
            {
              meta = {
                platforms = lib.platforms.linux;
                badPlatforms = lib.platforms.darwin;
              };
            }
            ''
              echo "hypridle is not supported on ${pkgs.stdenv.hostPlatform.system}" >&2
              exit 1
            '';
    };
}
