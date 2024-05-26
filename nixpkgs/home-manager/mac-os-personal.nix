{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wezterm
  ];

  home.homeDirectory = "/Users/fedorsulaev";
  home.username = "fedorsulaev";
  home.stateVersion = "23.11";

  home.file.".wezterm.lua".source = ./wezterm.lua;
}
