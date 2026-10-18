{ moduleWithSystem, inputs, ... }:

let
  gitConfig = {
    user = {
      email = "a-rustacean@outlook.com";
      name = "Dilshad";
      signingKey = "95BBBA7922AE1CEC";
    };
    commit.gpgSign = true;
    init.defaultBranch = "main";
    tag.gpgSign = true;
  };

  module = moduleWithSystem (
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.gitui ];
    }
  );
in
{
  flake = {
    nixosModules.gitui = module;
    darwinModules.gitui = module;
  };

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

      theme = {
        selected_tab = "Reset";
        command_fg = palette.text.hex;
        selection_bg = palette.surface2.hex;
        selection_fg = palette.text.hex;
        cmdbar_bg = palette.mantle.hex;
        cmdbar_extra_lines_bg = palette.mantle.hex;
        disabled_fg = palette.overlay1.hex;
        diff_line_add = palette.green.hex;
        diff_line_delete = palette.red.hex;
        diff_file_added = palette.green.hex;
        diff_file_removed = palette.maroon.hex;
        diff_file_moved = palette.mauve.hex;
        diff_file_modified = palette.peach.hex;
        commit_hash = palette.lavender.hex;
        commit_time = palette.subtext1.hex;
        commit_author = palette.sapphire.hex;
        danger_fg = palette.red.hex;
        push_gauge_bg = palette.blue.hex;
        push_gauge_fg = palette.base.hex;
        tag_fg = palette.rosewater.hex;
        branch_fg = palette.teal.hex;
      };
    in
    {
      packages.gitui = inputs.wrappers.lib.wrapPackage (
        { ... }:
        {
          inherit pkgs;
          package = pkgs.gitui;
          flags."-t" = pkgs.writeText "theme.ron" (
            "(\n${
              lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: ''${name}: Some("${value}"),'') theme)
            }\n)"
          );
          env.GIT_CONFIG_GLOBAL = pkgs.writeText "gitconfig" (lib.generators.toGitINI gitConfig);
        }
      );
    };
}
