{ pkgs, ... }:
{
  imports = [
    ./common.nix
  ];

  home.packages = with pkgs; [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    wezterm
  ];

  home.homeDirectory = "/Users/fedorsulaev";
  home.username = "fedorsulaev";

  home.file.".wezterm.lua".source = ./wezterm.lua;

  fonts.fontconfig.enable = true;
}
