{ inputs, config, pkgs, lib, ... }:
{
  imports = [
    ../../common/utility/host-spec.nix
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

  programs.kitty.enable = true;

  programs.wofi.enable = true;

  home.packages = with pkgs; [
    gnome-tweaks
    gnomeExtensions.appindicator
    git
    neovim
    htop
    ripgrep
    fd
    jq
    firefox
    blanket
    bitwarden-desktop
    bitwarden-cli
  ];

  programs.zsh = {
    enable = true;
    oh-my-zsh.enable = true;
    oh-my-zsh.theme = "agnoster";
  };
}

