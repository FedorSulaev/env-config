{ ... }:
{
  imports = [
    ./common.nix
  ];
  home.homeDirectory = "/home/fssulaev";
  home.username = "fssulaev";
  home.sessionPath = [
    "$HOME/.toolbox/bin"
  ];
}
