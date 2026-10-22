{ ... }:
{
  flake.nixosModules.vm =
    { ... }:
    {
      boot.kernelModules = [
        "9p"
        "9pnet_virtio"
      ];
      fileSystems."/mnt/share" = {
        device = "share";
        fsType = "9p";
        options = [
          "trans=virtio"
          "version=9p2000.L"
          "msize=104857600"
          "cache=loose"
          "nofail"
          "x-systemd.automount"
        ];
      };
      environment.sessionVariables = {
        LIBGL_ALWAYS_SOFTWARE = "1";
      };
    };
}
