{ pkgs, ... }:
{
  imports = [
    ./common.nix
  ];
  home.packages = with pkgs; [
    wezterm
  ];

  home.homeDirectory = "/Users/fedorsulaev";
  home.username = "fedorsulaev";

  home.file.".wezterm.lua".source = ./wezterm.lua;
}
