{ inputs, pkgs, config, lib, ... }:
let
  hostSpec = config.hostSpec;
  # TODO: put in secrets
  authorizedKeys = [ ./authorized-key.pub ];
in
{
  users.users.${hostSpec.username} = {
    name = hostSpec.username;
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = lib.lists.forEach authorizedKeys (key: builtins.readFile key);
  };

  programs.zsh.enable = true;
  environment.systemPackages = [
    pkgs.just
    pkgs.rsync
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit pkgs inputs;
      hostSpec = config.hostSpec;
    };
    users.${hostSpec.username}.imports =
      [
        (
          { config, ... }:
          import ./../../hosts/${hostSpec.hostName}/users/${hostSpec.username}.nix {
            inherit
              pkgs
              inputs
              config
              lib
              hostSpec
              ;
          }
        )
      ];
  };
}
