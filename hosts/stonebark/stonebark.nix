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
    inherit (inputs.env-secrets.stonebark) hostName username authorizedKeys;
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

  virtualisation.libvirtd.enable = true;

  users = {
    users.fedorsulaev = {
      isNormalUser = true;
      name = config.hostSpec.username;
      home = config.hostSpec.home;
      extraGroups = [ "networkmanager" "wheel" ];
      openssh.authorizedKeys.keys = config.hostSpec.authorizedKeys;
    };
    extraGroups.libvrtd.members = [ config.hostSpec.username ];
  };

  nix.settings = {
    trusted-users = [ "root" config.hostSpec.username ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  networking = {
    hostName = config.hostSpec.hostName;
    networkmanager.enable = true;
    interfaces = {
      enp5s0 = {
        useDHCP = false;
        ipv4.addresses = [{
          address = config.hostSpec.networking.hosts.stonebark.address;
          prefixLength = config.hostSpec.networking.hosts.stonebark.prefixLength;
        }];
      };
    };
    defaultGateway = {
      address = config.hostSpec.networking.hosts.stonebark.gatewayAddress;
      interface = "enp5s0";
    };
    nameservers = config.hostSpec.networking.hosts.stonebark.nameservers;
  };

  time.timeZone = "Europe/Bucharest";

  system.stateVersion = "25.05";
}
