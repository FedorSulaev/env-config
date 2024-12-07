{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    keyMode = "vi";
    prefix = "C-s";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      vim-tmux-navigator
    ];
    extraConfig = ''
      set-option -g default-command zsh

      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      set -g status-position top

      # For preview rendering
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      set -g default-terminal 'tmux-256color'
      set-option -sa terminal-features ',*:RGB'
    '';
  };

  home.packages = with pkgs; [
    tmuxifier
  ];
}
