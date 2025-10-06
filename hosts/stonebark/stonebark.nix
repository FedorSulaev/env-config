{ inputs, lib, config, pkgs, ... }:
{
  imports = [
    ../../common/utility/host-spec.nix

    # ===== Hardware =====
    ./hardware-configuration.nix
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-pc-ssd
  ];

  hostSpec = {
    inherit (inputs.env-secrets.stonebark) hostName username authorizedKeys hashedPassword rootHashedPassword;
    inherit (inputs.env-secrets) networking;
  };

  boot = {
    kernel.sysctl."vm.swappiness" = 10;
    kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
    ];
    kernelModules = [ "vfio" "vfio_pci" "vfio_iommu_type1" "vfio_virqfd" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    blacklistedKernelModules = [ "nouveau" "nvidia" ];
    extraModprobeConfig = ''
      options vfio-pci ids=10de:2484,10de:228b
    '';
  };

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
    bridges.br0.interfaces = [ "enp5s0" ];
    interfaces.br0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = config.hostSpec.networking.hosts.stonebark.address;
        prefixLength = config.hostSpec.networking.hosts.stonebark.prefixLength;
      }];
    };
    defaultGateway = {
      address = config.hostSpec.networking.hosts.stonebark.gatewayAddress;
      interface = "br0";
    };
    nameservers = config.hostSpec.networking.hosts.stonebark.nameservers;
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = false;
    networks = {
      br0 = {
        name = "br0";
        mode = "bridge";
        bridge = "br0";
        autostart = true;
      };
    };
  };

  users = {
    users.fedorsulaev = {
      isNormalUser = true;
      name = config.hostSpec.username;
      home = config.hostSpec.home;
      extraGroups = [ "networkmanager" "wheel" ];
      openssh.authorizedKeys.keys = config.hostSpec.authorizedKeys;
      hashedPassword = config.hostSpec.hashedPassword;
    };
    users.root = {
      hashedPassword = config.hostSpec.rootHashedPassword;
    };
    extraGroups.libvrtd.members = [ config.hostSpec.username ];
  };

  nix.settings = {
    trusted-users = [ "root" config.hostSpec.username ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  time.timeZone = "Europe/Bucharest";

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  system.stateVersion = "25.05";
}
