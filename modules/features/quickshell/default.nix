{ moduleWithSystem, inputs, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      services.upower.enable = true;
      environment.systemPackages = [ self'.packages.quickshell ];
    }
  );
in
{
  flake.nixosModules.quickshell = module;

  perSystem =
    { pkgs, lib, ... }:
    {
      packages.quickshell =
        if pkgs.stdenv.hostPlatform.isLinux then
          inputs.wrappers.wrappers.quickshell.wrap {
            inherit pkgs;
            configDir = "${./config}";
            env.XDG_DATA_DIRS = "${pkgs.nerd-fonts.jetbrains-mono}/share:/run/current-system/sw/share:/nix/var/nix/profiles/default/share";
          }
        else
          pkgs.runCommand "quickshell-unsupported"
            {
              meta = {
                platforms = lib.platforms.linux;
                badPlatforms = lib.platforms.darwin;
              };
            }
            ''
              echo "quickshell is not supported on ${pkgs.stdenv.hostPlatform.system}" >&2
              exit 1
            '';
    };
}
