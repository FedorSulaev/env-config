{ inputs, config, pkgs, ... }:
{
  imports = [
    ../../common/utility/host-spec.nix
  ];

  hostSpec = {
    inherit (inputs.env-secrets.riverfall) hostName username authorizedKeys hashedPassword rootHashedPassword;
    inherit (inputs.env-secrets) networking;
  };

  virtualisation.qemu.options = [
    "-m"
    "2048"
    "-device"
    "virtio-net-pci,netdev=net0"
    "-netdev"
    "bridge,id=net0,br=br0"
  ];

  services = {
    qemuGuest.enable = true;
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
    interfaces.eth0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = config.hostSpec.networking.hosts.riverfall.address;
        prefixLength = config.hostSpec.networking.hosts.riverfall.prefixLength;
      }];
    };
    defaultGateway = {
      address = config.hostSpec.networking.hosts.riverfall.gatewayAddress;
      interface = "eth0";
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
  ];

  system.stateVersion = "25.05";
}
