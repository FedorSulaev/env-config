{ config, pkgs, libs, ... }:
{
  imports = [
    ./modules/tmux-module/tmux.nix
    ./modules/gh.nix
    ./modules/zsh-module/zsh.nix
  ];

  home.homeDirectory = "/Users/fedorsulaev";
  home.username = "fedorsulaev";
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    bottom
    neovim
    tree-sitter
    lazygit
  ];

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
