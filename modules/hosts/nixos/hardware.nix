{ ... }:
{
  flake.nixosModules.hardwareConfig =
    {
      config,
      lib,
      pkgs,
      modulesPath,
      ...
    }:

    {
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "virtio_pci"
        "usbhid"
        "usb_storage"
        "sr_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/91d992a5-f5c5-4322-89d7-6e7fc014c3e3";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/D9D1-24F9";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [
        { device = "/dev/disk/by-uuid/5be7805a-9aac-472e-b265-e33a4cec411a"; }
      ];

      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    };
}
