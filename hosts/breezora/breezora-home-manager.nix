{ pkgs, ... }:
{
  imports = [
    ./../common/home-manager/common.nix
    ./../common/home-manager/modules/tmux-module/tmux-breezora.nix
  ];

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    alacritty
    postgresql
    exercism
    nixos-anywhere
    qemu
    awscli2
  ];

  home.homeDirectory = "/Users/fedorsulaev";
  home.username = "fedorsulaev";

  home.file.".config/alacritty/alacritty.toml".source =
    ./../common/home-manager/modules/alacritty.toml;

  fonts.fontconfig.enable = true;
}
