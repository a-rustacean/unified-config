{ self, ... }:
{
  flake.nixosModules.systemTheme =
    { ... }:
    {
      imports = [ self.nixosModules.catppuccinGtk ];
    };
}
