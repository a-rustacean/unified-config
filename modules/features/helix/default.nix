{ moduleWithSystem, inputs, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.helix ];
    }
  );
in
{
  flake = {
    nixosModules.helix = module;
    darwinModules.helix = module;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.helix = inputs.wrappers.wrappers.helix.wrap {
        inherit pkgs;
        runtimePkgs = with pkgs; [
          prettier
          typescript-language-server
          vscode-langservers-extracted
          bash-language-server
          lua-language-server
          nixd
          just-lsp
          taplo
        ];
        settings = {
          theme = "catppuccin_mocha";
          editor = {
            line-number = "relative";
            true-color = true;
            rulers = [
              80
              100
            ];
            cursor-shape.insert = "bar";
            file-picker.hidden = false;
            soft-wrap.enable = true;

            statusline = {
              left = [
                "mode"
                "spinner"
                "spacer"
                "spacer"
                "version-control"
              ];
              center = [
                "file-base-name"
                "file-modification-indicator"
              ];
              right = [
                "diagnostics"
                "selections"
                "position"
                "file-encoding"
                "file-line-ending"
                "file-type"
              ];
              separator = "|";
              mode.normal = "NOR";
              mode.insert = "INS";
              mode.select = "SEL";
            };

            lsp = {
              enable = true;
              display-messages = true;
              display-inlay-hints = true;
            };

            whitespace.render = {
              space = "all";
              nbsp = "all";
              tab = "all";
              newline = "none";
              tabpad = "all";
            };
          };
        };
        languages = {
          language = [
            {
              name = "html";
              formatter = {
                command = "${pkgs.prettier}/bin/prettier";
                args = [
                  "--parser"
                  "html"
                ];
              };
              auto-format = true;
            }
            {
              name = "css";
              formatter = {
                command = "${pkgs.prettier}/bin/prettier";
                args = [
                  "--parser"
                  "css"
                ];
              };
              auto-format = true;
            }
            {
              name = "javascript";
              formatter = {
                command = "${pkgs.prettier}/bin/prettier";
                args = [
                  "--parser"
                  "javascript"
                ];
              };
              auto-format = true;
            }
            {
              name = "typescript";
              formatter = {
                command = "${pkgs.prettier}/bin/prettier";
                args = [
                  "--parser"
                  "typescript"
                ];
              };
              auto-format = true;
            }
            {
              name = "tsx";
              formatter = {
                command = "${pkgs.prettier}/bin/prettier";
                args = [
                  "--parser"
                  "typescript"
                ];
              };
              auto-format = true;
            }
          ];
        };
      };
    };
}
