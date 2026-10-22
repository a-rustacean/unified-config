{ self, ... }:
{
  flake.nixosModules.desktop =
    { ... }:
    let
      modules = with self.nixosModules; [
        core
        audio
        network
        nix-ld
        systemTheme
        hyprland
        sddm
        sddm-autologin
        dunst
        quickshell
        hyprpaper
        hyprlock
        hypridle
        hyprsunset
        hyprlauncher
        prismlauncher
      ];
    in
    {
      imports = modules;
    };
}
