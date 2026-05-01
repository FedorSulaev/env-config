{ pkgs, lib, inputs, ... }:
{
  imports = [
    ./modules/github-module/gh.nix
    ./modules/zsh-module/zsh.nix
    ./modules/yazi-module/yazi.nix
    ./modules/nvim-module/neovim.nix
  ];

  _module.args.utility = import ./modules/utility.nix { lib = lib; };

  home.stateVersion = "26.05";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  home.packages = with pkgs; [
    tree-sitter
    lazygit
    lazydocker
    wget
    cargo
    rustc
    go
    yq-go
    php83
    php83Packages.composer
    julia-lts
    python313Packages.pynvim
    nixos-generators
    nixos-rebuild
    sops
    age
    ssh-to-age
    mkpasswd
    just
    curl
    rsync
  ];

  programs = {
    git.enable = true;

    bottom = {
      enable = true;
      settings = {
        flags = {
          color = "gruvbox";
          mem_as_value = true;
        };
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    fzf.enable = true;

    eza = {
      enable = true;
      icons = "auto";
      git = true;
    };

    gradle.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
