{ pkgs, ... }:
{
  imports = [
    ./common.nix
    ./modules/tmux-module/tmux-mac-os-personal.nix
  ];

  home.packages = with pkgs; [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    wezterm
    postgresql
    exercism
    nixos-anywhere
  ];

  home.homeDirectory = "/Users/fedorsulaev";
  home.username = "fedorsulaev";

  home.file.".wezterm.lua".source = ./wezterm.lua;

  fonts.fontconfig.enable = true;
}
