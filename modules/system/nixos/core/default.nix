{ self, ... }:
{
  flake.nixosModules.core =
    { ... }:
    let
      modules = with self.nixosModules; [
        bootloader
        nix
        locale
        user
      ];
    in
    {
      imports = modules;
      services.openssh.enable = true;
      environment.systemPackages = [ ];
      system.stateVersion = "26.05";
    };
}
