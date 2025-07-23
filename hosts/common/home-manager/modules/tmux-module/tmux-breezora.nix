{ ... }:
{
  imports = [
    ./tmux-common.nix
  ];

  home.file.".tmux-layouts/envconfig.session.sh".source = ./tmux-session-envconfig.sh;
  home.file.".tmux-layouts/selfhost.session.sh".source = ./tmux-session-selfhost.sh;
}
