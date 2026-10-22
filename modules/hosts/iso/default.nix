{ self, inputs, ... }:
{
  perSystem =
    {
      system,
      pkgs,
      lib,
      ...
    }:
    {
      packages.iso =
        if pkgs.stdenv.hostPlatform.isLinux then
          let
            iso = inputs.nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                (inputs.nixpkgs.outPath + "/nixos/modules/installer/cd-dvd/iso-image.nix")

                self.nixosModules.desktop
                self.nixosModules.development
                self.nixosModules.home

                {
                  # Boot as EFI and from a USB stick, in addition to BIOS.
                  isoImage.makeEfiBootable = true;
                  isoImage.makeUsbBootable = true;

                  isoImage.edition = "hyprland";
                  isoImage.appendToMenuLabel = " Live System";

                  # Live media must work on arbitrary hardware.
                  hardware.enableAllHardware = true;
                }
              ];
            };
          in
          iso.config.system.build.isoImage
        else
          pkgs.runCommand "iso-unsupported"
            {
              meta = {
                platforms = lib.platforms.linux;
                badPlatforms = lib.platforms.darwin;
              };
            }
            ''
              echo "iso is not supported on ${pkgs.stdenv.hostPlatform.system}" >&2
              exit 1
            '';
    };
}
