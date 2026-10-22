{ moduleWithSystem, inputs, ... }:

let
  module = moduleWithSystem (
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.cava ];
    }
  );
in
{
  flake.nixosModules.cava = module;

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

      # cava reads colors via iniparser, which requires hex values to be quoted
      isHex = s: builtins.isString s && builtins.substring 0 1 s == "#";
      quoteHex = v: if isHex v then "'${v}'" else toString v;
      iniKeyValue = name: value: "${name} = ${quoteHex value}";
      iniSection = name: attrs: ''
        [${name}]
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList iniKeyValue attrs)}
      '';
    in
    {
      packages.cava =
        if pkgs.stdenv.hostPlatform.isLinux then
          inputs.wrappers.lib.wrapPackage (
            { ... }:
            {
              inherit pkgs;
              package = pkgs.cava;
              flags."-p" = pkgs.writeText "cava-config" (
                lib.concatStringsSep "\n" (
                  lib.mapAttrsToList iniSection {
                    color = {
                      gradient = 1;
                      gradient_color_1 = palette.sky.hex;
                      gradient_color_2 = palette.blue.hex;
                      gradient_color_3 = palette.mauve.hex;
                      gradient_color_4 = palette.pink.hex;
                      gradient_color_5 = palette.red.hex;
                    };
                  }
                )
              );
            }
          )
        else
          pkgs.runCommand "cava-unsupported"
            {
              meta = {
                platforms = lib.platforms.linux;
                badPlatforms = lib.platforms.darwin;
              };
            }
            ''
              echo "cava is not supported on ${pkgs.stdenv.hostPlatform.system}" >&2
              exit 1
            '';
    };
}
