{
  flake = {
    nixosModules.sops =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.sops ];
        environment.variables.SOPS_AGE_KEY_FILE = "/home/dilshad/.config/sops/age/keys.txt";
      };

    darwinModules.sops =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.sops ];
        environment.variables.SOPS_AGE_KEY_FILE = "/Users/dilshad/.config/sops/age/keys.txt";
      };
  };
}
