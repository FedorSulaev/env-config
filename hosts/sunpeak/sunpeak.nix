{ inputs, config, pkgs, ... }:
{
  imports = [
    ../../common/utility/host-spec.nix
  ];

  hostSpec = {
    inherit (inputs.env-secrets.sunpeak) hostName username authorizedKeys hashedPassword rootHashedPassword;
    inherit (inputs.env-secrets) networking;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        PubkeyAuthentication = true;
      };
    };
  };

  networking = {
    hostName = config.hostSpec.hostName;
    useNetworkd = true;
    interfaces.enp1s0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = config.hostSpec.networking.hosts.sunpeak.address;
        prefixLength = config.hostSpec.networking.hosts.sunpeak.prefixLength;
      }];
    };
    defaultGateway = {
      address = config.hostSpec.networking.hosts.sunpeak.gatewayAddress;
      interface = "enp1s0";
    };
    nameservers = config.hostSpec.networking.hosts.stonebark.nameservers;
  };

  users = {
    users.fedorsulaev = {
      isNormalUser = true;
      name = config.hostSpec.username;
      home = config.hostSpec.home;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = config.hostSpec.authorizedKeys;
      hashedPassword = config.hostSpec.hashedPassword;
    };
    users.root = {
      hashedPassword = config.hostSpec.rootHashedPassword;
    };
  };

  nix.settings = {
    trusted-users = [ "root" config.hostSpec.username ];
  };

  time.timeZone = "Europe/Bucharest";

  environment.systemPackages = with pkgs; [
    vim
    cloud-utils
  ];

  system.stateVersion = "25.05";
}
