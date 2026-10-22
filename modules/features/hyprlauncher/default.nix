{ moduleWithSystem, inputs, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.hyprlauncher ];
    }
  );
in
{
  flake.nixosModules.hyprlauncher = module;

  perSystem =
    { pkgs, lib, ... }:
    {
      packages.hyprlauncher =
        if pkgs.stdenv.hostPlatform.isLinux then
          inputs.wrappers.lib.wrapPackage (
            { ... }:
            {
              inherit pkgs;
              package = pkgs.hyprlauncher;
            }
          )
        else
          pkgs.runCommand "hyprlauncher-unsupported"
            {
              meta = {
                platforms = lib.platforms.linux;
                badPlatforms = lib.platforms.darwin;
              };
            }
            ''
              echo "hyprlauncher is not supported on ${pkgs.stdenv.hostPlatform.system}" >&2
              exit 1
            '';
    };
}
