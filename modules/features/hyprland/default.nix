{ moduleWithSystem, inputs, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        package = self'.packages.hyprland;
        portalPackage = self'.packages.xdg-desktop-portal-hyprland;
      };

      services.displayManager.defaultSession = "hyprland";
    }
  );
in
{
  flake.nixosModules.hyprland = module;

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.hyprland =
        if pkgs.stdenv.hostPlatform.isLinux then
          lib.extendDerivation true pkgs.hyprland.passthru (
            inputs.wrappers.lib.wrapPackage (
              { ... }:
              {
                inherit pkgs;
                package = pkgs.hyprland;
                runtimePkgs = with pkgs; [
                  self'.packages.xdg-desktop-portal-hyprland
                  self'.packages.hypridle
                  self'.packages.hyprsunset
                  cliphist
                  wl-clipboard
                ];
                flags."--config" = "${./.}/hyprland.lua";
                env = {
                  HYPRLAND_PROGRAM_GHOSTTY = lib.getExe self'.packages.ghostty;
                  HYPRLAND_PROGRAM_HYPRLAUNCHER = lib.getExe self'.packages.hyprlauncher;
                  HYPRLAND_PROGRAM_HYPRPAPER = lib.getExe self'.packages.hyprpaper;
                  HYPRLAND_PROGRAM_HYPRLOCK = lib.getExe self'.packages.hyprlock;
                  HYPRLAND_PROGRAM_HYPRSHUTDOWN = lib.getExe self'.packages.hyprshutdown;
                  HYPRLAND_PROGRAM_HYPRPICKER = lib.getExe self'.packages.hyprpicker;
                  HYPRLAND_PROGRAM_QUICKSHELL = lib.getExe self'.packages.quickshell;
                  HYPRLAND_PROGRAM_DUNST = lib.getExe self'.packages.dunst;
                  # TODO: use hyprcursor
                  XCURSOR_PATH = "${pkgs.bibata-cursors}/share/icons";
                  XCURSOR_THEME = "Bibata-Modern-Ice";
                  XCURSOR_SIZE = "24";
                };
              }
            )
          )
        else
          pkgs.runCommand "hyprland-unsupported"
            {
              meta = {
                platforms = lib.platforms.linux;
                badPlatforms = lib.platforms.darwin;
              };
            }
            ''
              echo "hyprland is not supported on ${pkgs.stdenv.hostPlatform.system}" >&2
              exit 1
            '';

      packages.xdg-desktop-portal-hyprland = pkgs.xdg-desktop-portal-hyprland;
      packages.hyprshutdown = pkgs.hyprshutdown;
      packages.hyprpicker = pkgs.hyprpicker;
    };
}
