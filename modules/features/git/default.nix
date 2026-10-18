{ moduleWithSystem, inputs, ... }:

let
  settings = {
    user = {
      email = "a-rustacean@outlook.com";
      name = "Dilshad";
      signingKey = "95BBBA7922AE1CEC";
    };
    commit.gpgSign = true;
    init.defaultBranch = "main";
    tag.gpgSign = true;
  };

  nixosModule = moduleWithSystem (
    { pkgs, self', ... }:
    {
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryPackage = pkgs.pinentry-gnome3;
      };
      environment.systemPackages = [ self'.packages.git ];
    }
  );

  darwinModule = moduleWithSystem (
    { self', ... }:
    {
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
      environment.systemPackages = [ self'.packages.git ];
    }
  );
in
{
  flake = {
    nixosModules.git = nixosModule;
    darwinModules.git = darwinModule;
  };

  perSystem =
    { pkgs, lib, ... }:
    let
      lfsPath = lib.getExe pkgs.git-lfs;
    in
    {
      packages.git = inputs.wrappers.wrappers.git.wrap {
        inherit pkgs;
        runtimePkgs = [
          pkgs.gnupg
          pkgs.git-lfs
        ];
        settings = settings // {
          filter.lfs = {
            required = true;
            clean = "${lfsPath} clean -- %f";
            process = "${lfsPath} filter-process --skip";
            smudge = "${lfsPath} smudge --skip -- %f";
          };
        };
      };
    };
}
