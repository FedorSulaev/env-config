{ pkgs, ... }:
{
  imports = [
    ./../common/home-manager/common.nix
    ./../common/home-manager/modules/tmux-module/tmux-breezora.nix
  ];

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    wezterm
    postgresql
    exercism
    nixos-anywhere
    qemu
  ];

  home.homeDirectory = "/Users/fedorsulaev";
  home.username = "fedorsulaev";

  home.file.".wezterm.lua".source = ./../common/home-manager/modules/wezterm.lua;

  fonts.fontconfig.enable = true;
}
