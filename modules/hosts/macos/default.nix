{ self, inputs, ... }:
{
  flake.darwinConfigurations.macos = inputs.darwin.lib.darwinSystem {
    modules = with self.darwinModules; [
      system
      { nixpkgs.hostPlatform = "aarch64-darwin"; }
    ];
  };
}
