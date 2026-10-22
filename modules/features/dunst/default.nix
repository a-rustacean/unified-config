{ moduleWithSystem, inputs, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.dunst ];
    }
  );
in
{
  flake.nixosModules.dunst = module;

  perSystem =
    {
      pkgs,
      lib,
      inputs',
      ...
    }:
    let
      palette =
        (builtins.fromJSON (builtins.readFile "${inputs'.catppuccin.packages.palette}/palette.json"))
        .mocha.colors;

      boolToStr = v: if v then "yes" else "no";
      renderValue =
        v:
        if builtins.isBool v then
          boolToStr v
        else if builtins.isString v then
          v
        else
          toString v;
      iniSection = name: attrs: ''
        [${name}]
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "    ${k} = ${renderValue v}") attrs)}
      '';

      settings = {
        global = {
          monitor = 0;
          follow = "mouse";
          width = 300;
          height = 300;
          origin = "top-right";
          offset = "10x50";
          indicate_hidden = true;
          shrink = false;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          frame_width = 2;
          frame_color = palette.surface2.hex;
          separator_color = "frame";
          sort = true;
          font = "JetBrainsMono Nerd Font 10";
          line_height = 4;
          markup = "full";
          format = "<b>%s</b>\n%b";
          alignment = "left";
          show_age_threshold = 60;
          word_wrap = true;
          ellipsize = "middle";
          ignore_newline = false;
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = true;
          icon_position = "left";
          sticky_history = true;
          history_length = 20;
          browser = "/usr/bin/xdg-open";
          always_run_script = true;
          corner_radius = 8;
          ignore_dbusclose = false;
        };
        shortcuts = {
          close = "ctrl+space";
          close_all = "ctrl+shift+space";
          history = "ctrl+grave";
          context = "ctrl+shift+period";
        };
        urgency_low = {
          background = palette.surface0.hex;
          foreground = palette.text.hex;
          timeout = 10;
          highlight = palette.mauve.hex;
        };
        urgency_normal = {
          background = palette.surface0.hex;
          foreground = palette.text.hex;
          timeout = 10;
          highlight = palette.mauve.hex;
        };
        urgency_critical = {
          background = palette.red.hex;
          foreground = palette.text.hex;
          timeout = 0;
          highlight = palette.red.hex;
        };
      };
    in
    {
      packages.dunst =
        if pkgs.stdenv.hostPlatform.isLinux then
          inputs.wrappers.lib.wrapPackage (
            { ... }:
            {
              inherit pkgs;
              package = pkgs.dunst;
              flags."--config" = pkgs.writeText "dunstrc" (
                lib.concatStringsSep "\n" (lib.mapAttrsToList iniSection settings)
              );
            }
          )
        else
          pkgs.runCommand "dunst-unsupported"
            {
              meta = {
                platforms = lib.platforms.linux;
                badPlatforms = lib.platforms.darwin;
              };
            }
            ''
              echo "dunst is not supported on ${pkgs.stdenv.hostPlatform.system}" >&2
              exit 1
            '';
    };
}
