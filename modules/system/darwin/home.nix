{ inputs, ... }:
{
  flake.darwinModules.home = {
    imports = [ inputs.home-manager.darwinModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = ".backup";
      users.dilshad.home.stateVersion = "26.05";
    };
  };
}
