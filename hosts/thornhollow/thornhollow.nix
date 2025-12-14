{ inputs, config, pkgs, ... }:
{
  imports = [
    ../../common/utility/host-spec.nix
  ];

  hostSpec = {
    inherit (inputs.env-secrets.thornhollow) hostName username authorizedKeys hashedPassword rootHashedPassword;
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
        address = config.hostSpec.networking.hosts.thornhollow.address;
        prefixLength = config.hostSpec.networking.hosts.thornhollow.prefixLength;
      }];
    };
    defaultGateway = {
      address = config.hostSpec.networking.hosts.thornhollow.gatewayAddress;
      interface = "enp1s0";
    };
    nameservers = config.hostSpec.networking.hosts.thornhollow.nameservers;
    firewall.allowedTCPPorts = [
    ];
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

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = { };
  };

  system.stateVersion = "25.11";
}
