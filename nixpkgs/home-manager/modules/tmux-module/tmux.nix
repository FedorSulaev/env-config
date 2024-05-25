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
      {
        plugin = dracula;
        extraConfig = ''
          # Metrics
          set -g @dracula-plugins 'cpu-usage ram-usage'

          # For preview rendering
          set -g allow-passthrough on
          set -ga update-environment TERM
          set -ga update-environment TERM_PROGRAM
        '';
      }
    ];
    extraConfig = ''
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      set -g status-position top
    '';
  };

  home.packages = with pkgs; [
    tmuxifier
  ];

  home.file.".tmux-layouts/envconfig.session.sh".source = ./tmux-session-envconfig.sh;
}
