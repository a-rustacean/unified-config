{
  inputs,
  pkgs,
  lightFlavor ? "mocha",
  darkFlavor ? "mocha",
  accentColor ? "mauve",
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  userstyles = inputs.catppuccin-userstyles.outPath;
  stylusPkg = inputs.firefox-extensions-declarative.packages.${system}.stylus-declarative;

  mergedCss =
    pkgs.runCommand "catppuccin-userstyles.user.css"
      {
        nativeBuildInputs = [
          pkgs.nodejs
          pkgs.lessc
        ];
      }
      ''
        node ${./merge-userstyles.mjs} \
          ${userstyles}/styles \
          ${userstyles}/lib/std/v1.less \
          ${pkgs.lessc}/bin/lessc \
          $out \
          ${lightFlavor} \
          ${darkFlavor} \
          ${accentColor}
      '';

  xpi = pkgs.runCommand "stylus-declarative.xpi" { } ''
    cp ${stylusPkg}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}.xpi $out
  '';
in
{
  inherit mergedCss xpi;
}
