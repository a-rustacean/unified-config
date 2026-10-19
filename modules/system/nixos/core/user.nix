{ moduleWithSystem, ... }:
{
  flake.nixosModules.user = moduleWithSystem (
    { self', ... }:
    {
      users.users.dilshad = {
        isNormalUser = true;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        packages = [ ];
        shell = self'.packages.zsh;
        initialPassword = "dilshad";
      };
    }
  );
}
