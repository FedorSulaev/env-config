{ inputs, lib, config, pkgs, ... }:
{
  imports = [
    ../../common/utility/host-spec.nix

    # ===== Hardware =====
    ./hardware-configuration.nix
    ./libvirt/pools.nix
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
      "isolcpus=2-11,14-23"
      "nohz_full=2-11,14-23"
      "irqaffinity=0,12"
      "video=efifb:off"
      "nomodeset"
      # GPU, GPU audio, USB
      "vfio-pci.ids=10de:2484,10de:228b,1022:149c"
    ];
    kernelModules = [
      "vfio"
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio_virqfd"
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    blacklistedKernelModules = [
      "nouveau"
      "nvidia"
      "btusb"
    ];
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
    resolved = {
      llmnr = "false";
    };
  };

  virtualisation.libvirt = {
    enable = true;
    verbose = true;
    connections."qemu:///system" = {
      domains =
        (import ./libvirt/domains/riverfall-vm.nix { inherit inputs; })
        ++ (import ./libvirt/domains/sunpeak-vm.nix { inherit inputs; })
        ++ (import ./libvirt/domains/thornhollow-vm.nix { inherit inputs; });
    };
  };
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "start";
    onShutdown = "shutdown";
    qemu = {
      swtpm.enable = true; # virtual TPM for Windows/modern OS
    };
    allowedBridges = [ "br0" ];
  };

  networking = {
    networkmanager.enable = lib.mkForce false;
    hostName = config.hostSpec.hostName;
    useDHCP = false;
    useNetworkd = true;
  };

  systemd = {
    network = {
      enable = true;
      netdevs.br0 = {
        enable = true;
        netdevConfig = {
          Kind = "bridge";
          Name = "br0";
        };
      };
      networks = {
        br0-lan = {
          enable = true;
          matchConfig = {
            Name = [ "br0" ];
          };
          networkConfig = {
            Bridge = "br0";
          };
        };

        br0-lan-bridge = {
          enable = true;
          matchConfig = {
            Name = "br0";
          };

          networkConfig = {
            DHCP = "no";
            Address = [
              "${config.hostSpec.networking.hosts.stonebark.address}/${toString config.hostSpec.networking.hosts.stonebark.prefixLength}"
            ];
            DNS = config.hostSpec.networking.hosts.stonebark.nameservers;
          };

          routes = [
            {
              Destination = " 0.0.0.0/0 ";
              Gateway = config.hostSpec.networking.hosts.stonebark.gatewayAddress;
            }
          ];
        };

        enp5s0 = {
          matchConfig = {
            Name = "enp5s0";
          };

          networkConfig = {
            Bridge = "br0";
            DHCP = "no";
            DNS = config.hostSpec.networking.hosts.stonebark.nameservers;
          };
        };
      };
    };
  };

  users = {
    users.fedorsulaev = {
      isNormalUser = true;
      name = config.hostSpec.username;
      home = config.hostSpec.home;
      extraGroups = [ "wheel" "libvirtd" "kvm" ];
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
    pciutils
    usbutils
    dmidecode
  ];

  system.stateVersion = "25.05";
}


