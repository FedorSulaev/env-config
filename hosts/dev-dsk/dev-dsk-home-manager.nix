{ ... }:
{
  imports = [
    ./../common/home-manager/common.nix
    ./../common/home-manager/modules/tmux-module/tmux-dev-dsk.nix
  ];
  home.homeDirectory = "/home/fssulaev";
  home.username = "fssulaev";
  home.sessionPath = [
    "$HOME/.toolbox/bin"
  ];
}
