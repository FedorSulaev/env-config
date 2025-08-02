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
    inherit (inputs.env-secrets.stonebark) hostName username;
    inherit (inputs.env-secrets) networking;
  };

  boot = {
    kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
    ];
    kernelModules = [ "vfio" "vfio_pci" "vfio_iommu_type1" "vfio_virqfd" ];
    loader.grub = {
      enable = true;
      version = 2;
      devices = [ "/dev/nvme0n1" ];
    };
    blacklistedKernelModules = [ "nouveau" "nvidia" ];
    extraModprobeConfig = ''
      options vfio-pci ids=10de:2484,10de:228b
    '';
  };

  services.qemuGuest.enable = true;
  virtualisation.libvirtd.enable = true;

  users = {
    users.fedorsulaev = {
      isNormalUser = true;
      name = config.hostSpec.username;
      home = config.hostSpec.home;
      extraGroups = [ "networkmanager" "wheel" ];
    };
    extraGroups.libvrtd.members = [ config.hostSpec.username ];
  };

  nix.settings.trusted-users = [ "root" config.hostSpec.username ];

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

  system.stateVersion = "25.05";
}
