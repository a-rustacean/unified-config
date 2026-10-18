{ moduleWithSystem, inputs, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.opencode ];
    }
  );
in
{
  flake = {
    nixosModules.opencode = module;
    darwinModules.opencode = module;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.opencode = inputs.wrappers.wrappers.opencode.wrap {
        inherit pkgs;
        runtimePkgs = with pkgs; [
          typescript-language-server
          vscode-langservers-extracted
          bash-language-server
          lua-language-server
          nixd
          just-lsp
          taplo
        ];
        settings = {
          lsp = true;
        };
        tui-settings = {
          theme = "catppuccin";
        };
      };
    };
}
