{ ... }:
{
  flake.nixosModules.systemTheme =
    { self, ... }:
    {
      imports = [ self.nixosModules.catppuccinGtk ];
    };
}
