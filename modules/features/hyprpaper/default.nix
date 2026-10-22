{ moduleWithSystem, inputs, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.hyprpaper ];
    }
  );
in
{
  flake.nixosModules.hyprpaper = module;

  perSystem =
    { pkgs, lib, ... }:
    {
      packages.hyprpaper =
        if pkgs.stdenv.hostPlatform.isLinux then
          inputs.wrappers.lib.wrapPackage (
            { ... }:
            {
              inherit pkgs;
              package = pkgs.hyprpaper;
              flags."--config" = pkgs.writeText "hyprpaper.conf" ''
                wallpaper {
                  fit_mode = cover
                  monitor =
                  path = ${./wallpaper.jpg}
                }
                splash = false
              '';
            }
          )
        else
          pkgs.runCommand "hyprpaper-unsupported"
            {
              meta = {
                platforms = lib.platforms.linux;
                badPlatforms = lib.platforms.darwin;
              };
            }
            ''
              echo "hyprpaper is not supported on ${pkgs.stdenv.hostPlatform.system}" >&2
              exit 1
            '';
    };
}
