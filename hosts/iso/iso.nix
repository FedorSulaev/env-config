{ inputs, pkgs, lib, config, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    #"${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
    # This is overkill but I want my core home level utils if I need to use the iso environment for recovery purpose
    inputs.home-manager.nixosModules.home-manager
    ../../common/utility/host-spec.nix
    ../../common/users/user-primary.nix
  ];

  hostSpec = {
    # ISO host settings
    inherit (inputs.env-secrets.iso) hostName username;

    # Generic networking settings
    inherit (inputs.env-secrets) networking;

    # Git ids
    inherit (inputs.env-secrets) github;
  };

  users.users.${config.hostSpec.username} = {
    isNormalUser = true;
    inherit (inputs.env-secrets.iso) hashedPassword;
    extraGroups = [ "wheel" ];
  };

  # root's ssh key are mainly used for remote deployment
  users.extraUsers.root = {
    inherit (config.users.users.${config.hostSpec.username}) hashedPassword;
    openssh.authorizedKeys.keys =
      config.users.users.${config.hostSpec.username}.openssh.authorizedKeys.keys;
  };
}
