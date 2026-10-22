{ ... }:
{
  flake.nixosModules.sddm-autologin =
    { ... }:
    {
      # TODO: no-hardcode
      services.displayManager = {
        autoLogin.enable = true;
        autoLogin.user = "dilshad";
      };
    };
}
