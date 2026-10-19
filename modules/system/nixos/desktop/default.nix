{ self, ... }:
{
  flake.nixosModules.desktop =
    { ... }:
    let
      modules = with self.nixosModules; [
        core
        audio
        network
        nix-ld
        systemTheme
      ];
    in
    {
      imports = modules;
    };
}
