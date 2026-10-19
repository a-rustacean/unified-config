{ self, inputs, ... }:
{
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = with self.nixosModules; [
      nixosConfiguration
      desktop
      development
      home
    ];
  };
}
