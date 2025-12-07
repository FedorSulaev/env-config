{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    keyMode = "vi";
    prefix = "C-s";
    extraConfig = ''
      set -g default-command "$SHELL -l"
      bind-key "T" run-shell "sesh connect \"$(
        sesh list --icons | fzf-tmux -p 80%,70% \
          --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
          --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
          --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
          --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
          --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
          --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
          --preview-window 'right:55%' \
          --preview 'sesh preview {}'
      )\""
    '';
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = sensible;
        extraConfig = ''
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

  # Sesh dependencies
  programs.fzf = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
  };

  programs.zsh = {
    initContent = ''
      function sesh-sessions() {
        {
          exec </dev/tty
          exec <&1
          local session
          session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
          zle reset-prompt > /dev/null 2>&1 || true
          [[ -z "$session" ]] && return
          sesh connect $session
        }
      }
    '';
  };

  home.packages = with pkgs;
    [
      tmuxifier
      sesh
    ];
}
