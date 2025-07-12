{ pkgs, lib, inputs, config, ... }:
let
  sopsFolder = builtins.toString inputs.env-secrets + "/sops";
in
{
  sops = {
    defaultSopsFile = "${sopsFolder}/${config.hostSpec.hostName}.enc.yaml";
    validateSopsFiles = false;
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };

  sops.secrets = lib.mkMerge [
    {
      "keys/age" = {
        owner = config.users.users.${config.hostSpec.username}.name;
        inherit (config.users.users.${config.hostSpec.username}) group;
        path = "${config.hostSpec.home}/.config/sops/age/keys.txt";
      };
    }
  ];
}
