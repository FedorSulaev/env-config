{ pkgs, lib, ... }:
{
  imports = [
    ./modules/github-module/gh.nix
    ./modules/zsh-module/zsh.nix
    ./modules/yazi-module/yazi.nix
    ./modules/nvim-module/neovim.nix
  ];

  _module.args.utility = import ./modules/utility.nix { lib = lib; };

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    tree-sitter
    lazygit
    lazydocker
    wget
    cargo
    rustc
    go
    php83
    php83Packages.composer
    julia-bin
    python312Packages.pynvim
  ];

  programs.bottom = {
    enable = true;
    settings = {
      flags = {
        color = "gruvbox";
        mem_as_value = true;
      };
    };
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.fzf.enable = true;
  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };
  programs.gradle.enable = true;

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
