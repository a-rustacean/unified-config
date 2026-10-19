{ inputs, ... }:
{
  flake.nixosModules.home = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = ".backup";
      users.dilshad.home.stateVersion = "26.05";
    };
  };
}
