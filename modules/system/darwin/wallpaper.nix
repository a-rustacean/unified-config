{ ... }:
{
  flake.darwinModules.wallpaper =
    { ... }:
    {
      system.activationScripts.myScript = {
        # TODO: no path
        text = ''
          /usr/bin/osascript -e "
            tell application \"Finder\"
              set desktop picture to POSIX file \"${../../../wallpaper.jpg}\"
            end tell
          "
        '';
      };
    };
}
