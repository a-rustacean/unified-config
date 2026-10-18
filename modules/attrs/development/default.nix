{ self, ... }:

let
  packages =
    pkgs: with pkgs; [
      # Font
      nerd-fonts.jetbrains-mono
      # Tools
      typos
      xclip
      htop
      rsync
      util-linux
      ripgrep
      hexyl
      tree
      gnumake
      gcc
      cmake
      ffmpeg
      wget
      inetutils
      openblas
      llvmPackages_20.clang-tools
      llvm
      lld
      protobuf
      xz
      jq
      zip
      unzip
      tarlz
      # JS/TS
      nodejs_24
      typescript
      bun
      pnpm
      # Rust
      rustup
      # Python
      ruff
      python313
      uv
      # Git
      gh
      # Zig
      zig_0_16
      zls_0_16
    ];
in
{
  flake.nixosModules.development =
    { pkgs, ... }:
    {
      imports = with self.nixosModules; [
        btop
        fastfetch
        fetch
        git
        gitui
        ghostty
        zsh
      ];
      environment.systemPackages = packages pkgs;
    };

  flake.darwinModules.development =
    { pkgs, ... }:
    {
      imports = with self.darwinModules; [
        btop
        fastfetch
        fetch
        git
        gitui
        ghostty
        zsh
      ];
      environment.systemPackages = packages pkgs;
    };
}
