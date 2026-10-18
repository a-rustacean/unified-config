{ ... }:
{
  flake.darwinModules.aerospace = (
    { pkgs, lib, ... }:
    {
      services.aerospace = {
        enable = true;
        settings = {
          config-version = 2;
          after-startup-command = [ ];
          start-at-login = false;

          enable-normalization-flatten-containers = true;
          enable-normalization-opposite-orientation-for-nested-containers = true;

          accordion-padding = 30;

          default-root-container-layout = "tiles";
          default-root-container-orientation = "auto";

          on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
          automatically-unhide-macos-hidden-apps = true;

          persistent-workspaces = [
            "1"
            "2"
            "3"
            "4"
            "5"
            "6"
            "7"
            "8"
            "9"
          ];

          on-mode-changed = [ ];

          focus-follows-mouse.enabled = false;

          key-mapping.preset = "qwerty";

          gaps = {
            outer = {
              left = 8;
              bottom = 8;
              top = 8;
              right = 8;
            };
            inner = {
              vertical = 8;
              horizontal = 8;
            };
          };

          mode.main.binding = {
            "alt-enter" = "exec-and-forget ${lib.getExe pkgs.ghostty}";

            "alt-t" = "layout tiles horizontal vertical";

            "alt-minus" = "resize smart -50";
            "alt-equal" = "resize smart +50";

            "alt-h" = "focus left";
            "alt-j" = "focus down";
            "alt-k" = "focus up";
            "alt-l" = "focus right";

            "alt-shift-h" = "move left";
            "alt-shift-j" = "move down";
            "alt-shift-k" = "move up";
            "alt-shift-l" = "move right";

            "alt-ctrl-h" = "join-with left";
            "alt-ctrl-j" = "join-with down";
            "alt-ctrl-k" = "join-with up";
            "alt-ctrl-l" = "join-with right";

            "alt-1" = "workspace 1";
            "alt-2" = "workspace 2";
            "alt-3" = "workspace 3";
            "alt-4" = "workspace 4";
            "alt-5" = "workspace 5";
            "alt-6" = "workspace 6";
            "alt-7" = "workspace 7";
            "alt-8" = "workspace 8";
            "alt-9" = "workspace 9";

            "alt-shift-1" = "move-node-to-workspace 1";
            "alt-shift-2" = "move-node-to-workspace 2";
            "alt-shift-3" = "move-node-to-workspace 3";
            "alt-shift-4" = "move-node-to-workspace 4";
            "alt-shift-5" = "move-node-to-workspace 5";
            "alt-shift-6" = "move-node-to-workspace 6";
            "alt-shift-7" = "move-node-to-workspace 7";
            "alt-shift-8" = "move-node-to-workspace 8";
            "alt-shift-9" = "move-node-to-workspace 9";

            "alt-f" = "fullscreen";
          };
        };
      };
    }
  );
}
