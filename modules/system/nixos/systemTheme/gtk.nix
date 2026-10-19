{ ... }:
{
  flake.nixosModules.catppuccinGtk =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.catppuccin-gtk.override {
          variant = "mocha";
          accents = [ "blue" ];
          size = "standard";
        })
        (pkgs.catppuccin-kde.override {
          flavour = [ "mocha" ];
          accents = [ "blue" ];
        })
        pkgs.libsForQt5.qtstyleplugin-kvantum
        pkgs.adw-gtk3
        pkgs.libsForQt5.qt5ct
        pkgs.qt6Packages.qt6ct
      ];

      environment.variables.QT_QPA_PLATFORMTHEME = "kvantum";

      environment.etc."xdg/Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=Catppuccin-Mocha-Blue
      '';

      programs.dconf = {
        enable = true;
        profiles.user.databases = [
          {
            settings = {
              "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
                gtk-theme = "catppuccin-mocha-blue-standard";
              };
            };
          }
        ];
      };
    };
}
