{ pkgs, ... }:
{
  home.packages = with pkgs; [
    file
  ];

  programs.jq = {
    enable = true;
  };
}
