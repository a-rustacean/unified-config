{ self, ... }:
{
  flake.nixosModules.gaming =
    { ... }:
    {
      imports = with self.nixosModules; [
        prismlauncher
      ];
    };

  flake.darwinModules.gaming =
    { ... }:
    {
      imports = with self.darwinModules; [
        prismlauncher
      ];
    };
}
