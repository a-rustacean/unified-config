{ moduleWithSystem, inputs, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.fzf ];
    }
  );
in
{
  flake.nixosModules.fzf = module;

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

      renderValue =
        v:
        if builtins.isBool v then
          ""
        else if builtins.isString v then
          v
        else
          toString v;

      renderOpt =
        name: value:
        if builtins.isAttrs value then
          let
            parts = lib.mapAttrsToList (k: v: "${k}:${renderValue v}") value;
          in
          "--${name}=${lib.concatStringsSep "," parts}"
        else if builtins.isBool value then
          lib.optionalString value "--${name}"
        else
          "--${name}=${renderValue value}";

      settings = {
        color = {
          bg = "-1";
          fg = palette.text.hex;
          header = palette.red.hex;
          "bg+" = palette.surface0.hex;
          "fg+" = palette.text.hex;
          "hl+" = palette.red.hex;
          prompt = palette.mauve.hex;
          border = palette.surface0.hex;
          info = palette.surface2.hex;
          spinner = palette.pink.hex;
          pointer = palette.mauve.hex;
          marker = palette.pink.hex;
          hl = palette.red.hex;
          gutter = "-1";
        };
        layout = "reverse";
        border = "rounded";
        height = "40%";
      };

      fzfOpts = lib.concatStringsSep " " (lib.mapAttrsToList renderOpt settings);
    in
    {
      packages.fzf = inputs.wrappers.lib.wrapPackage (
        { ... }:
        {
          inherit pkgs;
          package = pkgs.fzf;
          env = lib.optionalAttrs (fzfOpts != "") {
            FZF_DEFAULT_OPTS = fzfOpts;
          };
        }
      );
    };
}
