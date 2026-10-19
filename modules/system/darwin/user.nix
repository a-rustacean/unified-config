{ moduleWithSystem, ... }:
{
  flake.darwinModules.user = moduleWithSystem (
    { self', ... }:
    {
      users.users.dilshad = {
        name = "dilshad";
        home = "/Users/dilshad";
        shell = self'.packages.zsh;
      };
    }
  );
}
