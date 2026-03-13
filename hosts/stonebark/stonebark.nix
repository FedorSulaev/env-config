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

  sops = {
    defaultSopsFile = "${builtins.toString inputs.env-secrets + "/sops"}/${config.hostSpec.hostName}.enc.yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets."ddns_env" = { };
  };

  boot = {
    kernel.sysctl."vm.swappiness" = 10;
    kernelParams = [
      "nvidia-drm.modeset=1"
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    blacklistedKernelModules = [
      "nouveau"
    ];
    initrd.kernelModules = [ "nvidia" ];
    kernelModules = [ "nvidia" ];
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
    enableRedistributableFirmware = true;
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
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    displayManager.gdm.enable = true;
    desktopManager.gnome = {
      enable = true;
    };
    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = false;
      recommendedTlsSettings = true;
      virtualHosts = {
        "_" = {
          default = true;
          locations."/" = { return = "444"; };
        };
        "${config.hostSpec.networking.dns.riverfall.actual.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${config.hostSpec.networking.dns.riverfall.actual.target}";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto https;
            '';
          };
        };
        "${config.hostSpec.networking.dns.riverfall.nextcloud.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${config.hostSpec.networking.dns.riverfall.nextcloud.target}";
            proxyWebsockets = false;
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_set_header Connection "";

              proxy_set_header Host $host;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Proto https;
              proxy_set_header X-Forwarded-Port 443;

              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
        };
        "obsistant.com" = {
          enableACME = true;
          forceSSL = true;

          locations."/" = {
            return = "404";
          };
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = config.hostSpec.networking.dns.email;
      server = "https://acme-v02.api.letsencrypt.org/directory";
    };
  };

  virtualisation.libvirt = {
    enable = true;
    verbose = true;
    connections."qemu:///system" = {
      domains =
        (import ./libvirt/domains/riverfall-vm.nix { inherit inputs; });
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
    firewall.allowedTCPPorts = [ 80 443 ];
    extraHosts =
      let
        stonebarkIp = config.hostSpec.networking.hosts.stonebark.address;
      in
      ''
        ${stonebarkIp} ${config.hostSpec.networking.dns.riverfall.actual.domain}
        ${stonebarkIp} ${config.hostSpec.networking.dns.riverfall.nextcloud.domain}
      '';
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
    services = {
      update-ddns = {
        description = "DDNS Update";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        serviceConfig = {
          Type = "oneshot";
          EnvironmentFile = config.sops.secrets."ddns_env".path;
          StateDirectory = "update-ddns";
          ReadWritePaths = [ "/var/lib/update-ddns" ];
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
        };

        script = ''
          set -euo pipefail

          LAST="/var/lib/update-ddns/last_ip"

          IP="$(${pkgs.curl}/bin/curl -sS \
            -H "Content-Type: application/json" \
            -d "{\"apikey\":\"''${API_KEY}\",\"secretapikey\":\"''${SECRET_API_KEY}\"}" \
            "https://api.porkbun.com/api/json/v3/ping" | ${pkgs.jq}/bin/jq -r '.yourIp')"

          if [ -z "$IP" ] || [ "$IP" = "null" ]; then
            echo "Failed to obtain public IP from ping"
            exit 1
          fi

          if [ -f "$LAST" ] && [ "$(cat "$LAST")" = "$IP" ]; then
            echo "IP unchanged ($IP), skipping"
            exit 0
          fi

          ZONE="''${ZONE}"

          RECORDS_JSON="$(${pkgs.curl}/bin/curl -sS \
            -H "Content-Type: application/json" \
            -d "{\"apikey\":\"''${API_KEY}\",\"secretapikey\":\"''${SECRET_API_KEY}\"}" \
            "https://api.porkbun.com/api/json/v3/dns/retrieve/$ZONE")"
          echo "A records returned for $ZONE:"
          echo "$RECORDS_JSON" | ${pkgs.jq}/bin/jq -r \
            '.records[] | select(.type=="A") | "\(.id)\t\(.name)\t\(.content)\tTTL=\(.ttl)"'


          if [ "$(echo "$RECORDS_JSON" | ${pkgs.jq}/bin/jq -r '.status')" != "SUCCESS" ]; then
            echo "DNS retrieve failed: $RECORDS_JSON"
            exit 1
          fi

          APEX_ID="$(echo "$RECORDS_JSON" | ${pkgs.jq}/bin/jq -r --arg z "$ZONE" '
            .records[]
            | select(.type=="A")
            | select(
              (.name | rtrimstr(".")) == $z
              or (.name | rtrimstr(".")) == ($z + "." + $z)
            )
            | .id
          ' | head -n1)"

          APEX_NAME="$(echo "$RECORDS_JSON" | ${pkgs.jq}/bin/jq -r --arg z "$ZONE" '
            .records[]
            | select(.type=="A")
            | select(
              (.name | rtrimstr(".")) == $z
              or (.name | rtrimstr(".")) == ($z + "." + $z)
            )
            | .name
          ' | head -n1)"

          if [ -z "$APEX_ID" ] || [ -z "$APEX_NAME" ] || [ "$APEX_ID" = "null" ] || [ "$APEX_NAME" = "null" ]; then
            echo "Could not find apex A record for $ZONE"
            exit 1
          fi

          UPDATE_JSON="$(${pkgs.curl}/bin/curl -sS -H "Content-Type: application/json" \
            -d "{\"apikey\":\"''${API_KEY}\",\"secretapikey\":\"''${SECRET_API_KEY}\",\"name\":\"$APEX_NAME\",\"type\":\"A\",\"content\":\"$IP\",\"ttl\":\"600\"}" \
          "https://api.porkbun.com/api/json/v3/dns/edit/$ZONE/$APEX_ID")"


          if [ "$(echo "$UPDATE_JSON" | ${pkgs.jq}/bin/jq -r '.status')" != "SUCCESS" ]; then
            echo "DNS edit failed: $UPDATE_JSON"
            exit 1
          fi

          echo "$IP" > "$LAST"
          echo "Updated $APEX_NAME -> $IP"
        '';
      };
    };
    timers.update-ddns = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "10min";
        RandomizedDelaySec = "60s";
        Persistent = true;
      };
    };
  };

  users = {
    users.${config.hostSpec.username} = {
      isNormalUser = true;
      name = config.hostSpec.username;
      home = config.hostSpec.home;
      extraGroups = [ "wheel" "libvirtd" "kvm" "video" ];
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
    cloud-utils
    pciutils
    usbutils
    dmidecode
    openssl
    jq
    ripgrep
    dig
  ];

  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    zsh.enable = true;
    dconf.enable = true;
  };

  system.stateVersion = "25.05";
}


