{ config, lib, pkgs, hostSpec, ... }:
{
  imports = [ ../utility/host-spec.nix ];

  inherit hostSpec;

  services.ssh-agent.enable = true;

  home = {
    username = lib.mkDefault config.hostSpec.username;
    homeDirectory = lib.mkDefault config.hostSpec.home;
    stateVersion = lib.mkDefault "25.05";
    sessionPath = [
    ];
    sessionVariables = {
      FLAKE = "$HOME/env-config";
      SHELL = "zsh";
      TERM = "";
      TERMINAL = "";
      VISUAL = "nvim";
      EDITOR = "nvim";
      MANPAGER = "batman";
    };
    preferXdgDirectories = true;
  };
}
