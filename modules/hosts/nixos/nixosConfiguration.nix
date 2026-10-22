{ self, lib, ... }:
{
  flake.nixosModules.nixosConfiguration =
    { ... }:
    {
      imports = [
        self.nixosModules.hardwareConfig
        self.nixosModules.vm
      ];

      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
      networking.hostName = "nixos";
      networking.firewall.allowedTCPPorts = [
        80
        443
        8080
        8000
      ];
    };
}
