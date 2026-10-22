{ moduleWithSystem, inputs, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.hyprsunset ];
    }
  );
in
{
  flake.nixosModules.hyprsunset = module;

  perSystem =
    { pkgs, lib, ... }:
    {
      packages.hyprsunset =
        if pkgs.stdenv.hostPlatform.isLinux then
          inputs.wrappers.lib.wrapPackage (
            { ... }:
            {
              inherit pkgs;
              package = pkgs.hyprsunset;
              flags."--config" = pkgs.writeText "hyprsunset.conf" ''
                profile {
                  time = 7:30
                  identity = true
                }
                profile {
                  time = 21:00
                  temperature = 5000
                  gamma = 0.8
                }
                max-gamma = 100
              '';
            }
          )
        else
          pkgs.runCommand "hyprsunset-unsupported"
            {
              meta = {
                platforms = lib.platforms.linux;
                badPlatforms = lib.platforms.darwin;
              };
            }
            ''
              echo "hyprsunset is not supported on ${pkgs.stdenv.hostPlatform.system}" >&2
              exit 1
            '';
    };
}
