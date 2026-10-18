{
  flake.darwinModules.nix =
    { ... }:
    {
      nix = {
        enable = true;
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          trusted-users = [
            "root"
            "dilshad"
          ];
        };
      };

      nixpkgs.config.allowUnfree = true;
    };
}
