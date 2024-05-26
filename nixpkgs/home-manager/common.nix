{ pkgs, ... }:
{
  imports = [
    ./modules/tmux-module/tmux.nix
    ./modules/gh.nix
    ./modules/zsh.nix
    ./modules/nvim-module/neovim.nix
  ];

  home.packages = with pkgs; [
    yazi
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
