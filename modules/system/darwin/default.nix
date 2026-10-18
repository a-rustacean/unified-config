{ self, ... }:
{
  flake.darwinModules.system =
    { pkgs, ... }:
    {
      imports = with self.darwinModules; [
        user
        networking
        nix
        wallpaper
      ];

      environment.systemPackages = with pkgs; [
        betterdisplay
        utm
      ];

      system = {
        primaryUser = "dilshad";
        stateVersion = 7;
        nixpkgsRelease = "26.05";

        defaults = {
          dock = {
            autohide = true;
            mru-spaces = false;
            persistent-apps = [ ];
            show-recents = false;
          };
          finder = {
            AppleShowAllExtensions = true;
            FXPreferredViewStyle = "clmv";
          };
          loginwindow.GuestEnabled = true;
          screencapture = {
            disable-shadow = true;
            location = "~/Pictures/screenshots";
          };
          screensaver.askForPasswordDelay = 10;
        };
      };
    };
}
