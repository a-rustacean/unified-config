{ moduleWithSystem, inputs, ... }:

let
  shellConfig = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    histSize = 10000;
  };

  overlay = self': {
    nixpkgs.overlays = [
      (final: prev: {
        zsh = self'.packages.zsh;
      })
    ];
  };

  nixosModule = moduleWithSystem (
    { pkgs, self', ... }:
    overlay self'
    // {
      programs.zsh = shellConfig // {
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
      };
      users.defaultUserShell = pkgs.zsh;
    }
  );

  darwinModule = moduleWithSystem (
    { self', ... }:
    overlay self'
    // {
      programs.zsh = shellConfig // {
        enableAutosuggestions = true;
        enableSyntaxHighlighting = true;
      };
    }
  );
in
{
  flake = {
    nixosModules.zsh = nixosModule;
    darwinModules.zsh = darwinModule;
  };

  perSystem =
    {
      pkgs,
      lib,
      self',
      inputs',
      ...
    }:
    let
      palette =
        (builtins.fromJSON (builtins.readFile "${inputs'.catppuccin.packages.palette}/palette.json"))
        .mocha.colors;
    in
    {
      packages = {
        zsh = inputs.wrappers.wrappers.zsh.wrap {
          inherit pkgs;
          runtimePkgs = [
            pkgs.carapace
            pkgs.devenv
            pkgs.fzf
          ];
          zshAliases = {
            ls = "${lib.getExe pkgs.lsd} -l";
            cat = lib.getExe pkgs.bat;
            man = "man -P \"${lib.getExe pkgs.bat} -p\"";
          };
          zshrc.content = ''
            source ${./devenv.zsh}

            if (( ''${+terminfo[smkx]} )) && (( ''${+terminfo[rmkx]} )); then
              function zle-line-init() { echoti smkx }
              function zle-line-finish() { echoti rmkx }
              zle -N zle-line-init
              zle -N zle-line-finish
            fi

            autoload -U compinit && compinit
            export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
            zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
            source <(${lib.getExe pkgs.carapace} _carapace)
            zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

            autoload -U select-word-style
            select-word-style bash

            autoload -U up-line-or-beginning-search down-line-or-beginning-search
            zle -N up-line-or-beginning-search
            zle -N down-line-or-beginning-search
            bindkey "^[OA" up-line-or-beginning-search
            bindkey "^[OB" down-line-or-beginning-search

            bindkey "^[[1;5C" forward-word
            bindkey "^[[1;5D" backward-word
            bindkey "^[[3;5~" kill-word
            bindkey "^H" backward-kill-word

            source <(${lib.getExe pkgs.fzf} --zsh)

            setopt NO_CASE_GLOB

            ${lib.getExe pkgs.any-nix-shell} zsh --info-right | source /dev/stdin

            export EDITOR=helix

            eval "$(${lib.getExe self'.packages.ohMyPosh} init zsh)"
            eval "$(${lib.getExe pkgs.devenv} hook zsh)"

            typeset -ag precmd_functions
            if (( ! ''${precmd_functions[(I)__devenv_reload_apply]} )); then
              precmd_functions+=(__devenv_reload_apply)
            fi
            if (( ! ''${precmd_functions[(I)__devenv_restore_path]} )); then
              precmd_functions+=(__devenv_restore_path)
            fi
          '';
        };
        ohMyPosh = inputs.wrappers.wrappers.oh-my-posh.wrap {
          inherit pkgs;
          configFile = pkgs.replaceVars ./config.toml {
            overlay1 = palette.overlay1.hex;
          };
        };
      };
    };
}
