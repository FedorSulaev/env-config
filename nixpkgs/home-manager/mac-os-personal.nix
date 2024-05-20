{ config, pkgs, ... }:
{
  imports = [
    ./modules/tmux-module/tmux.nix
    ./modules/gh.nix
    ./modules/zsh-module/zsh.nix
    ./modules/nvim-module/neovim.nix
  ];

  home.homeDirectory = "/Users/fedorsulaev";
  home.username = "fedorsulaev";
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    bottom
    tree-sitter
    lazygit
    wget
    cargo
    rustc
    nodejs_20
  ];

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk17_headless;
  };
}
