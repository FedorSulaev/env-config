{ inputs, config, pkgs, lib, ... }:
{
  imports = [
    ../../common/utility/host-spec.nix
    ./../common/home-manager/modules/tmux-module/tmux-common.nix
    ./../common/home-manager/common.nix
  ];

  hostSpec = {
    inherit (inputs.env-secrets.sunpeak) username;
  };

  home.username = config.hostSpec.username;
  home.homeDirectory = "/home/${config.hostSpec.username}";
  home.stateVersion = "25.05";
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "ctrl:nocaps" ];
    };
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;
    profiles.default = {
      isDefault = true;
      # --- imported profile
      id = 0;
      name = "default";
      path = "ep7cfvhx.default";
      # ---
      settings = {
        "browser.tabs.verticalTabs" = true;
        "browser.tabs.verticalTabs.position" = "right";
        "browser.startup.page" = 3;
        "browser.sessionstore.resume_session_once" = false;
        "browser.ctrlTab.sortByRecentlyUsed" = true;
      };
    };
  };

  home.packages = with pkgs; [
    gnome-tweaks
    gnomeExtensions.appindicator
    blanket
    bitwarden-desktop
    bitwarden-cli
    nerd-fonts.jetbrains-mono
    alacritty
    steam
    libreoffice
    evolution
    evolution-ews
    anki-bin
    mpv
  ];

  home.file.".config/alacritty/alacritty.toml".source =
    ./../common/home-manager/modules/alacritty-gnome.toml;
}
