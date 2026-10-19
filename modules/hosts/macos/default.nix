{ self, inputs, ... }:
{
  flake.darwinConfigurations.macos = inputs.darwin.lib.darwinSystem {
    modules = with self.darwinModules; [
      system
      development
      gaming
      aerospace
      home
      { nixpkgs.hostPlatform = "aarch64-darwin"; }
    ];
  };
}
