{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    keyMode = "vi";
    prefix = "C-s";
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = sensible;
        extraConfig = ''
          set-option -g default-command zsh
          set -g detach-on-destroy off
        '';
      }
      yank
      {
        plugin = vim-tmux-navigator;
        extraConfig = ''
          bind-key h select-pane -L
          bind-key j select-pane -D
          bind-key k select-pane -U
          bind-key l select-pane -R
        '';
      }
      {
        plugin = gruvbox;
        extraConfig = ''
          set -g status-position top
          # For preview rendering
          set -g allow-passthrough on
          set -ga update-environment TERM
          set -ga update-environment TERM_PROGRAM

          set -g default-terminal 'tmux-256color'
          set-option -sa terminal-features ',*:RGB'
        '';
      }
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-save-interval '10'
          set -g @continuum-restore 'on'
        '';
      }
    ];
  };

  home.packages = with pkgs; [
    tmuxifier
  ];
}
