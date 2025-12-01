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
}

