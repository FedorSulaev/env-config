{ inputs, pkgs, lib, config, ... }:
{
  imports = lib.flatten [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    #"${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
    # This is overkill but I want my core home level utils if I need to use the iso environment for recovery purpose
    inputs.home-manager.nixosModules.home-manager
    ../../common/utility/host-spec.nix
    ../../common/users/user-primary.nix
    ../../common/users/temp-password.nix
  ];

  hostSpec = {
    # ISO host settings
    inherit (inputs.env-secrets) iso;

    # Generic networking settings
    inherit (inputs.env-secrets) networking;
  };
}
