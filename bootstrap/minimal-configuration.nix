{ inputs, config, lib, pkgs, ... }:
{
  imports = [
    ../common/utility/host-spec.nix
  ];

  hostSpec = {
    hostName = "installer";
    username = "fedors";
  };

  fileSystems."/boot".options = [ "umask=0077" ]; # Removes permissions and security warnings.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = lib.mkDefault 3;
    consoleMode = lib.mkDefault "max";
  };
  boot.initrd = {
    systemd.enable = true;
    systemd.emergencyAccess = true;
    luks.forceLuksSupportInInitrd = true;
  };
  boot.kernelParams = [
    "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
    "systemd.show_status=true"
    #"systemd.log_level=debug"
    "systemd.log_target=console"
    "systemd.journald.forward_to_console=1"
  ];

  security.pam = {
    rssh.enable = true;
    services.sudo = {
      rssh = true;
      u2fAuth = true;
    };
  };

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      wget
      curl
      rsync
      git
      ;
  };

  networking = {
    networkmanager.enable = true;
  };

  services = {
    qemuGuest.enable = true;
    openssh =
      {
        enable = true;
        ports = [ 22 ];
        settings.PermitRootLogin = "yes";
        authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
      };
  };

  nix = {
    #FIXME(installer): registry and nixPath shouldn't be required here because flakes but removal results in warning spam on build
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
  };

  system.stateVersion = "25.05";
}
