{
  flake.darwinModules.user =
    { pkgs, ... }:
    {
      users.users.dilshad = {
        name = "dilshad";
        home = "/Users/dilshad";
        shell = pkgs.zsh;
      };
    };
}
