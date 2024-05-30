{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    enableAutosuggestions = true;
    initExtra = "[[ ! $(command -v nix) && -e ' /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ' ]] && source ' /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh '";
    shellAliases = {
      l = "eza -l -a";
      lt = "eza -l -a --tree --level=2";
    };
  };
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$character";
      right_format = "$all";
      palette = "gruvbox_dark";
      palettes = {
        gruvbox_dark = {
          color_fg0 = "#fbf1c7";
          color_bg1 = "#3c3836";
          color_bg3 = "#665c54";
          color_blue = "#458588";
          color_aqua = "#689d6a";
          color_green = "#98971a";
          color_orange = "#d65d0e";
          color_purple = "#b16286";
          color_red = "#cc241d";
          color_yellow = "#d79921";
        };
      };
      os = {
        disabled = false;
        symbols = {
          Windows = "󰍲";
          Ubuntu = "󰕈";
          SUSE = "";
          Raspbian = "󰐿";
          Mint = "󰣭";
          Macos = "󰀵";
          Manjaro = "";
          Linux = "󰌽";
          Gentoo = "󰣨";
          Fedora = "󰣛";
          Alpine = "";
          Amazon = "";
          Android = "";
          Arch = "󰣇";
          Artix = "󰣇";
          CentOS = "";
          Debian = "󰣚";
          Redhat = "󱄛";
          RedHatEnterprise = "󱄛";
        };
      };

    };
  };
}
