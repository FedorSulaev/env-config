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
    go
    php83
    php83Packages.composer
    julia-bin
    python311Packages.pynvim
  ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.fzf.enable = true;
  programs.eza = {
    enable = true;
    icons = true;
    git = true;
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk17_headless;
  };
}
