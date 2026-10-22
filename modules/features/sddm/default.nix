{ ... }:
{
  flake.nixosModules.sddm =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.catppuccin-sddm.override {
          flavor = "mocha";
          font = "JetBrainsMono Nerd Font";
          fontSize = "11";
          background = null;
        })
      ];
      services.xserver.enable = true;
      services.displayManager.sddm = {
        enable = true;
        theme = "catppuccin-mocha-blue";
        package = pkgs.kdePackages.sddm;
      };
    };
}
