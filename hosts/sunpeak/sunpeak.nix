{ inputs, config, pkgs, ... }:
{
  imports = [
    ../../common/utility/host-spec.nix
  ];

  hostSpec = {
    inherit (inputs.env-secrets.sunpeak) hostName username authorizedKeys hashedPassword rootHashedPassword;
    inherit (inputs.env-secrets) networking;
  };

  boot = {
    blacklistedKernelModules = [ "nouveau" ];
    initrd.kernelModules = [ "nvidia" ];
    kernelModules = [ "nvidia" ];
    kernelParams = [
      "nvidia-drm.modeset=1"
      "fbcon=map:1"
    ];
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = false;
    };
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
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  networking = {
    hostName = config.hostSpec.hostName;
    useNetworkd = false;
    networkmanager.enable = true;
    useDHCP = false;
    interfaces.enp1s0 = {
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
    users.${config.hostSpec.username} = {
      isNormalUser = true;
      name = config.hostSpec.username;
      home = config.hostSpec.home;
      extraGroups = [
        "wheel"
        "video"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = config.hostSpec.authorizedKeys;
      hashedPassword = config.hostSpec.hashedPassword;
    };
    users.root = {
      hashedPassword = config.hostSpec.rootHashedPassword;
    };
  };

  nix.settings = {
    trusted-users = [ "root" config.hostSpec.username ];
    experimental-features = "nix-command flakes";
  };

  time.timeZone = "Europe/Bucharest";

  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    zsh.enable = true;
    dconf.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      vim
      cloud-utils
      pciutils
      usbutils
    ];
  };

  system.stateVersion = "25.05";
}
